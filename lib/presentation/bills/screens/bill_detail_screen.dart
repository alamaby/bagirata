import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/format/app_format.dart';
import '../../../core/format/currency_formatter.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/services/settlement_reminder_service.dart';
import '../../../domain/entities/auth_snapshot.dart';
import '../../../domain/entities/participant.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../../auth/providers/auth_providers.dart';
import '../../credits/providers/ocr_credit_status_provider.dart';
import '../../settings/providers/transfer_bank_info_provider.dart';
import '../../shared/widgets/loading_view.dart';
import '../../shared/widgets/plus_info_icon.dart';
import '../export/bill_csv_exporter.dart';
import '../export/bill_pdf_exporter.dart';
import '../export/bill_xlsx_exporter.dart';
import '../export/export_filenames.dart';
import '../providers/bill_detail_notifier.dart';
import '../providers/bill_share_link_notifier.dart';
import '../providers/split_notifier.dart' show ParticipantTotal, SplitState;
import '../utils/settlement_share_launcher.dart';
import '../utils/settlement_message_builder.dart';
import '../widgets/participant_avatar.dart';

/// Settlement loop screen. Shows the bill header (merchant, total, settled
/// badge) and a list of participants with a `Switch` to toggle `is_paid`.
/// Auto-flips `bills.is_settled` when all participants are paid (handled in
/// the notifier).
class BillDetailScreen extends ConsumerWidget {
  const BillDetailScreen({super.key, required this.billId});

  final String billId;

