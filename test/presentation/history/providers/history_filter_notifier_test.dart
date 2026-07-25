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
  });
}
