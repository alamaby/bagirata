import 'package:bagistruk/core/error/failure.dart';
import 'package:bagistruk/core/error/result.dart';
import 'package:bagistruk/data/providers.dart';
import 'package:bagistruk/domain/entities/assignment.dart';
import 'package:bagistruk/domain/entities/bill.dart';
import 'package:bagistruk/domain/entities/bill_payment_status.dart';
import 'package:bagistruk/domain/entities/deleted_bill.dart';
import 'package:bagistruk/domain/entities/history_bill.dart';
import 'package:bagistruk/domain/entities/history_bill_page.dart';
import 'package:bagistruk/domain/entities/history_cursor.dart';
import 'package:bagistruk/domain/entities/history_summary.dart';
import 'package:bagistruk/domain/entities/item.dart';
import 'package:bagistruk/domain/entities/ocr_credit_status.dart';
import 'package:bagistruk/domain/entities/participant.dart';
import 'package:bagistruk/domain/repositories/i_bill_repository.dart';
import 'package:bagistruk/presentation/credits/providers/ocr_credit_status_provider.dart';
import 'package:bagistruk/presentation/history/providers/history_filter_notifier.dart';
import 'package:bagistruk/presentation/history/providers/history_filter_state.dart';
import 'package:bagistruk/presentation/history/providers/history_list_notifier.dart';
import 'package:bagistruk/presentation/insights/providers/monthly_spending_insight_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records every `listHistoryBillsPage` call and returns a configurable page.
class FakeBillRepository implements IBillRepository {
  final List<ListHistoryCall> calls = [];
  HistoryBillPage Function(ListHistoryCall call)? responder;

  /// When non-null, `getHistorySummary` returns this result.
  HistorySummary? summary;

  /// Recorded `getHistorySummary` invocations.
  int summaryCalls = 0;

  @override
  Future<Result<HistoryBillPage>> listHistoryBillsPage({
    required DateTime createdAfter,
    required int limit,
    required String sort,
    String? currencyCode,
    String? paymentStatus,
    String? cursorSortValue,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final call = ListHistoryCall(
      createdAfter: createdAfter,
      limit: limit,
      sort: sort,
      currencyCode: currencyCode,
      paymentStatus: paymentStatus,
      cursorSortValue: cursorSortValue,
      cursorCreatedAt: cursorCreatedAt,
      cursorId: cursorId,
    );
    calls.add(call);
    final responder = this.responder;
    if (responder == null) {
      return const Result.success(
        HistoryBillPage(bills: [], hasMore: false),
      );
    }
    return Result.success(responder(call));
  }

  @override
  Future<Result<HistorySummary>> getHistorySummary({
    required DateTime createdAfter,
  }) async {
    summaryCalls++;
    final s = summary;
    if (s == null) {
      return const Result.success(
        HistorySummary(
          totalBillCount: 0,
          availableCurrencies: [],
          outstanding: [],
        ),
      );
    }
    return Result.success(s);
  }

  @override
  Future<Result<List<Bill>>> listBills({DateTime? createdAfter}) async =>
      const Result.success([]);

  @override
  Future<Result<Bill>> getBill(String id) async =>
      Result.failure(Failure.unknown('not used', null));

  @override
  Future<Result<Bill>> createBill(Bill bill) async =>
      Result.failure(Failure.unknown('not used', null));

  @override
  Future<Result<Bill>> updateBill(Bill bill) async =>
      Result.failure(Failure.unknown('not used', null));

  @override
  Future<Result<void>> deleteBill(String id) async =>
      const Result.success(null);

  @override
  Future<Result<void>> restoreDeletedBill(String id) async =>
      const Result.success(null);

  @override
  Future<Result<List<DeletedBill>>> listDeletedBills() async =>
      const Result.success([]);

  @override
  Future<Result<List<Item>>> listItems(String billId) async =>
      const Result.success([]);

  @override
  Future<Result<List<Item>>> upsertItems(List<Item> items) async =>
      const Result.success([]);

  @override
  Future<Result<List<Participant>>> listParticipants(String billId) async =>
      const Result.success([]);

  @override
  Future<Result<Participant>> upsertParticipant(Participant participant) async =>
      Result.failure(Failure.unknown('not used', null));

  @override
  Future<Result<void>> deleteParticipant(String participantId) async =>
      const Result.success(null);

  @override
  Future<Result<List<Assignment>>> listAssignments(String billId) async =>
      const Result.success([]);

  @override
  Future<Result<List<Assignment>>> replaceAssignments(
    String billId,
    List<Assignment> assignments,
  ) async =>
      const Result.success([]);

  @override
  Future<Result<void>> ensureSignedIn() async => const Result.success(null);
}

class ListHistoryCall {
  ListHistoryCall({
    required this.createdAfter,
    required this.limit,
    required this.sort,
    this.currencyCode,
    this.paymentStatus,
    this.cursorSortValue,
    this.cursorCreatedAt,
    this.cursorId,
  });

