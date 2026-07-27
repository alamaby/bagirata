import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/bill_payment_status.dart';
export 'history_filter_state.dart';
import 'history_filter_state.dart';

part 'history_filter_notifier.g.dart';

@riverpod
class HistoryFilterNotifier extends _$HistoryFilterNotifier {
  @override
  HistoryFilterState build() => const HistoryFilterState();

  void setSort(HistorySort sort) => state = state.copyWith(sort: sort);

  void setPaymentStatus(BillPaymentStatus? status) =>
      state = state.copyWith(paymentStatus: status);

  void setCurrencyCode(String? code) =>
      state = state.copyWith(currencyCode: code);

  void apply(HistoryFilterState filter) => state = filter;

  void reset() => state = const HistoryFilterState();
}
