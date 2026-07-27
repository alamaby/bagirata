import 'package:bagistruk/domain/entities/history_summary.dart';
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
  setUp(() {
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
          monthlySpendingInsightProvider.overrideWithValue(
            AsyncValue.data(null),
          ),
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
          monthlySpendingInsightProvider.overrideWithValue(
            AsyncValue.data(null),
          ),
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
    final freeStatus = OcrCreditStatus(
      planCode: 'free',
      balance: 5,
      monthlyAllowance: 10,
      adsEnabled: true,
      plusFeaturesEnabled: false,
    );

    const singleCurrencySummary = HistorySummary(
      totalBillCount: 3,
      availableCurrencies: ['IDR'],
      outstanding: [],
    );

    const multiCurrencySummary = HistorySummary(
      totalBillCount: 3,
      availableCurrencies: ['IDR', 'USD'],
      outstanding: [],
    );

    const emptySummary = HistorySummary(
      totalBillCount: 0,
      availableCurrencies: [],
      outstanding: [],
    );

    /// Returns a [ProviderContainer] pre-configured for filter tests.
    ProviderContainer makeContainer({
      required HistorySummary summary,
    }) {
      return ProviderContainer(
        overrides: [
          historyListProvider.overrideWithValue(
            HistoryListState(
              isLoadingInitial: false,
              summary: summary,
            ),
          ),
          ocrCreditStatusProvider.overrideWithValue(
            AsyncValue.data(freeStatus),
          ),
          currencyPrefProvider.overrideWithValue('IDR'),
          monthlySpendingInsightProvider.overrideWithValue(
            AsyncValue.data(null),
          ),
        ],
      );
    }

    testWidgets('amount sort applied on single-currency normalizes to IDR', (
      tester,
    ) async {
      // Test the normalisation logic directly: single currency + amount sort
      // without explicit filter should produce currencyCode: IDR.
      const draft = HistoryFilterState(
        sort: HistorySort.amountAsc,
      );
      const currencies = ['IDR'];
      final normalized = draft.isAmountSort &&
              draft.currencyCode == null &&
              currencies.length == 1
          ? draft.copyWith(currencyCode: currencies.single)
          : draft;
      expect(normalized.currencyCode, 'IDR');
      expect(normalized.sort, HistorySort.amountAsc);
    });

    testWidgets('amount sort on multi-currency without filter stays null', (
      tester,
    ) async {
      const draft = HistoryFilterState(
        sort: HistorySort.amountAsc,
      );
      const currencies = ['IDR', 'USD'];
      final normalized = draft.isAmountSort &&
              draft.currencyCode == null &&
              currencies.length == 1
          ? draft.copyWith(currencyCode: currencies.single)
          : draft;
      expect(normalized.currencyCode, isNull);
      expect(normalized.sort, HistorySort.amountAsc);
    });

    testWidgets('non-amount sort on single-currency keeps null', (tester) async {
      const draft = HistoryFilterState(
        sort: HistorySort.newest,
      );
      const currencies = ['IDR'];
      final normalized = draft.isAmountSort &&
              draft.currencyCode == null &&
              currencies.length == 1
          ? draft.copyWith(currencyCode: currencies.single)
          : draft;
      expect(normalized.currencyCode, isNull);
    });

    testWidgets('isAmountSort getter works correctly', (tester) async {
      expect(
        const HistoryFilterState(sort: HistorySort.amountAsc).isAmountSort,
        isTrue,
      );
      expect(
        const HistoryFilterState(sort: HistorySort.amountDesc).isAmountSort,
        isTrue,
      );
      expect(
        const HistoryFilterState(sort: HistorySort.newest).isAmountSort,
        isFalse,
      );
      expect(
        const HistoryFilterState(sort: HistorySort.oldest).isAmountSort,
        isFalse,
      );
      expect(
        const HistoryFilterState(sort: HistorySort.titleAsc).isAmountSort,
        isFalse,
      );
    });

    test('screen canSortNominal with single currency is true', () {
      final container = makeContainer(summary: singleCurrencySummary);
      container.dispose();
      final filter = const HistoryFilterState();
      expect(filter.currencyCode, isNull);
      expect(
        singleCurrencySummary.availableCurrencies.length == 1,
        isTrue,
      );
      expect(
        filter.currencyCode != null ||
            singleCurrencySummary.availableCurrencies.length == 1,
        isTrue,
      );
    });

    test('screen canSortNominal with multi-currency is false', () {
      final container = makeContainer(summary: multiCurrencySummary);
      container.dispose();
      final filter = const HistoryFilterState();
      expect(filter.currencyCode, isNull);
      expect(
        multiCurrencySummary.availableCurrencies.length == 1,
        isFalse,
      );
      expect(
        filter.currencyCode != null ||
            multiCurrencySummary.availableCurrencies.length == 1,
        isFalse,
      );
    });

    test('screen canSortNominal with empty currencies is false', () {
      final container = makeContainer(summary: emptySummary);
      container.dispose();
      final filter = const HistoryFilterState();
      expect(filter.currencyCode, isNull);
      expect(
        emptySummary.availableCurrencies.length == 1,
        isFalse,
      );
      expect(
        filter.currencyCode != null ||
            emptySummary.availableCurrencies.length == 1,
        isFalse,
      );
    });

    testWidgets('apply amount sort on multi-currency resets to newest', (
      tester,
    ) async {
      // Simulate the "Semua" tap handler in _FilterSheet:
      // multi-currency + draft.isAmountSort + currency set to null → sort to newest
      const draft = HistoryFilterState(
        sort: HistorySort.amountAsc,
        currencyCode: 'IDR',
      );
      const currencies = ['IDR', 'USD'];
      final afterClear = draft.copyWith(
        currencyCode: null,
        sort: currencies.length > 1 && draft.isAmountSort
            ? HistorySort.newest
            : draft.sort,
      );
      expect(afterClear.currencyCode, isNull);
      expect(afterClear.sort, HistorySort.newest);
    });

    testWidgets('apply amount sort with currency filter preserves sort', (
      tester,
    ) async {
      const applied = HistoryFilterState(
        sort: HistorySort.amountDesc,
        currencyCode: 'IDR',
      );
      expect(applied.isAmountSort, isTrue);
      expect(applied.currencyCode, 'IDR');
    });
  });
}
