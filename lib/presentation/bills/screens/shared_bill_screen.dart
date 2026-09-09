import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/app_format.dart';
import '../../../core/format/currency_formatter.dart';
import '../../../core/router/routes.dart';
import '../../../domain/entities/participant.dart';
import '../../../domain/entities/shared_bill.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../../shared/widgets/loading_view.dart';
import '../providers/bill_detail_notifier.dart';
import '../providers/shared_bill_provider.dart';

/// Public read-only bill view opened from a `bagistruk://share/<token>` link.
/// No login wall, no legal/onboarding gates (exempted in the router): viewers
/// without an account see items, per-person totals, and payment status only.
/// No toggles, no edits, no bank info, no phone numbers.
class SharedBillScreen extends ConsumerWidget {
  const SharedBillScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final async = ref.watch(sharedBillProvider(token));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shareLinkPublicTitle)),
      body: SafeArea(
        child: switch (async) {
          AsyncLoading() => LoadingView(message: l10n.loading),
          AsyncError(:final error) => _ResolveErrorView(
            l10n: l10n,
            message: error.toString(),
            onRetry: () => ref.invalidate(sharedBillProvider(token)),
          ),
          AsyncData(:final value) =>
            value == null
                ? _ExpiredView(l10n: l10n)
                : _SharedBillView(shared: value),
        },
      ),
    );
  }
}

class _ResolveErrorView extends StatelessWidget {
  const _ResolveErrorView({
    required this.l10n,
    required this.message,
    required this.onRetry,
  });

  final AppL10n l10n;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48.r,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_outlined),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiredView extends StatelessWidget {
  const _ExpiredView({required this.l10n});

  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.link_off_outlined,
              size: 48.r,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.shareLinkExpired,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            FilledButton.tonalIcon(
              onPressed: () => context.pushNamed(Routes.registerName),
              icon: const Icon(Icons.person_add_outlined),
              label: Text(l10n.shareLinkJoinCta),
            ),
          ],
        ),
      ),
    );
  }
}

class _SharedBillView extends StatelessWidget {
  const _SharedBillView({required this.shared});

  final SharedBill shared;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final currency = CurrencyFormatter.of(shared.bill.currencyCode);
    // Reuse the settled bill math for per-person totals; the state object is
    // constructed locally and never persisted — display only.
    final detailState = BillDetailState(
      bill: shared.bill,
      items: shared.items,
      participants: shared.participants,
      assignments: shared.assignments,
    );
    final totals = {
      for (final t in detailState.calculateTotals()) t.participantId: t,
    };
    final byId = {for (final p in shared.participants) p.id: p};

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      children: [
        Text(
          shared.bill.title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 4.h),
        Text(
          AppFormat.longDate(
            AppFormat.intlLocaleOf(Localizations.localeOf(context)),
          ).format(shared.bill.receiptDate ?? shared.bill.createdAt),
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '${l10n.billDetailTotalBill}: ${currency.format(shared.bill.totalAmount)}',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        Text(
          shared.bill.isSettled
              ? l10n.billDetailSettled
              : l10n.billDetailUnsettled,
          style: TextStyle(
            fontSize: 13.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          l10n.exportLabelItems,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        for (final item in shared.items)
          _ItemRow(
            title:
                '${item.name} × ${item.qty == item.qty.roundToDouble() ? item.qty.toStringAsFixed(0) : item.qty}',
            subtitle: _assigneeNames(shared, item.id, byId),
            amount: currency.format(item.price * item.qty),
          ),
        SizedBox(height: 16.h),
        Text(
          l10n.exportLabelParticipants,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        for (final p in shared.participants)
          _ParticipantRow(
            name: p.name,
            status: p.isPaid
                ? l10n.settlementMessagePaid
                : l10n.settlementMessageUnpaid,
            amount: currency.format(totals[p.id]?.total ?? 0),
          ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            onPressed: () => context.pushNamed(Routes.registerName),
            icon: const Icon(Icons.person_add_outlined),
            label: Text(l10n.shareLinkJoinCta),
          ),
        ),
      ],
    );
  }

  String _assigneeNames(
    SharedBill shared,
    String itemId,
    Map<String, Participant> byId,
  ) {
    final names = shared.assignments
        .where((a) => a.itemId == itemId)
        .map((a) => byId[a.participantId]?.name)
        .whereType<String>()
        .join(', ');
    return names;
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final String title;
  final String subtitle;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14.sp)),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.name,
    required this.status,
    required this.amount,
  });

  final String name;
  final String status;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