  final DateTime createdAfter;
  final int limit;
  final String sort;
  final String? currencyCode;
  final String? paymentStatus;
  final String? cursorSortValue;
  final DateTime? cursorCreatedAt;
  final String? cursorId;
}

HistoryBill _bill({
  required String id,
  required String currency,
  required double amount,
  required DateTime createdAt,
  int participantCount = 1,
  int paid = 0,
}) =>
    HistoryBill(
      id: id,
      title: 'Bill $id',
      totalAmount: amount,
      currencyCode: currency,
      participantCount: participantCount,
      paidParticipantCount: paid,
      paymentStatus: paid == participantCount
          ? BillPaymentStatus.settled
          : paid > 0
              ? BillPaymentStatus.partial
              : BillPaymentStatus.unpaid,
      createdAt: createdAt,
    );

const _plusStatus = OcrCreditStatus(
  planCode: 'plus',
  balance: 10,
  monthlyAllowance: 50,
  adsEnabled: false,
  plusFeaturesEnabled: true,
);

void main() {
  late ProviderContainer container;
  late FakeBillRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeBillRepository();
    container = ProviderContainer(
      overrides: [
        billRepositoryProvider.overrideWithValue(fakeRepo),
        ocrCreditStatusProvider.overrideWithValue(
          const AsyncValue.data(_plusStatus),
        ),
        monthlySpendingInsightProvider.overrideWithValue(
          const AsyncValue.data(null),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  /// Waits until the notifier's async work settles by pumping microtasks
  /// and running the event loop. The build method of `HistoryListNotifier`
  /// re-runs whenever the filter provider emits, and `_loadFirstPage()` is
  /// fire-and-forget, so several event-loop iterations are required before
  /// the repository call is observed.
  Future<void> settleFirstPage() async {
    for (var i = 0; i < 100; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  group('HistoryListNotifier normalization', () {
    test('amountAsc on single-currency sends amountAsc + IDR', () async {
      fakeRepo.summary = const HistorySummary(
        totalBillCount: 3,
        availableCurrencies: ['IDR'],
        outstanding: [],
      );

      // Use a long-lived listen to keep the autoDispose provider alive.
      final sub = container.listen<HistoryListState>(
        historyListProvider,
        (_, next) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      // Let initial build run.
      await settleFirstPage();
      fakeRepo.calls.clear();

      // Now change the filter.
      container
          .read(historyFilterProvider.notifier)
          .apply(const HistoryFilterState(sort: HistorySort.amountAsc));

      await settleFirstPage();

      // Find the call made after filter change (last one).
      final callAfterApply = fakeRepo.calls.last;
      expect(callAfterApply.sort, 'amountAsc');
      expect(callAfterApply.currencyCode, 'IDR');
    });

    test('amountDesc with explicit currency sends that currency', () async {
      fakeRepo.summary = const HistorySummary(
        totalBillCount: 3,
        availableCurrencies: ['IDR', 'USD'],
        outstanding: [],
      );
      final sub = container.listen(historyListProvider, (_, _) {});
      addTearDown(sub.close);
      await settleFirstPage();
      fakeRepo.calls.clear();

      container.read(historyFilterProvider.notifier).apply(
            const HistoryFilterState(
              sort: HistorySort.amountDesc,
              currencyCode: 'USD',
            ),
          );

      await settleFirstPage();

      expect(fakeRepo.calls.length, 1);
      final call = fakeRepo.calls.first;
      expect(call.sort, 'amountDesc');
      expect(call.currencyCode, 'USD');
    });

    test('multi-currency amount sort without currency falls back to newest', () async {
      fakeRepo.summary = const HistorySummary(
        totalBillCount: 3,
        availableCurrencies: ['IDR', 'USD'],
        outstanding: [],
      );
      final sub = container.listen(historyListProvider, (_, _) {});
      addTearDown(sub.close);
      await settleFirstPage();
      fakeRepo.calls.clear();

      container
          .read(historyFilterProvider.notifier)
          .apply(const HistoryFilterState(sort: HistorySort.amountAsc));

      await settleFirstPage();

      expect(fakeRepo.calls.length, 1);
      final call = fakeRepo.calls.first;
      expect(call.sort, 'newest');
      expect(call.currencyCode, isNull);
    });

    test('empty currencies amount sort falls back to newest', () async {
      fakeRepo.summary = const HistorySummary(
        totalBillCount: 0,
        availableCurrencies: [],
        outstanding: [],
      );
      final sub = container.listen(historyListProvider, (_, _) {});
      addTearDown(sub.close);
      await settleFirstPage();
      fakeRepo.calls.clear();

      container
          .read(historyFilterProvider.notifier)
          .apply(const HistoryFilterState(sort: HistorySort.amountDesc));

      await settleFirstPage();

      expect(fakeRepo.calls.length, 1);
      expect(fakeRepo.calls.first.sort, 'newest');
      expect(fakeRepo.calls.first.currencyCode, isNull);
    });

    test(
      'amount sort + null currency never reaches repository as amount sort',
      () async {
        fakeRepo.summary = const HistorySummary(
          totalBillCount: 3,
          availableCurrencies: ['IDR', 'USD'],
          outstanding: [],
        );
        final sub = container.listen(historyListProvider, (_, _) {});
        addTearDown(sub.close);
        await settleFirstPage();

        container
            .read(historyFilterProvider.notifier)
            .apply(const HistoryFilterState(sort: HistorySort.amountAsc));

        await settleFirstPage();

        for (final call in fakeRepo.calls) {
          if (call.sort == 'amountAsc' || call.sort == 'amountDesc') {
            expect(call.currencyCode, isNotNull);
          }
        }
      },
    );
  });

  group('HistoryListNotifier pagination', () {
    test('loadMore preserves sort and currency from first page', () async {
      fakeRepo.summary = const HistorySummary(
        totalBillCount: 50,
        availableCurrencies: ['IDR'],
        outstanding: [],
      );
      final t0 = DateTime.utc(2026, 7, 1);
      fakeRepo.responder = (call) {
        if (call.cursorId == null) {
          return HistoryBillPage(
            bills: List.generate(
              25,
              (i) => _bill(
                id: 'b$i',
                currency: 'IDR',
                amount: 1000 + i.toDouble(),
                createdAt: t0.add(Duration(hours: i)),
              ),
            ),
            hasMore: true,
            nextCursor: _cursorFor('b24', t0.add(const Duration(hours: 24)), 'amount'),
          );
        }
        return const HistoryBillPage(bills: [], hasMore: false);
      };

      final sub = container.listen(historyListProvider, (_, _) {});
      addTearDown(sub.close);
      await settleFirstPage();

      container
          .read(historyFilterProvider.notifier)
          .apply(const HistoryFilterState(sort: HistorySort.amountAsc));
      await settleFirstPage();

      fakeRepo.calls.clear();
      await container.read(historyListProvider.notifier).loadMore();
      await settleFirstPage();

      expect(fakeRepo.calls.length, 1);
      final call = fakeRepo.calls.first;
      expect(call.sort, 'amountAsc');
      expect(call.currencyCode, 'IDR');
      expect(call.cursorId, isNotNull);
      expect(call.cursorSortValue, 'amount');
      expect(call.cursorCreatedAt, t0.add(const Duration(hours: 24)));
    });

    test('filter change after first page triggers new first-page request', () async {
      fakeRepo.summary = const HistorySummary(
        totalBillCount: 10,
        availableCurrencies: ['IDR'],
        outstanding: [],
      );
      fakeRepo.responder = (call) {
        return HistoryBillPage(
          bills: [
            _bill(
              id: 'b${call.cursorId ?? 'first'}',
              currency: 'IDR',
              amount: 5000,
              createdAt: DateTime.utc(2026, 7, 1),
            ),
          ],
          hasMore: false,
        );
      };

      final sub = container.listen(historyListProvider, (_, _) {});
      addTearDown(sub.close);
      await settleFirstPage();
      fakeRepo.calls.clear();

      container
          .read(historyFilterProvider.notifier)
          .apply(const HistoryFilterState(sort: HistorySort.oldest));
      await settleFirstPage();

      expect(fakeRepo.calls.length, 1);
      expect(fakeRepo.calls.first.cursorId, isNull);
      expect(fakeRepo.calls.first.sort, 'oldest');
    });
  });
}

HistoryCursor _cursorFor(String id, DateTime createdAt, String sortValue) =>
    HistoryCursor(sortValue: sortValue, createdAt: createdAt, id: id);
