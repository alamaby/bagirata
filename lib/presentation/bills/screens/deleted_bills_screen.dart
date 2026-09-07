import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/billing/plus_feature_limits.dart';
import '../../../core/error/result.dart';
import '../../../core/format/currency_formatter.dart';
import '../../../core/router/routes.dart';
import '../../../domain/entities/deleted_bill.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../../credits/providers/ocr_credit_status_provider.dart';
import '../../shared/widgets/plus_info_icon.dart';
import '../providers/bill_list_notifier.dart';

class DeletedBillsScreen extends ConsumerWidget {
  const DeletedBillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final creditStatusAsync = ref.watch(ocrCreditStatusProvider);
    final creditStatus = switch (creditStatusAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final isPlus = creditStatus?.isPlus ?? false;
    final deletedBills = ref.watch(deletedBillListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deletedBillsTitle)),
      body: creditStatusAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : !isPlus
          ? _LockedView(onUpgrade: () => context.goNamed(Routes.settingsName))
          : deletedBills.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => _ErrorView(
                onRetry: () =>
                    ref.read(deletedBillListProvider.notifier).refresh(),
              ),
              data: (bills) => RefreshIndicator(
                onRefresh: () =>
                    ref.read(deletedBillListProvider.notifier).refresh(),
                child: bills.isEmpty
                    ? const _EmptyView()
                    : ListView.separated(
                        padding: EdgeInsets.all(16.w),
                        itemCount: bills.length,
                        separatorBuilder: (_, _) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) => _DeletedBillTile(
                          bill: bills[index],
                          onRestore: () =>
                              _restoreBill(context, ref, bills[index]),
                        ),
                      ),
              ),
            ),
    );
  }

  Future<void> _restoreBill(
    BuildContext context,
    WidgetRef ref,
    DeletedBill bill,
  ) async {
    final l10n = AppL10n.of(context);
    // Client-side pre-check: an already-expired row fails server-side anyway;
    // surfacing the specific message here avoids a confusing generic error.
    if (bill.isExpired) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.deletedBillExpiredError),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final result = await ref
        .read(deletedBillListProvider.notifier)
        .restoreBill(bill.id);
    if (!context.mounted) return;

    final message = switch (result) {
      Success<void>() => l10n.deletedBillRestored,
      ResultFailure(:final failure)
          when failure.toString().contains(
            'deleted_bill_not_found_or_expired',
          ) =>
        l10n.deletedBillExpiredError,
      ResultFailure() => l10n.errorGeneric,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _DeletedBillTile extends StatelessWidget {
  const _DeletedBillTile({required this.bill, required this.onRestore});

  final DeletedBill bill;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final currency = CurrencyFormatter.of(bill.currencyCode);
    final deletedAt = DateFormat.yMMMd().add_Hm().format(bill.deletedAt);
    final expiresAt = DateFormat.yMMMd().format(bill.deleteExpiresAt);
    final daysLeft = PlusFeatureLimits.trashDaysRemaining(
      bill.deleteExpiresAt,
    );

    return Card(
      child: ListTile(
        leading: const Icon(Icons.restore_from_trash_outlined),
        title: Text(bill.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${currency.format(bill.totalAmount)}\n'
          '${l10n.deletedBillDeletedAt(deletedAt)}\n'
          '${l10n.deletedBillExpiresAt(expiresAt)}'
          '${bill.isExpired ? '' : ' • ${l10n.deletedBillExpiresInDays(daysLeft)}'}',
        ),
        isThreeLine: true,
        trailing: IconButton.filledTonal(
          tooltip: l10n.deletedBillRestoreAction,
          onPressed: bill.isExpired ? null : onRestore,
          icon: const Icon(Icons.restore_outlined),
        ),
      ),
    );
  }
}

class _LockedView extends StatelessWidget {
  const _LockedView({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 56.r,
              color: scheme.primary,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.deletedBillsLockedTitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            PlusInfoIcon(
              title: l10n.deletedBillsLockedTitle,
              message: l10n.deletedBillsRetentionPlus(
                PlusFeatureLimits.trashRetentionDaysPlus,
              ),
              iconColor: scheme.primary,
            ),
            SizedBox(height: 16.h),
            FilledButton.icon(
              icon: const Icon(Icons.workspace_premium_outlined),
              onPressed: onUpgrade,
              label: Text(l10n.historyUpgradeCta),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return ListView(
      children: [
        SizedBox(height: 120.h),
        Icon(
          Icons.delete_outline,
          size: 56.r,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(height: 12.h),
        Text(
          l10n.deletedBillsEmpty,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48.r,
            ),
            SizedBox(height: 12.h),
            Text(l10n.errorGeneric, textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            FilledButton.tonal(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
