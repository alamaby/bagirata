import 'dart:async';

import 'package:bagistruk/core/error/result.dart';
import 'package:bagistruk/data/providers.dart';
import 'package:bagistruk/domain/entities/app_config.dart';
import 'package:bagistruk/domain/entities/monthly_spending_insight.dart';
import 'package:bagistruk/domain/entities/ocr_credit_status.dart';
import 'package:bagistruk/domain/entities/transfer_bank_info.dart';
import 'package:bagistruk/domain/entities/user_profile.dart';
import 'package:bagistruk/domain/repositories/i_app_config_repository.dart';
import 'package:bagistruk/domain/repositories/i_profile_repository.dart';
import 'package:bagistruk/l10n/generated/app_l10n.dart';
import 'package:bagistruk/presentation/onboarding/screens/onboarding_screen.dart';
import 'package:bagistruk/presentation/settings/providers/preferences_providers.dart';
import 'package:bagistruk/presentation/settings/providers/profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake repository that returns a fixed [AppConfig] without Supabase.
class _FakeAppConfigRepository implements IAppConfigRepository {
  _FakeAppConfigRepository(this._config);

  final AppConfig _config;

  @override
  Future<Result<AppConfig>> getConfig() async =>
      Result.success(_config);

  @override
  void invalidate() {}
}

/// Fake notifier that returns a fixed [AppConfig] without hitting the DB.
class _FakeAppConfigNotifier extends AppConfigNotifier {
  _FakeAppConfigNotifier(this._config);

  final AppConfig _config;

  @override
  Future<AppConfig> build() async => _config;
}

/// Fake notifier whose build future can be controlled externally, for testing
/// the initial loading → data transition.
class _ControllableAppConfigNotifier extends AppConfigNotifier {
  _ControllableAppConfigNotifier(this._completer);

  final Completer<AppConfig> _completer;

  @override
  Future<AppConfig> build() async => _completer.future;
}

/// Fake [IProfileRepository] returning canned responses without DB.
class _FakeProfileRepository implements IProfileRepository {
  @override
  Future<Result<UserProfile>> getCurrentProfile() async =>
      Result.success(const UserProfile(
        id: 'test-user',
        defaultCurrency: 'IDR',
        languagePref: 'id',
        themePref: 'system',
        isAnonymous: false,
        onboardingCompletedAt: null,
        onboardingVersion: 1,
      ));

  @override
  Future<Result<void>> updateDisplayName(String name) async =>
      Result.success(null);

  @override
  Future<Result<void>> updateDefaultCurrency(String code) async =>
      Result.success(null);

  @override
  Future<Result<void>> updateLanguage(String code) async =>
      Result.success(null);

  @override
  Future<Result<void>> updateThemePref(String mode) async =>
      Result.success(null);

  @override
  Future<Result<void>> setMarketingEmailOptIn({
    required bool optedIn,
    required String source,
    String preferredLanguage = 'en',
  }) async =>
      Result.success(null);

  @override
  Future<Result<void>> recordLegalAcceptance({
    required int termsVersion,
    required int privacyVersion,
  }) async =>
      Result.success(null);

  @override
  Future<Result<void>> markWelcomed() async =>
      Result.success(null);

  @override
  Future<Result<void>> markOnboardingCompleted({required int version}) async =>
      Result.success(null);

  @override
  Future<Result<void>> setIsAdult({required bool isAdult}) async =>
      Result.success(null);

  @override
  Future<Result<OcrCreditStatus>> getOcrCreditStatus() async =>
      throw UnimplementedError();

  @override
  Future<Result<MonthlySpendingInsight>> getMonthlySpendingInsight({
    required DateTime month,
    required String currencyCode,
  }) async =>
      throw UnimplementedError();

  @override
  Future<Result<TransferBankInfo?>> getTransferBankInfo() async =>
      throw UnimplementedError();

  @override
  Future<Result<void>> updateTransferBankInfo(TransferBankInfo? info) async =>
      throw UnimplementedError();

  @override
  Future<Result<void>> touchLastActive() async =>
      Result.success(null);

  @override
  Future<Result<void>> updateOnboardingPreferences({
    required String currencyCode,
    required String languageCode,
  }) async =>
      Result.success(null);
}

/// Fake notifier returning a fixed [UserProfile] without hitting the DB.
class _FakeProfileNotifier extends ProfileNotifier {
  _FakeProfileNotifier(this._profile);

  final UserProfile _profile;

  @override
  Future<UserProfile> build() async => _profile;
}

String _nextLabel(WidgetTester tester) {
  final ctx = tester.element(find.byType(OnboardingScreen));
  return AppL10n.of(ctx).onboardingNext;
}

String _finishLabel(WidgetTester tester) {
  final ctx = tester.element(find.byType(OnboardingScreen));
  return AppL10n.of(ctx).onboardingFinish;
}