  /// Settlement is the end of the flow — reset the nav stack instead of
  /// popping, so the device back button does not land the user back on
  /// review/split screens. Anon users have no history tab; send them to scan.
  void _goHome(BuildContext context, WidgetRef ref) {
    final snap = switch (ref.read(authStateProvider)) {
      AsyncData<AuthSnapshot>(:final value) => value,
      _ => null,
    };
    final isSignedIn = snap?.userId != null && !(snap?.isAnonymous ?? true);
    context.go(isSignedIn ? Routes.history : Routes.scan);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(billDetailFamily(billId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goHome(context, ref);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppL10n.of(context).billDetailTitle),
          leading: IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: AppL10n.of(context).billDetailHomeTooltip,
            onPressed: () => _goHome(context, ref),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.document_scanner_outlined),
              tooltip: AppL10n.of(context).billDetailScanAnotherTooltip,
              onPressed: () => context.go(Routes.scan),
            ),
          ],
        ),
        body: SafeArea(
          child: async.when(
            loading: () =>
                LoadingView(message: AppL10n.of(context).billDetailLoading),
            error: (e, _) => _ErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(billDetailFamily(billId)),
            ),
            data: (state) => _Body(
              state: state,
              billId: billId,
              currency: CurrencyFormatter.of(state.bill.currencyCode),
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.state,
    required this.billId,
    required this.currency,
  });

  final BillDetailState state;
  final String billId;
  final NumberFormat currency;

  Future<void> _toggle(BuildContext context, WidgetRef ref, String pid) async {
    final err = await ref
        .read(billDetailFamily(billId).notifier)
        .toggleParticipantPaymentStatus(pid);
    // Keep local reminders in sync (best-effort, never throws): settled →
    // cancel; otherwise (re)schedule — idempotent overwrite, so un-toggling a
    // participant back to unpaid restores the nudges.
    final bill = ref.read(billDetailFamily(billId)).value?.bill;
    if (bill != null) {
      final l10n = AppL10n.of(context);
      final title = bill.title;
      final totalLabel = currency.format(bill.totalAmount);
      final settled = bill.isSettled;
      unawaited(() async {
        try {
          final svc = await ref.read(
            settlementReminderServiceProvider.future,
          );
          if (settled) {
            await svc.cancelForBill(billId);
          } else {
            await svc.scheduleForBill(
              billId: billId,
              notificationTitle: l10n.reminderNotificationTitle,
              notificationBody: l10n.reminderNotificationBody(
                title,
                totalLabel,
              ),
              createdAt: bill.createdAt,
            );
          }
        } catch (e) {
          AppLogger.error('BillDetailScreen.reminderSync failed', e);
        }
      }());
    }
    if (err != null && context.mounted) {
      final l10n = AppL10n.of(context);
      final msg = switch (err.kind) {
        BillDetailActionErrorKind.notFound =>
          l10n.billDetailParticipantNotFound,
        BillDetailActionErrorKind.saveStatusFailed =>
          l10n.billDetailSaveStatusFailed(err.message ?? ''),
        BillDetailActionErrorKind.stateNotReady => l10n.billDetailStateNotReady,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _shareParticipant(
    BuildContext context,
    WidgetRef ref,
    Participant participant,
  ) async {
    final l10n = AppL10n.of(context);
    final creditStatus = await ref.refresh(ocrCreditStatusProvider.future);
    final isPlus = creditStatus?.isPlus ?? false;
    final bankInfo = isPlus
        ? await ref.read(transferBankInfoProvider.future)
        : null;
    final splitState = SplitState(
      bill: state.bill,
      items: state.items,
      participants: state.participants,
      assignments: state.assignments,
    );
    await launchSettlementShare(
      context: context,
      participant: participant,
      state: splitState,
      currency: currency,
      l10n: l10n,
      template: SettlementMessageTemplate.basic,
      subject: '${l10n.settlementMessageBillPrefix} ${state.bill.title}',
      bankInfo: bankInfo,
    );
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final isPlus = switch (ref.read(ocrCreditStatusProvider)) {
      AsyncData(:final value) => value?.isPlus ?? false,
      _ => false,
    };
    if (!isPlus) {
      context.goNamed(Routes.settingsName);
      return;
    }

    try {
      final bankInfo = isPlus
          ? await ref.read(transferBankInfoProvider.future)
          : null;
      if (!context.mounted) return;
      final csv = BillCsvExporter(
        state,
        l10n: l10n,
        bankInfo: bankInfo,
      ).build();
      final filename = ExportFilenames.unique(
        state.bill.title,
        state.bill.id,
        'csv',
      );
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(utf8.encode(csv)),
            mimeType: 'text/csv',
          ),
        ],
        subject: l10n.exportCsvSubject(state.bill.title),
        text: l10n.exportCsvShareText(state.bill.title),
        fileNameOverrides: [filename],
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
      }
    }
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final isPlus = switch (ref.read(ocrCreditStatusProvider)) {
      AsyncData(:final value) => value?.isPlus ?? false,
      _ => false,
    };
    if (!isPlus) {
      context.goNamed(Routes.settingsName);
      return;
    }

    try {
      final bankInfo = await ref.read(transferBankInfoProvider.future);
      if (!context.mounted) return;
      final bytes = await BillPdfExporter(
        state: state,
        currency: currency,
        dateFormat: AppFormat.longDate(
          AppFormat.intlLocaleOf(Localizations.localeOf(context)),
        ),
        l10n: l10n,
        bankInfo: bankInfo,
      ).build();
      final filename = ExportFilenames.unique(
        state.bill.title,
        state.bill.id,
        'pdf',
      );
      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'application/pdf')],
        subject: l10n.exportPdfSubject(state.bill.title),
        text: l10n.exportPdfShareText(state.bill.title),
        fileNameOverrides: [filename],
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
      }
    }
  }

  Future<void> _exportXlsx(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final isPlus = switch (ref.read(ocrCreditStatusProvider)) {
      AsyncData(:final value) => value?.isPlus ?? false,
      _ => false,
    };
    if (!isPlus) {
      context.goNamed(Routes.settingsName);
      return;
    }

    try {
      final bankInfo = isPlus
          ? await ref.read(transferBankInfoProvider.future)
          : null;
      if (!context.mounted) return;
      final bytes = BillXlsxExporter(
        state,
        l10n: l10n,
        bankInfo: bankInfo,
      ).build();
      final filename = ExportFilenames.unique(
        state.bill.title,
        state.bill.id,
        'xlsx',
      );
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(bytes),
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        subject: l10n.exportXlsxSubject(state.bill.title),
        text: l10n.exportXlsxShareText(state.bill.title),
        fileNameOverrides: [filename],
      );
    } catch (e, st) {
      AppLogger.error('BillDetailScreen._exportXlsx failed', e, st);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.exportFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = state.calculateTotals();
    final byId = {for (final t in totals) t.participantId: t};
    final isPlus = switch (ref.watch(ocrCreditStatusProvider)) {
      AsyncData(:final value) => value?.isPlus ?? false,
      _ => false,
    };
    final l10n = AppL10n.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      children: [
        _HeaderCard(
          title: state.bill.title,
          totalAmount: state.bill.totalAmount,
          isSettled: state.bill.isSettled,
          paidCount: state.paidCount,
          totalCount: state.participants.length,
          receiptDate: state.bill.receiptDate ?? state.bill.createdAt,
          currency: currency,
          l10n: l10n,
        ),
        SizedBox(height: 12.h),
        _ExportActions(
          isPlus: isPlus,
          onExportPdf: () => _exportPdf(context, ref),
          onExportCsv: () => _exportCsv(context, ref),
          onExportXlsx: () => _exportXlsx(context, ref),
          l10n: l10n,
        ),
        SizedBox(height: 12.h),
        _ShareLinkSection(billId: billId),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            l10n.billDetailParticipants,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        if (state.participants.isEmpty)
          _EmptyParticipants(billId: billId, l10n: l10n)
        else
          for (final p in state.participants)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _ParticipantTile(
                participant: p,
                total: byId[p.id],
                currency: currency,
                onChanged: () => _toggle(context, ref, p.id),
                onShare: () => _shareParticipant(context, ref, p),
              ),
            ),
      ],
    );
  }
}

