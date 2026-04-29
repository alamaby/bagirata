import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/format/app_format.dart';
import '../../../core/router/routes.dart';
import '../../../data/providers.dart';
import '../../../domain/entities/bill.dart';
import '../../bills/providers/bill_list_notifier.dart';
import '../../shared/widgets/loading_view.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billListProvider);
    final currency = AppFormat.currency();

    return Scaffold(
      body: SafeArea(
        child: bills.when(
          loading: () => const LoadingView(message: 'Memuat riwayat…'),
          error: (e, _) => _ErrorView(
            message: e.toString(),
            onRetry: () => ref.read(billListProvider.notifier).refresh(),
          ),
          data: (list) => RefreshIndicator(
            onRefresh: () => ref.read(billListProvider.notifier).refresh(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: const Text('Riwayat'),
                  pinned: true,
                  actions: [
                    IconButton(
                      tooltip: 'Keluar',
                      icon: const Icon(Icons.logout),
                      onPressed: () => _signOut(context, ref),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: _SummaryCards(bills: list, currency: currency),
                ),
                if (list.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    sliver: SliverList.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) => SizedBox(height: 8.h),
                      itemBuilder: (context, i) {
                        final bill = list[i];
                        return Card(
                          child: ListTile(
                            title: Text(bill.title),
                            subtitle: Text(currency.format(bill.totalAmount)),
                            trailing: bill.isSettled
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : const Icon(Icons.chevron_right),
                            onTap: () => context.pushNamed(
                              Routes.billSplitName,
                              pathParameters: {'billId': bill.id},
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: 24.h)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    await repo.signInAnonymously();
    if (!context.mounted) return;
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Kamu sudah keluar.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.bills, required this.currency});

  final List<Bill> bills;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final totalBills = bills.length;
    final outstanding = bills
        .where((b) => !b.isSettled)
        .fold<double>(0, (sum, b) => sum + b.totalAmount);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Total bill',
              value: '$totalBills',
              icon: Icons.receipt_long_outlined,
              color: scheme.primaryContainer,
              onColor: scheme.onPrimaryContainer,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _StatCard(
              label: 'Piutang outstanding',
              value: currency.format(outstanding),
              icon: Icons.account_balance_wallet_outlined,
              color: scheme.tertiaryContainer,
              onColor: scheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: onColor, size: 22.r),
          SizedBox(height: 10.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: onColor.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: onColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined,
                size: 56.r, color: scheme.onSurfaceVariant),
            SizedBox(height: 12.h),
            Text(
              'Belum ada bill tersimpan.\nMulai scan struk dari tab Scan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: Theme.of(context).colorScheme.error, size: 48.r),
            SizedBox(height: 12.h),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 16.h),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}
