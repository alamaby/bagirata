import '../../../domain/entities/bill.dart';
import '../providers/history_filter_notifier.dart';

/// Pure functions for filtering and sorting bill lists on the client.
///
/// Designed to be unit-testable with no Flutter dependency.

/// Returns the filtered and sorted list. Input list is NOT mutated.
/// Nominal sort falls back to [HistorySort.newest] when the result spans
/// multiple currencies without a currency filter — see [effectiveHistorySort].
List<Bill> applyHistoryFilter(
  List<Bill> bills,
  HistoryFilterState filter,
) {
  var result = bills;

  if (filter.paymentStatus != null) {
    result = result.where((b) => b.paymentStatus == filter.paymentStatus).toList(growable: false);
  }

  if (filter.currencyCode != null) {
    result = result.where((b) => b.currencyCode == filter.currencyCode).toList(growable: false);
  }

  if (filter.category != null) {
    result = result.where((b) => b.category == filter.category).toList(growable: false);
  }

  final q = filter.effectiveQuery;
  if (q != null) {
    final needle = q.toLowerCase();
    result = result.where((b) => b.title.toLowerCase().contains(needle)).toList(growable: false);
  }

  final sort = effectiveHistorySort(result, filter);
  result = result.toList(growable: false)..sort((a, b) => _compare(a, b, sort));
  return result;
}

/// Returns the sort to actually use, potentially downgrading from a nominal
/// sort when the data doesn't support it (multi-currency without a filter).
///
/// This is both the UI gate (disable chips) and the defense-in-depth fallback
/// so that even if an invalid sort order is somehow stored, it never reaches
/// the comparison function.
HistorySort effectiveHistorySort(
  List<Bill> bills,
  HistoryFilterState filter,
) {
  if (filter.currencyCode != null) return filter.sort;
  if (switch (filter.sort) {
    HistorySort.amountAsc || HistorySort.amountDesc => true,
    _ => false,
  }) {
    final currencies = bills.map((b) => b.currencyCode).toSet();
    if (currencies.length > 1) return HistorySort.newest;
  }
  return filter.sort;
}

/// Whether nominal (amount) sort options are meaningful given the current
/// filter state and bill data. Nominal sort only makes sense when the result
/// set has at most one currency, or a currency filter is active.
bool nominalSortAvailable(
  List<Bill> bills,
  HistoryFilterState filter,
) {
  if (filter.currencyCode != null) return true;
  final currencies = bills.map((b) => b.currencyCode).toSet();
  return currencies.length <= 1;
}

int _compare(Bill a, Bill b, HistorySort sort) {
  final cmp = switch (sort) {
    HistorySort.newest => b.createdAt.compareTo(a.createdAt),
    HistorySort.oldest => a.createdAt.compareTo(b.createdAt),
    HistorySort.titleAsc => _compareTitle(a.title, b.title),
    HistorySort.amountDesc => a.totalAmount.compareTo(b.totalAmount).sign * -1,
    HistorySort.amountAsc => a.totalAmount.compareTo(b.totalAmount).sign,
  };
  if (cmp != 0) return cmp;
  return b.createdAt.compareTo(a.createdAt);
}

int _compareTitle(String a, String b) {
  return a.toLowerCase().compareTo(b.toLowerCase());
}
