import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/format/app_format.dart';
import '../../../core/router/routes.dart';
import '../../../domain/entities/auth_snapshot.dart';
import '../../../domain/entities/participant.dart';
import '../../auth/providers/auth_providers.dart';
import '../../shared/widgets/loading_view.dart';
import '../providers/bill_detail_notifier.dart';
import '../providers/split_notifier.dart' show ParticipantTotal;
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
    final currency = AppFormat.currency();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tagihan'),
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Beranda',
          onPressed: () => _goHome(context, ref),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined),
            tooltip: 'Scan struk lain',
            onPressed: () => context.go(Routes.scan),
          ),
        ],
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const LoadingView(message: 'Memuat detail…'),
          error: (e, _) => _ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(billDetailFamily(billId)),
          ),
          data: (state) => _Body(
            state: state,
            billId: billId,
            currency: currency,
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
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totals = state.calculateTotals();
    final byId = {for (final t in totals) t.participantId: t};

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
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Partisipan',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        if (state.participants.isEmpty)
          _EmptyParticipants(billId: billId)
        else
          for (final p in state.participants)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: _ParticipantTile(
                participant: p,
                total: byId[p.id],
                currency: currency,
                onChanged: () => _toggle(context, ref, p.id),
              ),
            ),
      ],
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
  });

  final String title;
  final double totalAmount;
  final bool isSettled;
  final int paidCount;
  final int totalCount;
  final DateTime receiptDate;
  final NumberFormat currency;

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
              _StatusBadge(isSettled: isSettled),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.event_outlined,
                  size: 14.r, color: scheme.onSurfaceVariant),
              SizedBox(width: 4.w),
              Text(
                AppFormat.longDate().format(receiptDate),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Total tagihan',
            style: TextStyle(
              fontSize: 12.sp,
              color: scheme.onSurfaceVariant,
            ),
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
                  '$paidCount/$totalCount partisipan sudah bayar',
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
  const _StatusBadge({required this.isSettled});

  final bool isSettled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isSettled ? scheme.primaryContainer : scheme.secondaryContainer;
    final fg =
        isSettled ? scheme.onPrimaryContainer : scheme.onSecondaryContainer;
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
            isSettled ? 'Lunas' : 'Belum lunas',
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
  });

  final Participant participant;
  final ParticipantTotal? total;
  final NumberFormat currency;
  final VoidCallback onChanged;

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
      child: Row(
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
                    decoration:
                        paid ? TextDecoration.lineThrough : TextDecoration.none,
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
                    decoration:
                        paid ? TextDecoration.lineThrough : TextDecoration.none,
                    decorationColor: scheme.onSurfaceVariant,
                  ),
                  child: Text(currency.format(amount)),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: paid,
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    )
        .animate(target: paid ? 1 : 0)
        .fade(begin: 1.0, end: 0.7, duration: 220.ms);
  }
}

class _EmptyParticipants extends StatelessWidget {
  const _EmptyParticipants({required this.billId});

  final String billId;

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
          Icon(Icons.group_outlined, size: 40.r, color: scheme.onSurfaceVariant),
          SizedBox(height: 8.h),
          Text(
            'Belum ada partisipan untuk tagihan ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: scheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12.h),
          FilledButton.tonalIcon(
            onPressed: () => context.pushNamed(
              Routes.billSplitName,
              pathParameters: {'billId': billId},
            ),
            icon: const Icon(Icons.call_split),
            label: const Text('Pergi ke Pembagian'),
          ),
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
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
