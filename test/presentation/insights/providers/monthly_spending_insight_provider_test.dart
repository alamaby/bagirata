import 'package:bagistruk/core/error/failure.dart';
import 'package:bagistruk/core/error/result.dart';
import 'package:bagistruk/data/providers.dart';
import 'package:bagistruk/domain/entities/auth_snapshot.dart';
import 'package:bagistruk/domain/entities/monthly_spending_insight.dart';
import 'package:bagistruk/domain/entities/ocr_credit_status.dart';
import 'package:bagistruk/domain/entities/transfer_bank_info.dart';
import 'package:bagistruk/domain/entities/user_profile.dart';
import 'package:bagistruk/domain/repositories/i_profile_repository.dart';
import 'package:bagistruk/presentation/auth/providers/auth_providers.dart';
import 'package:bagistruk/presentation/credits/providers/ocr_credit_status_provider.dart';
import 'package:bagistruk/presentation/insights/providers/monthly_spending_insight_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProfileRepository implements IProfileRepository {
  int insightCalls = 0;
  DateTime? lastMonth;
  String? lastCurrency;
  MonthlySpendingInsight? result;

  @override
  Future<Result<MonthlySpendingInsight>> getMonthlySpendingInsight({
    required DateTime month,
    required String currencyCode,
  }) async {
    insightCalls++;
    lastMonth = month;
    lastCurrency = currencyCode;
    return Result.success(
      result ??
          MonthlySpendingInsight(
            planCode: 'plus',
            isPlus: true,
            monthStart: DateTime(month.year, month.month),
            totalAmount: 100,
            billCount: 2,
            averageBillAmount: 50,
            previousMonthTotal: 0,
            monthOverMonthPercent: null,
            outstandingAmount: 30,
            topMerchants: const [],
            monthlyTrend: const [],
          ),
    );
  }

  @override
  Future<Result<UserProfile>> getCurrentProfile() async =>
      Result.failure(Failure.unknown('unused', null));

  @override
  Future<Result<void>> updateDisplayName(String name) async =>
      const Result.success(null);

  @override
  Future<Result<void>> updateDefaultCurrency(String code) async =>
      const Result.success(null);

  @override
  Future<Result<void>> updateLanguage(String code) async =>
      const Result.success(null);

  @override
  Future<Result<void>> updateThemePref(String mode) async =>
      const Result.success(null);

  @override
  Future<Result<void>> setMarketingEmailOptIn({
    required bool optedIn,
    required String source,
    String preferredLanguage = 'en',
  }) async => const Result.success(null);

  @override
  Future<Result<void>> recordLegalAcceptance({
    required int termsVersion,
    required int privacyVersion,
  }) async => const Result.success(null);

  @override
  Future<Result<void>> markWelcomed() async => const Result.success(null);

  @override
  Future<Result<void>> markOnboardingCompleted({required int version}) async =>
      const Result.success(null);

  @override
  Future<Result<void>> setIsAdult({required bool isAdult}) async =>
      const Result.success(null);

  @override
  Future<Result<OcrCreditStatus>> getOcrCreditStatus() async =>
      Result.failure(Failure.unknown('unused', null));

  @override
  Future<Result<TransferBankInfo?>> getTransferBankInfo() async =>
      const Result.success(null);

  @override
  Future<Result<void>> updateTransferBankInfo(TransferBankInfo? info) async =>
      const Result.success(null);

  @override
  Future<Result<void>> touchLastActive() async => const Result.success(null);

  @override
  Future<Result<void>> updateOnboardingPreferences({
    required String currencyCode,
    required String languageCode,
    required String themeMode,
  }) async =>
      const Result.success(null);
}

const _plusStatus = OcrCreditStatus(
  planCode: 'plus',
  balance: 10,
  monthlyAllowance: 50,
  adsEnabled: false,
  plusFeaturesEnabled: true,
);

const _freeStatus = OcrCreditStatus(
  planCode: 'free',
  balance: 5,
  monthlyAllowance: 10,
  adsEnabled: true,
  plusFeaturesEnabled: false,
);

void main() {
  late ProviderContainer container;
  late _FakeProfileRepository fakeRepo;

  setUp(() {
    fakeRepo = _FakeProfileRepository();
    container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (ref) async* {
            yield const AuthSnapshot(
              userId: 'user-1',
              isAnonymous: false,
              emailConfirmed: true,
            );
          },
        ),
        profileRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<void> settle() async {
    for (var i = 0; i < 50; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  test('plus sends normalized month and currency to the repository', () async {
    container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (ref) async* {
            yield const AuthSnapshot(
              userId: 'user-1',
              isAnonymous: false,
              emailConfirmed: true,
            );
          },
        ),
        ocrCreditStatusProvider.overrideWith(
          (ref) async => _plusStatus,
        ),
        profileRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );

    final sub = container.listen(
      monthlySpendingInsightProvider(
        (month: DateTime(2026, 8, 15), currencyCode: 'IDR'),
      ),
      (_, _) {},
    );
    addTearDown(sub.close);
    await settle();

    expect(fakeRepo.insightCalls, greaterThanOrEqualTo(1));
    expect(fakeRepo.lastMonth, DateTime(2026, 8));
    expect(fakeRepo.lastCurrency, 'IDR');
    expect(sub.read(), isA<AsyncData<MonthlySpendingInsight?>>());
    expect(sub.read().value?.totalAmount, 100);
  });

  test('free user returns null without calling the repository', () async {
    container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (ref) async* {
            yield const AuthSnapshot(
              userId: 'user-1',
              isAnonymous: false,
              emailConfirmed: true,
            );
          },
        ),
        ocrCreditStatusProvider.overrideWith((ref) async => _freeStatus),
        profileRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );

    final sub = container.listen(
      monthlySpendingInsightProvider(
        (month: DateTime(2026, 8), currencyCode: 'USD'),
      ),
      (_, _) {},
    );
    addTearDown(sub.close);
    await settle();

    expect(fakeRepo.insightCalls, 0);
    expect(sub.read().value, isNull);
  });

  test('each month/currency combination is cached separately', () async {
    container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (ref) async* {
            yield const AuthSnapshot(
              userId: 'user-1',
              isAnonymous: false,
              emailConfirmed: true,
            );
          },
        ),
        ocrCreditStatusProvider.overrideWith((ref) async => _plusStatus),
        profileRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );

    final augIdr = container.listen(
      monthlySpendingInsightProvider(
        (month: DateTime(2026, 8), currencyCode: 'IDR'),
      ),
      (_, _) {},
    );
    final julUsd = container.listen(
      monthlySpendingInsightProvider(
        (month: DateTime(2026, 7), currencyCode: 'USD'),
      ),
      (_, _) {},
    );
    addTearDown(augIdr.close);
    addTearDown(julUsd.close);
    await settle();

    expect(fakeRepo.insightCalls, greaterThanOrEqualTo(2));
    expect(fakeRepo.lastMonth, DateTime(2026, 7));
    expect(fakeRepo.lastCurrency, 'USD');
  });
}
