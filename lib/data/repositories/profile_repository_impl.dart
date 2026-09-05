import '../../core/error/exception_mapper.dart';
import '../../core/error/result.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/monthly_spending_insight.dart';
import '../../domain/entities/ocr_credit_status.dart';
import '../../domain/entities/transfer_bank_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  ProfileRepositoryImpl(this._ds);
  final ProfileRemoteDataSource _ds;

  @override
  Future<Result<UserProfile>> getCurrentProfile() => guardAsync(() async {
    final dto = await _ds.getCurrentProfile();
    return UserProfile(
      id: dto.id,
      displayName: dto.displayName,
      email: _ds.currentEmail,
      defaultCurrency: dto.defaultCurrency,
      languagePref: dto.languagePref,
      themePref: dto.themePref,
      isAnonymous: _ds.isAnonymous,
      marketingEmailOptIn: dto.marketingEmailOptIn,
      marketingEmailOptInAt: dto.marketingEmailOptInAt,
      marketingEmailOptInSource: dto.marketingEmailOptInSource,
      acceptedTermsAt: dto.acceptedTermsAt,
      acceptedPrivacyAt: dto.acceptedPrivacyAt,
      acceptedTermsVersion: dto.acceptedTermsVersion,
      acceptedPrivacyVersion: dto.acceptedPrivacyVersion,
      welcomedAt: dto.welcomedAt,
      onboardingCompletedAt: dto.onboardingCompletedAt,
      onboardingVersion: dto.onboardingVersion,
      isAdult: dto.isAdult,
    );
  });

  @override
  Future<Result<void>> updateDisplayName(String name) =>
      guardAsync(() => _ds.updateField('display_name', name.trim()));

  @override
  Future<Result<void>> updateDefaultCurrency(String code) =>
      guardAsync(() => _ds.updateField('default_currency', code));

  @override
  Future<Result<void>> updateLanguage(String code) =>
      guardAsync(() => _ds.updateField('language_pref', code));

  @override
  Future<Result<void>> updateOnboardingPreferences({
    required String currencyCode,
    required String languageCode,
    required String themeMode,
  }) =>
      guardAsync(
        () => _ds.updateFields({
          'default_currency': currencyCode,
          'language_pref': languageCode,
          'theme_pref': themeMode,
        }),
      );

  @override
  Future<Result<void>> updateThemePref(String mode) =>
      guardAsync(() => _ds.updateField('theme_pref', mode));

  @override
  Future<Result<void>> setMarketingEmailOptIn({
    required bool optedIn,
    required String source,
    String preferredLanguage = 'en',
  }) async {
    final now = DateTime.now().toUtc();

    // Capture the pre-call marketing state so a failed dual-write can roll back
    // to exactly what was there before — not a hardcoded `false`, which would
    // wrongly clear a user who was already opted in (e.g. a re-affirm that
    // fails at step 2). If the read fails we fall back to clearing, the old
    // behaviour, since we then cannot know the prior state.
    final prev = (await guardAsync(() => _ds.getCurrentProfile())).dataOrNull;
    final prevOptIn = prev?.marketingEmailOptIn ?? false;
    final prevOptInAt = prev?.marketingEmailOptInAt;
    final prevOptInSource = prev?.marketingEmailOptInSource;

    // Step 1: write to the per-account mirror on `profiles` (existing).
    final profileRes = await guardAsync(
      () => _ds.updateFields({
        'marketing_email_opt_in': optedIn,
        // Clear the audit columns when the user withdraws consent so the
        // marketing opt-in is unambiguously recorded as `never` again.
        // `postgrest` serialises the update body with `jsonEncode`, which
        // rejects raw `DateTime` (`Converting object to an encodable
        // object failed`). Convert to ISO 8601 string up front so the
        // same code path works for every DateTime-bearing mutation.
        'marketing_email_opt_in_at': optedIn ? now.toIso8601String() : null,
        'marketing_email_opt_in_source': optedIn ? source : null,
      }),
    );
    if (profileRes is ResultFailure<void>) return profileRes;

    // Step 2: dual-write to the unified `marketing_subscribers` table so
    // the landing page (and any future email blast tooling) sees the
    // same preference. No-op for anonymous users because they have no
    // email and cannot satisfy the RLS WITH CHECK.
    final email = _ds.currentEmail;
    if (email == null || email.isEmpty) {
      return profileRes;
    }
    final subscriberRes = await guardAsync(
      () => _ds.upsertMarketingSubscriber(
        email: email,
        optedIn: optedIn,
        source: source,
        preferredLanguage: preferredLanguage,
      ),
    );
    if (subscriberRes is ResultFailure<void>) {
      // Pseudo-transactional rollback: restore the PREVIOUS profile mirror so
      // the user-visible flag and the subscriber list never disagree — and a
      // re-affirm that fails at step 2 never clobbers an existing opt-in.
      await _ds
          .updateFields({
            'marketing_email_opt_in': prevOptIn,
            'marketing_email_opt_in_at': prevOptInAt?.toIso8601String(),
            'marketing_email_opt_in_source': prevOptInSource,
          })
          .catchError((Object e) {
            // If the rollback itself fails, `profiles` and `marketing_subscribers`
            // can diverge — log it so the divergence is at least observable. The
            // original error still bubbles up to the caller.
            AppLogger.warn(
              'marketing opt-in rollback failed; profiles/subscribers may diverge',
              e,
            );
          });
      return subscriberRes;
    }

    return profileRes;
  }

  @override
  Future<Result<void>> recordLegalAcceptance({
    required int termsVersion,
    required int privacyVersion,
  }) {
    final now = DateTime.now().toUtc();
    return guardAsync(
      () => _ds.updateFields({
        'accepted_terms_at': now.toIso8601String(),
        'accepted_privacy_at': now.toIso8601String(),
        'accepted_terms_version': termsVersion,
        'accepted_privacy_version': privacyVersion,
      }),
    );
  }

  @override
  Future<Result<void>> markWelcomed() => guardAsync(
    () => _ds.updateFields({
      'welcomed_at': DateTime.now().toUtc().toIso8601String(),
    }),
  );

  @override
  Future<Result<void>> markOnboardingCompleted({required int version}) =>
      guardAsync(
        () => _ds.updateFields({
          'onboarding_completed_at': DateTime.now().toUtc().toIso8601String(),
          'onboarding_version': version,
        }),
      );

  @override
  Future<Result<void>> setIsAdult({required bool isAdult}) =>
      guardAsync(() => _ds.updateFields({'is_adult': isAdult}));

  @override
  Future<Result<OcrCreditStatus>> getOcrCreditStatus() => guardAsync(() async {
    final row = await _ds.getOcrCreditStatus();
    return OcrCreditStatus.fromJson(row);
  });

  @override
  Future<Result<MonthlySpendingInsight>> getMonthlySpendingInsight({
    required DateTime month,
    required String currencyCode,
  }) => guardAsync(() async {
    final row = await _ds.getMonthlySpendingInsight(
      month: month,
      currencyCode: currencyCode,
    );
    return MonthlySpendingInsight.fromJson(row);
  });

  @override
  Future<Result<TransferBankInfo?>> getTransferBankInfo() => guardAsync(
    () async =>
        TransferBankInfo.fromProfileRow(await _ds.getTransferBankInfo()),
  );

  @override
  Future<Result<void>> updateTransferBankInfo(TransferBankInfo? info) =>
      guardAsync(
        () => _ds.updateTransferBankInfo(
          bankName: _emptyToNull(info?.bankName),
          accountName: _emptyToNull(info?.accountName),
          accountNumber: _emptyToNull(info?.accountNumber),
        ),
      );

  @override
  Future<Result<void>> touchLastActive() => guardAsync(_ds.touchLastActive);

  static String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