Widget _buildApp({
  required bool promoEnabled,
  String titleId = 'Promo ID Title',
  String titleEn = 'Promo EN Title',
  String bodyId = 'Promo ID Body',
  String bodyEn = 'Promo EN Body',
  Locale locale = const Locale('id'),
  bool isReplay = false,
}) {
  final config = AppConfig(
    termsVersion: 1,
    privacyVersion: 1,
    promoOnboardingEnabled: promoEnabled,
    promoOnboardingTitleId: titleId,
    promoOnboardingTitleEn: titleEn,
    promoOnboardingBodyId: bodyId,
    promoOnboardingBodyEn: bodyEn,
  );
  final profile = const UserProfile(
    id: 'test-user',
    defaultCurrency: 'IDR',
    languagePref: 'id',
    themePref: 'system',
    isAnonymous: false,
    onboardingCompletedAt: null,
    onboardingVersion: 1,
  );

  return ProviderScope(
    overrides: [
      appConfigProvider.overrideWith(
        () => _FakeAppConfigNotifier(config),
      ),
      appConfigRepositoryProvider.overrideWithValue(
        _FakeAppConfigRepository(config),
      ),
      localePrefProvider.overrideWithValue(locale),
      profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
      profileProvider.overrideWith(
        () => _FakeProfileNotifier(profile),
      ),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, _) =>
            OnboardingScreen(isReplay: isReplay),
      ),
    ),
  );
}

