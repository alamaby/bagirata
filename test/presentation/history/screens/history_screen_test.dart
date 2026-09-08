import 'package:bagistruk/domain/entities/bill_payment_status.dart';
import 'package:bagistruk/domain/entities/history_summary.dart';
import 'package:bagistruk/domain/entities/monthly_spending_insight.dart';
import 'package:bagistruk/domain/entities/ocr_credit_status.dart';
import 'package:bagistruk/l10n/generated/app_l10n.dart';
import 'package:bagistruk/presentation/credits/providers/ocr_credit_status_provider.dart';
import 'package:bagistruk/presentation/history/providers/history_filter_notifier.dart';
import 'package:bagistruk/presentation/history/providers/history_filter_state.dart';
import 'package:bagistruk/presentation/history/providers/history_list_notifier.dart';
import 'package:bagistruk/presentation/history/screens/history_screen.dart';
import 'package:bagistruk/presentation/insights/providers/monthly_spending_insight_provider.dart';
import 'package:bagistruk/presentation/settings/providers/preferences_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _emptyHistoryState = HistoryListState(isLoadingInitial: false);

final _historyListOverride = historyListProvider.overrideWithValue(
  _emptyHistoryState,
);

const _nonEmptySummary = HistorySummary(
  totalBillCount: 3,
  availableCurrencies: ['IDR'],
  outstanding: <OutstandingByCurrency>[],
);

final _nonEmptyHistoryState = HistoryListState(
  isLoadingInitial: false,
  summary: _nonEmptySummary,
);