class _ExportActions extends StatelessWidget {
  const _ExportActions({
    required this.isPlus,
    required this.onExportPdf,
    required this.onExportCsv,
    required this.onExportXlsx,
    required this.l10n,
  });

  final bool isPlus;
  final VoidCallback onExportPdf;
  final VoidCallback onExportCsv;
  final VoidCallback onExportXlsx;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = isPlus ? Icons.file_download_outlined : Icons.lock_outline;
    final lockedStyle = FilledButton.styleFrom(
      minimumSize: Size.fromHeight(44.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      backgroundColor: scheme.surfaceContainerHigh,
      foregroundColor: scheme.onSurfaceVariant,
    );

    final buttons = Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onExportPdf,
            icon: Icon(isPlus ? Icons.picture_as_pdf_outlined : icon),
            label: _OneLineButtonLabel(
              isPlus ? l10n.exportPdf : l10n.exportPdfPlusLocked,
            ),
            style: isPlus
                ? FilledButton.styleFrom(
                    minimumSize: Size.fromHeight(44.h),
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                  )
                : lockedStyle,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onExportCsv,
            icon: Icon(icon),
            label: _OneLineButtonLabel(
              isPlus ? l10n.exportCsv : l10n.exportCsvPlusLocked,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.fromHeight(44.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
            ),
          ),
        ),
        if (!isPlus) ...[
          SizedBox(width: 4.w),
          PlusInfoIcon(
            title: l10n.exportPdfPlusLocked,
            message: l10n.exportPlusDetail,
            iconColor: scheme.onSurfaceVariant,
          ),
        ],
      ],
    );
    return Column(
      children: [
        buttons,
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onExportXlsx,
            icon: Icon(
              isPlus ? Icons.table_chart_outlined : Icons.lock_outline,
            ),
            label: _OneLineButtonLabel(
              isPlus ? l10n.exportXlsx : l10n.exportXlsxPlusLocked,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.fromHeight(44.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
            ),
          ),
        ),
      ],
    );
  }
}

class _OneLineButtonLabel extends StatelessWidget {
  const _OneLineButtonLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.totalAmount,
    required this.isSettled,
    required this.paidCount,
    required this.totalCount,
    required this.receiptDate,
    required this.currency,
    required this.l10n,
  });

  final String title;
  final double totalAmount;
  final bool isSettled;
  final int paidCount;
  final int totalCount;
  final DateTime receiptDate;
  final NumberFormat currency;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              _StatusBadge(isSettled: isSettled, l10n: l10n),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 14.r,
                color: scheme.onSurfaceVariant,
              ),
              SizedBox(width: 4.w),
              Text(
                AppFormat.longDate(
                  AppFormat.intlLocaleOf(Localizations.localeOf(context)),
                ).format(receiptDate),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.billDetailTotalBill,
            style: TextStyle(fontSize: 12.sp, color: scheme.onSurfaceVariant),
          ),
          SizedBox(height: 2.h),
          Text(
            currency.format(totalAmount),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          if (totalCount > 0) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.people_alt_outlined,
                  size: 16.r,
                  color: scheme.onSurfaceVariant,
                ),
                SizedBox(width: 6.w),
                Text(
                  l10n.billDetailPaidProgress(paidCount, totalCount),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: totalCount == 0 ? 0 : paidCount / totalCount,
                minHeight: 6.h,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  isSettled ? scheme.primary : scheme.tertiary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isSettled, required this.l10n});

  final bool isSettled;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isSettled ? scheme.primaryContainer : scheme.secondaryContainer;
    final fg = isSettled
        ? scheme.onPrimaryContainer
        : scheme.onSecondaryContainer;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSettled ? Icons.check_circle : Icons.schedule,
            size: 14.r,
            color: fg,
          ),
          SizedBox(width: 4.w),
          Text(
            isSettled ? l10n.billDetailSettled : l10n.billDetailUnsettled,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.participant,
    required this.total,
    required this.currency,
    required this.onChanged,
    required this.onShare,
  });

  final Participant participant;
  final ParticipantTotal? total;
  final NumberFormat currency;
  final VoidCallback onChanged;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final paid = participant.isPaid;
    final amount = total?.total ?? 0;

    return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  ParticipantAvatar(
                    id: participant.id,
                    name: participant.name,
                    size: 40,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: paid
                                ? scheme.onSurface.withValues(alpha: 0.55)
                                : scheme.onSurface,
                            decoration: paid
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: scheme.onSurfaceVariant,
                          ),
                          child: Text(participant.name),
                        ),
                        SizedBox(height: 2.h),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: paid
                                ? scheme.primary.withValues(alpha: 0.6)
                                : scheme.primary,
                            decoration: paid
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: scheme.onSurfaceVariant,
                          ),
                          child: Text(currency.format(amount)),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.outlined(
                        tooltip: AppL10n.of(context).participantShareAgain,
                        onPressed: onShare,
                        icon: const Icon(Icons.share_outlined),
                      ),
                      SizedBox(width: 4.w),
                      Switch.adaptive(
                        value: paid,
                        onChanged: (_) => onChanged(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
        .animate(target: paid ? 1 : 0)
        .fade(begin: 1.0, end: 0.7, duration: 220.ms);
  }
}