/// Helper to advance the PageView to the next slide by tapping the Next
/// button. Uses the l10n label so the test survives l10n copy changes.
Future<void> _tapNext(WidgetTester tester) async {
  await tester.tap(find.text(_nextLabel(tester)));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OnboardingScreen — promo slide visibility', () {
    testWidgets('shows 5 indicator dots when promo enabled with complete copy',
        (tester) async {
      await tester.pumpWidget(_buildApp(promoEnabled: true));
      await tester.pumpAndSettle();

      final indicator = find.byType(SmoothPageIndicator);
      expect(indicator, findsOneWidget);

      final row = tester.widget<Row>(
        find.descendant(of: indicator, matching: find.byType(Row)),
      );
      expect(row.children.length, 5);
    });

    testWidgets('shows 4 indicator dots when promo disabled', (tester) async {
      await tester.pumpWidget(_buildApp(promoEnabled: false));
      await tester.pumpAndSettle();

      final indicator = find.byType(SmoothPageIndicator);
      expect(indicator, findsOneWidget);

      final row = tester.widget<Row>(
        find.descendant(of: indicator, matching: find.byType(Row)),
      );
      expect(row.children.length, 4);
    });

    testWidgets('shows 4 dots when promo enabled but copy incomplete',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        promoEnabled: true,
        titleId: '',
        bodyId: '',
      ));
      await tester.pumpAndSettle();

      final indicator = find.byType(SmoothPageIndicator);
      expect(indicator, findsOneWidget);

      final row = tester.widget<Row>(
        find.descendant(of: indicator, matching: find.byType(Row)),
      );
      expect(row.children.length, 4);
    });

    testWidgets('promo slide shows ID title and body on final page',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        promoEnabled: true,
        titleId: 'Gratis 30 Hari!',
        bodyId: 'Nikmati Plus gratis.',
      ));
      await tester.pumpAndSettle();

      for (int i = 0; i < 4; i++) {
        await _tapNext(tester);
      }

      expect(find.text('Gratis 30 Hari!'), findsOneWidget);
      expect(find.text('Nikmati Plus gratis.'), findsOneWidget);
    });

    testWidgets('promo slide shows EN title and body with English locale',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        promoEnabled: true,
        titleEn: 'Free 30 Days!',
        bodyEn: 'Enjoy free Plus.',
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();

      for (int i = 0; i < 4; i++) {
        await _tapNext(tester);
      }

      expect(find.text('Free 30 Days!'), findsOneWidget);
      expect(find.text('Enjoy free Plus.'), findsOneWidget);
    });

    testWidgets('last slide shows Finish button with promo',
        (tester) async {
      await tester.pumpWidget(_buildApp(promoEnabled: true));
      await tester.pumpAndSettle();

      for (int i = 0; i < 4; i++) {
        await _tapNext(tester);
      }

      expect(find.text(_finishLabel(tester)), findsOneWidget);
    });

    testWidgets('last slide shows Finish button without promo',
        (tester) async {
      await tester.pumpWidget(_buildApp(promoEnabled: false));
      await tester.pumpAndSettle();

      for (int i = 0; i < 3; i++) {
        await _tapNext(tester);
      }

      expect(find.text(_finishLabel(tester)), findsOneWidget);
    });

    testWidgets('Next button advances through all slides with promo',
        (tester) async {
      await tester.pumpWidget(_buildApp(promoEnabled: true));
      await tester.pumpAndSettle();

      expect(find.text(_nextLabel(tester)), findsOneWidget);

      for (int i = 0; i < 4; i++) {
        await _tapNext(tester);
      }

      expect(find.text(_finishLabel(tester)), findsOneWidget);
      expect(find.text(_nextLabel(tester)), findsNothing);
    });

    testWidgets('Skip button hidden in replay mode even with promo',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        promoEnabled: true,
        isReplay: true,
      ));
      await tester.pumpAndSettle();

      final l10n = AppL10n.of(tester.element(find.byType(OnboardingScreen)));
      expect(find.text(l10n.onboardingSkip), findsNothing);
    });

    testWidgets('promo slide renders image asset', (tester) async {
      await tester.pumpWidget(_buildApp(promoEnabled: true));
      await tester.pumpAndSettle();

      for (int i = 0; i < 4; i++) {
        await _tapNext(tester);
      }

      expect(find.byType(Image), findsAtLeastNWidgets(1));
    });

    testWidgets('transitions from 4 to 5 dots when config loads late',
        (tester) async {
      final completer = Completer<AppConfig>();

      // Pre-build the config so the fake repo can return it after refresh.
      final lateConfig = AppConfig(
        termsVersion: 1,
        privacyVersion: 1,
        promoOnboardingEnabled: true,
        promoOnboardingTitleId: 'Title',
        promoOnboardingTitleEn: 'Title',
        promoOnboardingBodyId: 'Body',
        promoOnboardingBodyEn: 'Body',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWith(
              () => _ControllableAppConfigNotifier(completer),
            ),
            appConfigRepositoryProvider.overrideWithValue(
              _FakeAppConfigRepository(lateConfig),
            ),
            localePrefProvider.overrideWithValue(const Locale('id')),
            profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
            profileProvider.overrideWith(
              () => _FakeProfileNotifier(const UserProfile(
                id: 'test-user',
                defaultCurrency: 'IDR',
                languagePref: 'id',
                themePref: 'system',
                isAnonymous: false,
                onboardingCompletedAt: null,
                onboardingVersion: 1,
              )),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('id'),
            localizationsDelegates: AppL10n.localizationsDelegates,
            supportedLocales: AppL10n.supportedLocales,
            home: ScreenUtilInit(
              designSize: const Size(393, 852),
              child: const OnboardingScreen(),
            ),
          ),
        ),
      );

      // Initially 4 dots while config is loading (fallback = disabled)
      var indicator = find.byType(SmoothPageIndicator);
      var row = tester.widget<Row>(
        find.descendant(of: indicator, matching: find.byType(Row)),
      );
      expect(row.children.length, 4);

      // Resolve config with promo enabled
      completer.complete(lateConfig);
      await tester.pumpAndSettle();

      // Now 5 dots
      indicator = find.byType(SmoothPageIndicator);
      row = tester.widget<Row>(
        find.descendant(of: indicator, matching: find.byType(Row)),
      );
      expect(row.children.length, 5);
    });
  });

  group('OnboardingScreen — preference slide', () {
    testWidgets('preference slide is first and shows language and currency',
        (tester) async {
      await tester.pumpWidget(_buildApp(promoEnabled: false));
      await tester.pumpAndSettle();

      expect(find.text('Atur preferensi'), findsOneWidget);
      expect(find.text('Bahasa aplikasi'), findsOneWidget);
      expect(find.text('Mata uang default'), findsOneWidget);
      expect(find.text('Keduanya bisa diubah nanti di Pengaturan.'),
          findsOneWidget);
    });

    testWidgets('language picker opens and changes locale',
        (tester) async {
      await tester.pumpWidget(_buildApp(promoEnabled: false));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bahasa aplikasi'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(find.text('Set your preferences'), findsOneWidget);
      expect(find.text('App language'), findsOneWidget);
    });

testWidgets('currency tile is present and tappable',
        (tester) async {
      await tester.pumpWidget(_buildApp(promoEnabled: false));
      await tester.pumpAndSettle();

      // Ensure the currency tile is present
      expect(find.text('Mata uang default'), findsOneWidget);

      // Tap the currency tile (should not throw)
      final currencyTileFinder = find.ancestor(
        of: find.text('Mata uang default').last,
        matching: find.byType(ListTile),
      );
      await tester.ensureVisible(currencyTileFinder);
      await tester.pumpAndSettle();
      await tester.tap(currencyTileFinder);
      await tester.pumpAndSettle();

      // If we reach here, the tap did not throw an error.
    });

    testWidgets('Skip button shows the preference slide default',
        (tester) async {
      await tester.pumpWidget(_buildApp(promoEnabled: false));
      await tester.pumpAndSettle();

      // The top-right skip ("Lewati") is present during first run, even on
      // the new preference slide.
      expect(find.text('Lewati'), findsOneWidget);
    });
  });
}
