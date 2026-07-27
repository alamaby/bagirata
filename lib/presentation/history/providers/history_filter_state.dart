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
  }) = _HistoryFilterState;

  const HistoryFilterState._();

  bool get isAmountSort =>
      sort == HistorySort.amountAsc || sort == HistorySort.amountDesc;

  bool get hasActiveFilters => paymentStatus != null || currencyCode != null;
}