class _EmptyParticipants extends StatelessWidget {
  const _EmptyParticipants({required this.billId, required this.l10n});

  final String billId;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.group_outlined,
            size: 40.r,
            color: scheme.onSurfaceVariant,
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.billDetailEmptyParticipants,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: scheme.onSurfaceVariant),
          ),
          SizedBox(height: 12.h),
          FilledButton.tonalIcon(
            onPressed: () => context.pushNamed(
              Routes.billSplitName,
              pathParameters: {'billId': billId},
            ),
            icon: const Icon(Icons.call_split),
            label: Text(l10n.billDetailGoToSplit),
          ),
        ],
      ),
    );
  }
}

/// Owner-side share-link controls (M2/F5): create/copy a 7-day read-only
/// link, show its expiry while active, revoke it. The raw token lives only
/// in the creating session (clipboard + in-memory `lastLink`); reopening the
/// screen shows expiry + revoke for the active row resolved by hash lookup.
class _ShareLinkSection extends ConsumerStatefulWidget {
  const _ShareLinkSection({required this.billId});

  final String billId;

  @override
  ConsumerState<_ShareLinkSection> createState() => _ShareLinkSectionState();
}

class _ShareLinkSectionState extends ConsumerState<_ShareLinkSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(billShareLinkFamily(widget.billId).notifier).load(widget.billId),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(billShareLinkFamily(widget.billId).notifier)
        .createAndCopy(widget.billId);
    if (!context.mounted) return;
    final l10n = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (result.link != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.shareLinkCopied),
          action: SnackBarAction(
            label: l10n.splitSummaryShare,
            onPressed: () => Share.shareUri(Uri.parse(result.link!)),
          ),
        ),
      );
    } else if (result.limited) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.shareLinkFreeLimit),
          action: SnackBarAction(
            label: l10n.billingUpgradePlus,
            onPressed: () => context.pushNamed(Routes.settingsName),
          ),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.shareLinkCreateFailed)),
      );
    }
  }

  Future<void> _revoke(
    BuildContext context,
    WidgetRef ref,
    String tokenId,
  ) async {
    final ok = await ref
        .read(billShareLinkFamily(widget.billId).notifier)
        .revoke(tokenId);
    if (!context.mounted) return;
    final l10n = AppL10n.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(ok ? l10n.shareLinkRevoked : l10n.shareLinkCreateFailed),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(billShareLinkFamily(widget.billId));

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link_outlined,
                size: 18.r,
                color: scheme.onSurfaceVariant,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.shareLinkSectionTitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          switch (async) {
            AsyncLoading() => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: CircularProgressIndicator(),
              ),
            ),
            AsyncError() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.shareLinkCreateFailed,
                  style: TextStyle(fontSize: 13.sp, color: scheme.error),
                ),
                SizedBox(height: 8.h),
                OutlinedButton.icon(
                  onPressed: () => ref
                      .read(
                        billShareLinkFamily(widget.billId).notifier,
                      )
                      .load(widget.billId),
                  icon: const Icon(Icons.refresh_outlined),
                  label: Text(l10n.retry),
                ),
              ],
            ),
            AsyncData(:final value) when value == null => SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _create(context, ref),
                icon: const Icon(Icons.content_copy_outlined),
                label: Text(l10n.shareLinkCreate),
              ),
            ),
            AsyncData(:final value) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.shareLinkExpiresIn(
                    DateFormat.yMMMd(
                      AppFormat.intlLocaleOf(Localizations.localeOf(context)),
                    ).format(value!.expiresAt.toLocal()),
                  ),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    if (value.lastLink != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              Share.shareUri(Uri.parse(value.lastLink!)),
                          icon: const Icon(Icons.share_outlined),
                          label: Text(l10n.splitSummaryShare),
                        ),
                      ),
                    if (value.lastLink != null) SizedBox(width: 8.w),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _revoke(context, ref, value.tokenId),
                        icon: const Icon(Icons.link_off_outlined),
                        label: Text(l10n.shareLinkRevoke),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _ => const SizedBox.shrink(),
          },
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: scheme.error, size: 48.r),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(AppL10n.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }
}