void main() {
  setUp(() async {
    await initializeDateFormatting();
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad(
      mergeWith: {
        'ADS_ENABLED': 'false',
        'ADMOB_ANDROID_BANNER_HISTORY_ID': 'test',
        'SUPABASE_URL': 'http://test',
        'SUPABASE_ANON_KEY': 'test',
        'GOOGLE_WEB_CLIENT_ID': 'test',
      },
    );
  });

  group('HistoryScreen banner', () {
    ProviderContainer containerOf(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(HistoryScreen)));

    Widget buildApp({
      required OcrCreditStatus? creditStatus,
      Locale locale = const Locale('id'),
      HistoryListState? listState,
    }) {
      return ProviderScope(
        overrides: [
          listState != null
              ? historyListProvider.overrideWithValue(listState)
              : _historyListOverride,
          ocrCreditStatusProvider.overrideWithValue(
            AsyncValue.data(creditStatus),
          ),
          currencyPrefProvider.overrideWithValue('IDR'),
          monthlySpendingInsightProvider.overrideWith((ref, query) async => null),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: ScreenUtilInit(
            designSize: const Size(393, 852),
            child: const HistoryScreen(),
          ),
        ),
      );
    }

    final plusStatus = OcrCreditStatus(
      planCode: 'plus',
      balance: 10,
      monthlyAllowance: 50,
      adsEnabled: false,
      plusFeaturesEnabled: true,
    );
    final freeStatus = OcrCreditStatus(
      planCode: 'free',
      balance: 5,
      monthlyAllowance: 10,
      adsEnabled: true,
      plusFeaturesEnabled: false,
    );
    final anonymousStatus = OcrCreditStatus(
      planCode: 'anonymous',
      balance: 0,
      monthlyAllowance: 0,
      adsEnabled: true,
      plusFeaturesEnabled: false,
    );

    testWidgets('search field is always visible', (tester) async {
      await tester.pumpWidget(
        buildApp(creditStatus: freeStatus, listState: _nonEmptyHistoryState),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('search clear and submit flush immediately', (tester) async {
      await tester.pumpWidget(
        buildApp(creditStatus: freeStatus, listState: _nonEmptyHistoryState),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'kopi');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        containerOf(tester).read(historyFilterProvider).effectiveQuery,
        'kopi',
      );

      // Submit flushes without waiting for the debounce window.
      await tester.enterText(find.byType(TextField), 'teh');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        containerOf(tester).read(historyFilterProvider).effectiveQuery,
        'teh',
      );

      // Clear icon resets the query.
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        containerOf(tester).read(historyFilterProvider).effectiveQuery,
        isNull,
      );
    });

    testWidgets('Plus sees banner with close button when not dismissed', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(creditStatus: plusStatus, listState: _nonEmptyHistoryState),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Riwayat Plus'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('Plus banner renders immediately before provider resolves', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        buildApp(creditStatus: plusStatus, listState: _nonEmptyHistoryState),
      );
      await tester.pump();

      expect(find.text('Riwayat Plus'), findsOneWidget);
    });

    testWidgets('Plus tap close hides banner', (tester) async {
      await tester.pumpWidget(
        buildApp(creditStatus: plusStatus, listState: _nonEmptyHistoryState),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Riwayat Plus'), findsNothing);
    });

    testWidgets('Plus banner hidden when persisted dismissed', (tester) async {
      SharedPreferences.setMockInitialValues({
        'history_plus_banner_dismissed_v1': true,
      });
      await tester.pumpWidget(
        buildApp(creditStatus: plusStatus, listState: _nonEmptyHistoryState),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Riwayat Plus'), findsNothing);
    });

    testWidgets(
      'Free sees compact combined banner with chevron and Plus pill',
      (tester) async {
        await tester.pumpWidget(
          buildApp(creditStatus: freeStatus, listState: _nonEmptyHistoryState),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Riwayat 30 hari · Insight bulanan'), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
        expect(find.byIcon(Icons.close), findsNothing);
        expect(find.text('Riwayat Free'), findsNothing);
        expect(find.text('Insight bulanan'), findsNothing);
      },
    );

    testWidgets('Free combined banner still visible with persisted dismiss', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'history_plus_banner_dismissed_v1': true,
      });
      await tester.pumpWidget(
        buildApp(creditStatus: freeStatus, listState: _nonEmptyHistoryState),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Riwayat 30 hari · Insight bulanan'), findsOneWidget);
    });

    testWidgets('Free tap combined banner opens detail sheet', (tester) async {
      await tester.pumpWidget(
        buildApp(creditStatus: freeStatus, listState: _nonEmptyHistoryState),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Riwayat 30 hari · Insight bulanan'));
      await tester.pumpAndSettle();

      expect(find.text('Fitur History Plus'), findsOneWidget);
      expect(find.text('Riwayat lebih panjang'), findsOneWidget);
      expect(find.text('Insight bulanan'), findsOneWidget);
      expect(
        find.text(
          'Free menampilkan 30 hari terakhir. '
          'Plus menampilkan hingga 365 hari.',
        ),
        findsOneWidget,
      );
      expect(find.text('Nanti'), findsOneWidget);
    });

    testWidgets('Anonymous keeps locked banner and no combined banner', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(creditStatus: anonymousStatus));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Riwayat terkunci'), findsOneWidget);
      expect(find.text('Riwayat 30 hari · Insight bulanan'), findsNothing);
    });
  });

  group('HistoryScreen banner English locale', () {
    Widget buildApp({
      required OcrCreditStatus? creditStatus,
      HistoryListState? listState,
    }) {
      return ProviderScope(
        overrides: [
          listState != null
              ? historyListProvider.overrideWithValue(listState)
              : _historyListOverride,
          ocrCreditStatusProvider.overrideWithValue(
            AsyncValue.data(creditStatus),
          ),
          currencyPrefProvider.overrideWithValue('USD'),
          monthlySpendingInsightProvider.overrideWith((ref, query) async => null),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: ScreenUtilInit(
            designSize: const Size(393, 852),
            child: const HistoryScreen(),
          ),
        ),
      );
    }

    final plusStatus = OcrCreditStatus(
      planCode: 'plus',
      balance: 10,
      monthlyAllowance: 50,
      adsEnabled: false,
      plusFeaturesEnabled: true,
    );
    final freeStatus = OcrCreditStatus(
      planCode: 'free',
      balance: 5,
      monthlyAllowance: 10,
      adsEnabled: true,
      plusFeaturesEnabled: false,
    );

    testWidgets('Plus shows Plus history banner and close button', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(creditStatus: plusStatus, listState: _nonEmptyHistoryState),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Plus history'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('Free shows compact combined banner in English', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(creditStatus: freeStatus, listState: _nonEmptyHistoryState),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('30-day history · Monthly insight'), findsOneWidget);
      expect(find.text('Free history'), findsNothing);
    });

    testWidgets('Free banner persists in English with persisted dismiss', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'history_plus_banner_dismissed_v1': true,
      });
      await tester.pumpWidget(
        buildApp(creditStatus: freeStatus, listState: _nonEmptyHistoryState),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('30-day history · Monthly insight'), findsOneWidget);
    });

    testWidgets('Free tap combined banner opens English sheet', (tester) async {
      await tester.pumpWidget(
        buildApp(creditStatus: freeStatus, listState: _nonEmptyHistoryState),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('30-day history · Monthly insight'));
      await tester.pumpAndSettle();

      expect(find.text('Plus history features'), findsOneWidget);
      expect(find.text('Longer history'), findsOneWidget);
      expect(find.text('Monthly insight'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
    });
  });

  group('HistoryScreen filter normalization', () {
    test('single currency normalizes amount sort to that currency', () {
      const filter = HistoryFilterState(sort: HistorySort.amountAsc);
      const currencies = ['IDR'];
      final normalized = normalizeHistoryFilter(filter, currencies);
      expect(normalized.currencyCode, 'IDR');
      expect(normalized.sort, HistorySort.amountAsc);
    });

    test('multi-currency with amount sort and null currency falls back to newest', () {
      const filter = HistoryFilterState(sort: HistorySort.amountAsc);
      const currencies = ['IDR', 'USD'];
      final normalized = normalizeHistoryFilter(filter, currencies);
      expect(normalized.currencyCode, isNull);
      expect(normalized.sort, HistorySort.newest);
    });

    test('empty currencies with amount sort falls back to newest', () {
      const filter = HistoryFilterState(sort: HistorySort.amountDesc);
      const currencies = <String>[];
      final normalized = normalizeHistoryFilter(filter, currencies);
      expect(normalized.currencyCode, isNull);
      expect(normalized.sort, HistorySort.newest);
    });

    test('non-amount sort keeps filter unchanged', () {
      const filter = HistoryFilterState(sort: HistorySort.newest);
      const currencies = ['IDR'];
      final normalized = normalizeHistoryFilter(filter, currencies);
      expect(normalized.currencyCode, isNull);
      expect(normalized.sort, HistorySort.newest);
    });

    test('amount sort with explicit currency keeps that currency', () {
      const filter = HistoryFilterState(
        sort: HistorySort.amountDesc,
        currencyCode: 'USD',
      );
      const currencies = ['IDR', 'USD'];
      final normalized = normalizeHistoryFilter(filter, currencies);
      expect(normalized.currencyCode, 'USD');
      expect(normalized.sort, HistorySort.amountDesc);
    });

    test('removing currency from multi-currency amount sort falls back to newest', () {
      const filter = HistoryFilterState(
        sort: HistorySort.amountAsc,
        currencyCode: 'IDR',
      );
      const currencies = ['IDR', 'USD'];
      final afterRemove =
          normalizeHistoryFilter(filter.copyWith(currencyCode: null), currencies);
      expect(afterRemove.currencyCode, isNull);
      expect(afterRemove.sort, HistorySort.newest);
    });

    test('removing currency from single-currency amount sort keeps that currency', () {
      const filter = HistoryFilterState(
        sort: HistorySort.amountAsc,
        currencyCode: 'IDR',
      );
      const currencies = ['IDR'];
      final afterRemove =
          normalizeHistoryFilter(filter.copyWith(currencyCode: null), currencies);
      expect(afterRemove.currencyCode, 'IDR');
      expect(afterRemove.sort, HistorySort.amountAsc);
    });

    test('payment status preserved through normalization', () {
      const filter = HistoryFilterState(
        sort: HistorySort.amountAsc,
        paymentStatus: BillPaymentStatus.unpaid,
      );
      const currencies = ['IDR'];
      final normalized = normalizeHistoryFilter(filter, currencies);
      expect(normalized.paymentStatus, BillPaymentStatus.unpaid);
      expect(normalized.currencyCode, 'IDR');
    });
  });

  group('HistoryScreen summary carousel', () {
    Widget buildAppWithInsight({
      required HistoryListState listState,
      required MonthlySpendingInsight? insight,
    }) {
      return ProviderScope(
        overrides: [
          historyListProvider.overrideWithValue(listState),
          ocrCreditStatusProvider.overrideWithValue(
            const AsyncValue.data(
              OcrCreditStatus(
                planCode: 'plus',
                balance: 10,
                monthlyAllowance: 50,
                adsEnabled: false,
                plusFeaturesEnabled: true,
              ),
            ),
          ),
          currencyPrefProvider.overrideWithValue('IDR'),
          monthlySpendingInsightProvider.overrideWith(
            (ref, query) async => insight,
          ),
        ],
        child: MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: ScreenUtilInit(
            designSize: const Size(393, 852),
            child: const HistoryScreen(),
          ),
        ),
      );
    }

    const multiSummary = HistorySummary(
      totalBillCount: 3,
      availableCurrencies: ['IDR', 'USD'],
      outstanding: [
        OutstandingByCurrency(currency: 'IDR', amount: 80001),
        OutstandingByCurrency(currency: 'USD', amount: 156000),
      ],
    );

    final multiState = HistoryListState(
      isLoadingInitial: false,
      summary: multiSummary,
    );

    testWidgets('shows one outstanding currency per page and swipes', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildAppWithInsight(listState: multiState, insight: null),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('80.001'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.textContaining('156,000'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('auto-rotates between currencies', (tester) async {
      await tester.pumpWidget(
        buildAppWithInsight(listState: multiState, insight: null),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('80.001'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.textContaining('156,000'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('single currency renders without a carousel', (tester) async {
      final state = HistoryListState(
        isLoadingInitial: false,
        summary: const HistorySummary(
          totalBillCount: 3,
          availableCurrencies: ['IDR'],
          outstanding: [
            OutstandingByCurrency(currency: 'IDR', amount: 80001),
          ],
        ),
      );
      await tester.pumpWidget(
        buildAppWithInsight(listState: state, insight: null),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('80.001'), findsOneWidget);
      expect(find.byType(PageView), findsNothing);

      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.textContaining('80.001'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('empty outstanding shows zero without a carousel', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildAppWithInsight(listState: _nonEmptyHistoryState, insight: null),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Rp'), findsAtLeastNWidgets(1));
      expect(find.byType(PageView), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

  group('HistoryScreen monthly insight controls', () {
    final plusStatus = OcrCreditStatus(
      planCode: 'plus',
      balance: 10,
      monthlyAllowance: 50,
      adsEnabled: false,
      plusFeaturesEnabled: true,
    );

    final insight = MonthlySpendingInsight(
      planCode: 'plus',
      isPlus: true,
      monthStart: DateTime(2026, 8),
      totalAmount: 99914,
      billCount: 2,
      averageBillAmount: 49957,
      previousMonthTotal: 0,
      monthOverMonthPercent: null,
      outstandingAmount: 80001,
      topMerchants: const [],
      monthlyTrend: const [],
      byCategory: const [],
    );

    Widget buildApp(MonthlySpendingInsight data) {
      return ProviderScope(
        overrides: [
          historyListProvider.overrideWithValue(_nonEmptyHistoryState),
          ocrCreditStatusProvider.overrideWithValue(AsyncValue.data(plusStatus)),
          currencyPrefProvider.overrideWithValue('IDR'),
          monthlySpendingInsightProvider.overrideWith(
            (ref, query) async => data,
          ),
        ],
        child: MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: ScreenUtilInit(
            designSize: const Size(393, 852),
            child: const HistoryScreen(),
          ),
        ),
      );
    }

    testWidgets('previous month navigates; next is disabled at current month', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(insight));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The screen initializes `_selectedInsightMonth` from `DateTime.now()`.
      // Assert the header matches that dynamic month (immune to calendar
      // rollover) plus navigation state, rather than a hard-coded label.
      final now = DateTime(DateTime.now().year, DateTime.now().month);
      expect(find.text('Pengeluaran ${formatMonthLabel(now)}'), findsOneWidget);

      final nextButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(nextButton.onPressed, isNull);

      final beforeTexts = find
          .byType(Text)
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .toSet();

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final prevMonth = DateTime(now.year, now.month - 1, 1);
      expect(find.text('Pengeluaran ${formatMonthLabel(prevMonth)}'),
          findsOneWidget);

      final afterTexts = find
          .byType(Text)
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .toSet();
      expect(beforeTexts, isNot(equals(afterTexts)));

      final nextAfterBack = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.chevron_right),
      );
      expect(nextAfterBack.onPressed, isNotNull);

       await tester.pumpWidget(const SizedBox.shrink());
     });
  });
}

String formatMonthLabel(DateTime m) {
  const idMonths = <int, String>{
    1: 'Januari',
    2: 'Februari',
    3: 'Maret',
    4: 'April',
    5: 'Mei',
    6: 'Juni',
    7: 'Juli',
    8: 'Agustus',
    9: 'September',
    10: 'Oktober',
    11: 'November',
    12: 'Desember',
  };
  return '${idMonths[m.month]} ${m.year}';
}
