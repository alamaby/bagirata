import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/billing/plus_feature_limits.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data/providers.dart';
import '../../../domain/entities/bill_payment_status.dart';
import '../../../domain/entities/history_bill.dart';
import '../../../domain/entities/history_bill_page.dart';
import '../../../domain/entities/history_cursor.dart';
import '../../../domain/entities/history_summary.dart';
import '../../credits/providers/ocr_credit_status_provider.dart';
import '../../insights/providers/monthly_spending_insight_provider.dart';
import 'history_filter_notifier.dart';
import 'history_filter_state.dart';

part 'history_list_notifier.freezed.dart';
part 'history_list_notifier.g.dart';

@freezed
abstract class HistoryListState with _$HistoryListState {
  const factory HistoryListState({
    @Default([]) List<HistoryBill> items,
    HistoryCursor? nextCursor,
    HistorySummary? summary,
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingInitial,
    @Default(false) bool isLoadingMore,
    Failure? initialFailure,
    Failure? loadMoreFailure,
  }) = _HistoryListState;

  const HistoryListState._();
}

@riverpod
class HistoryListNotifier extends _$HistoryListNotifier {
  /// Cached summary. Persisted across `build()` invocations so that amount-sort
  /// normalization sees the same currency list as before the filter change.
  HistorySummary? _lastSummary;

  @override
  HistoryListState build() {
    ref.watch(historyFilterProvider);
    ref.watch(ocrCreditStatusProvider);
    state = HistoryListState(
      isLoadingInitial: true,
      summary: _lastSummary,
    );
    _loadFirstPage();
    return state;
  }

  Future<void> _loadFirstPage() async {
    state = state.copyWith(
      isLoadingInitial: true,
      initialFailure: null,
      loadMoreFailure: null,
    );
    final success = await _fetchPage(cursor: null, append: false);
    if (success) {
      state = state.copyWith(isLoadingInitial: false);
    } else {
      state = state.copyWith(
        isLoadingInitial: false,
        initialFailure: Failure.unknown('Initial load failed', null),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isLoadingInitial: true,
      initialFailure: null,
      loadMoreFailure: null,
    );
    await _fetchPage(cursor: null, append: false);
    state = state.copyWith(isLoadingInitial: false);
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.nextCursor == null) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, loadMoreFailure: null);
    final success = await _fetchPage(cursor: state.nextCursor!, append: true);
    state = state.copyWith(
      isLoadingMore: false,
      loadMoreFailure: success
          ? null
          : Failure.unknown('Load more failed', null),
    );
  }

  /// Deletes a bill. Returns `true` on success, `false` when sign-in or the
  /// delete fails, so the caller can surface feedback instead of silently
  /// leaving the row in place.
  Future<bool> deleteBill(String billId) async {
    final repo = ref.read(billRepositoryProvider);
    final authRes = await repo.ensureSignedIn();
    if (authRes is ResultFailure) return false;
    final result = await repo.deleteBill(billId);
    if (result is ResultFailure) return false;

    state = state.copyWith(
      items: state.items.where((b) => b.id != billId).toList(growable: false),
    );
    await _updateSummary();
    ref.invalidate(monthlySpendingInsightProvider);
    return true;
  }

  Future<void> _updateSummary() async {
    final creditStatusAsync = ref.read(ocrCreditStatusProvider);
    final creditStatus = switch (creditStatusAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final historyDays = PlusFeatureLimits.historyDays(
      planCode: creditStatus?.planCode,
    );
    if (historyDays <= 0) return;
    final createdAfter = PlusFeatureLimits.historyCutoff(
      planCode: creditStatus?.planCode,
      now: DateTime.now(),
    );
    if (createdAfter == null) return;

    final repo = ref.read(billRepositoryProvider);
    final result = await repo.getHistorySummary(createdAfter: createdAfter);
    if (result is Success<HistorySummary>) {
      _lastSummary = result.data;
      state = state.copyWith(summary: result.data);
    }
  }

  Future<bool> _fetchPage({
    required HistoryCursor? cursor,
    required bool append,
  }) async {
    final filter = ref.read(historyFilterProvider);
    final creditStatusAsync = ref.read(ocrCreditStatusProvider);
    final creditStatus = switch (creditStatusAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final historyDays = PlusFeatureLimits.historyDays(
      planCode: creditStatus?.planCode,
    );
    if (historyDays <= 0) {
      _lastSummary = null;
      state = state.copyWith(items: [], hasMore: false, summary: null);
      return true;
    }

    final createdAfter = PlusFeatureLimits.historyCutoff(
      planCode: creditStatus?.planCode,
      now: DateTime.now(),
    );
    if (createdAfter == null) {
      state = state.copyWith(items: [], hasMore: false);
      return true;
    }

    final availableCurrencies =
        _lastSummary?.availableCurrencies ?? const <String>[];
    final normalized = normalizeHistoryFilter(filter, availableCurrencies);

    final repo = ref.read(billRepositoryProvider);
    final result = await repo.listHistoryBillsPage(
      createdAfter: createdAfter,
      limit: 25,
      sort: _sortValue(normalized.sort),
      currencyCode: normalized.currencyCode,
      paymentStatus: normalized.paymentStatus != null
          ? _statusValue(normalized.paymentStatus!)
          : null,
      cursorSortValue: cursor?.sortValue,
      cursorCreatedAt: cursor?.createdAt,
      cursorId: cursor?.id,
    );

    if (result is ResultFailure) return false;

    final data = (result as Success<HistoryBillPage>).data;
    final existingIds = state.items.map((b) => b.id).toSet();
    final newItems = data.bills
        .where((b) => !existingIds.contains(b.id))
        .toList();
    final updatedItems = append ? [...state.items, ...newItems] : newItems;
    state = state.copyWith(
      items: updatedItems,
      nextCursor: data.nextCursor,
      hasMore: data.hasMore,
    );

    if (!append) {
      await _updateSummary();
    }

    return true;
  }

  static String _sortValue(HistorySort sort) => sort.name;
  static String _statusValue(BillPaymentStatus status) => status.name;
}
