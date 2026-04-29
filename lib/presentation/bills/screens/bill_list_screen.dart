import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/loading_view.dart';
import '../providers/bill_list_notifier.dart';

class BillListScreen extends ConsumerWidget {
  const BillListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billListProvider);
    final currency = NumberFormat.simpleCurrency();

    return AppScaffold(
      title: 'BagiStruk',
      body: bills.when(
        loading: () => const LoadingView(message: 'Loading bills…'),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    color: Theme.of(context).colorScheme.error, size: 48.r),
                SizedBox(height: 12.h),
                Text(e.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp)),
                SizedBox(height: 16.h),
                FilledButton.tonal(
                  onPressed: () => ref
                      .read(billListProvider.notifier)
                      .refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (list) => list.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: list.length,
                separatorBuilder: (_, _) => SizedBox(height: 8.h),
                itemBuilder: (context, i) {
                  final bill = list[i];
                  return Card(
                    child: ListTile(
                      title: Text(bill.title),
                      subtitle: Text(currency.format(bill.totalAmount)),
                      trailing: bill.isSettled
                          ? const Icon(Icons.check_circle, color: Colors.green)
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(Routes.captureName),
        icon: const Icon(Icons.camera_alt),
        label: const Text('New bill'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          'No bills yet. Tap “New bill” to scan a receipt.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp),
        ),
      ),
    );
  }
}
