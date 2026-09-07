import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/bill_payment_status.dart';

part 'history_filter_state.freezed.dart';

enum HistorySort { newest, oldest, titleAsc, amountDesc, amountAsc }

@freezed
abstract class HistoryFilterState with _$HistoryFilterState {
  const factory HistoryFilterState({
    @Default(HistorySort.newest) HistorySort sort,
    BillPaymentStatus? paymentStatus,
    String? currencyCode,
    String? category,
    String? query,
  }) = _HistoryFilterState;

  const HistoryFilterState._();

  bool get isAmountSort =>
      sort == HistorySort.amountAsc || sort == HistorySort.amountDesc;

  /// Trimmed non-empty query, or null when the search box is effectively
  /// empty. An empty query must behave as "no filter", never as a full-scan
  /// `ILIKE '%%'`.
  String? get effectiveQuery {
    final q = query?.trim() ?? '';
    return q.isEmpty ? null : q;
  }

  bool get hasActiveFilters =>
      paymentStatus != null ||
      currencyCode != null ||
      category != null ||
      effectiveQuery != null;
}

HistoryFilterState normalizeHistoryFilter(
  HistoryFilterState filter,
  List<String> availableCurrencies,
) {
  if (!filter.isAmountSort) return filter;
  if (filter.currencyCode != null) return filter;
  if (availableCurrencies.length == 1) {
    return filter.copyWith(currencyCode: availableCurrencies.single);
  }
  return filter.copyWith(sort: HistorySort.newest);
}
