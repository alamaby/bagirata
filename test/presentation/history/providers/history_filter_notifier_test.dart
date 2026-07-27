import 'package:bagistruk/domain/entities/bill_payment_status.dart';
import 'package:bagistruk/presentation/history/providers/history_filter_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HistoryFilterNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
    });

    test('default state has newest sort, no filters', () {
      final state = container.read(historyFilterProvider);
      expect(state.sort, HistorySort.newest);
      expect(state.paymentStatus, isNull);
      expect(state.currencyCode, isNull);
      expect(state.hasActiveFilters, isFalse);
    });

    test('setSort updates sort', () {
      container
          .read(historyFilterProvider.notifier)
          .setSort(HistorySort.amountDesc);
      expect(container.read(historyFilterProvider).sort, HistorySort.amountDesc);
    });

    test('setPaymentStatus updates and reflects hasActiveFilters', () {
      container
          .read(historyFilterProvider.notifier)
          .setPaymentStatus(BillPaymentStatus.unpaid);
      final state = container.read(historyFilterProvider);
      expect(state.paymentStatus, BillPaymentStatus.unpaid);
      expect(state.hasActiveFilters, isTrue);
    });

    test('setCurrencyCode updates and reflects hasActiveFilters', () {
      container.read(historyFilterProvider.notifier).setCurrencyCode('USD');
      final state = container.read(historyFilterProvider);
      expect(state.currencyCode, 'USD');
      expect(state.hasActiveFilters, isTrue);
    });

    test('reset returns to defaults', () {
      container
          .read(historyFilterProvider.notifier)
          .setSort(HistorySort.titleAsc);
      container
          .read(historyFilterProvider.notifier)
          .setPaymentStatus(BillPaymentStatus.settled);
      container.read(historyFilterProvider.notifier).setCurrencyCode('JPY');

      container.read(historyFilterProvider.notifier).reset();
      final state = container.read(historyFilterProvider);
      expect(state.sort, HistorySort.newest);
      expect(state.paymentStatus, isNull);
      expect(state.currencyCode, isNull);
      expect(state.hasActiveFilters, isFalse);
    });

    test('isAmountSort true for amountAsc', () {
      final state =
          const HistoryFilterState(sort: HistorySort.amountAsc);
      expect(state.isAmountSort, isTrue);
    });

    test('isAmountSort true for amountDesc', () {
      final state =
          const HistoryFilterState(sort: HistorySort.amountDesc);
      expect(state.isAmountSort, isTrue);
    });

    test('isAmountSort false for newest', () {
      final state =
          const HistoryFilterState(sort: HistorySort.newest);
      expect(state.isAmountSort, isFalse);
    });

    test('apply replaces all fields atomically', () {
      container
          .read(historyFilterProvider.notifier)
          .setSort(HistorySort.oldest);
      container
          .read(historyFilterProvider.notifier)
          .setPaymentStatus(BillPaymentStatus.unpaid);
      container
          .read(historyFilterProvider.notifier)
          .setCurrencyCode('IDR');

      container.read(historyFilterProvider.notifier).apply(
            const HistoryFilterState(
              sort: HistorySort.amountDesc,
              paymentStatus: BillPaymentStatus.settled,
              currencyCode: 'USD',
            ),
          );

      final state = container.read(historyFilterProvider);
      expect(state.sort, HistorySort.amountDesc);
      expect(state.paymentStatus, BillPaymentStatus.settled);
      expect(state.currencyCode, 'USD');
    });

    test('isAmountSort and hasActiveFilters composable', () {
      final state = const HistoryFilterState(
        sort: HistorySort.amountAsc,
        currencyCode: 'IDR',
      );
      expect(state.isAmountSort, isTrue);
      expect(state.hasActiveFilters, isTrue);
    });
  });
}
