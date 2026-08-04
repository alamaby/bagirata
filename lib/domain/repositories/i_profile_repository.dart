import '../../core/error/result.dart';
import '../entities/monthly_spending_insight.dart';
import '../entities/ocr_credit_status.dart';
import '../entities/transfer_bank_info.dart';
import '../entities/user_profile.dart';

abstract interface class IProfileRepository {
  /// Loads the current user's profile row, joined with the email + anon flag
  /// from the active Supabase session.
  Future<Result<UserProfile>> getCurrentProfile();

  Future<Result<void>> updateDisplayName(String name);

  /// [code] must be one of the supported ISO-4217 currencies.
  Future<Result<void>> updateDefaultCurrency(String code);

  /// [code] must be `id` or `en`.
  Future<Result<void>> updateLanguage(String code);

  /// Writes the onboarding default preferences in a single UPDATE so
  /// currency and language are saved or fail together.
  ///
  /// [currencyCode] must be one of the supported ISO-4217 currencies and
  /// [languageCode] must be `id` or `en`.
  Future<Result<void>> updateOnboardingPreferences({
    required String currencyCode,
    required String languageCode,
  });

  /// [mode] must be `light`, `dark`, or `system`.
  Future<Result<void>> updateThemePref(String mode);

  /// Records or withdraws the user's marketing email opt-in. [source] is
  /// stored for audit purposes and must be one of
  /// `register_form` | `settings_toggle` | `post_login_welcome` |
  /// `landing_footer` | `landing_section` | `landing_preferences` |
  /// `landing_unsubscribe` | `pre_existing_subscriber` (enforced by the
  /// `profiles_marketing_source_check` constraint on the database).
  /// When [optedIn] is `false` the timestamp and source columns are cleared.
  ///
  /// Also dual-writes the preference to the unified `marketing_subscribers`
  /// table so the landing page / future email tooling sees the same flag.
  /// [preferredLanguage] is recorded alongside the subscriber row so the
  /// landing-page preferences page can render in the right language.
  Future<Result<void>> setMarketingEmailOptIn({
    required bool optedIn,
    required String source,
    String preferredLanguage = 'en',
  });

  /// Records that the user accepted the Terms of Service and Privacy Policy
  /// at the supplied versions. The router compares these versions against
  /// `app_config` to decide whether to re-prompt on subsequent launches.
  Future<Result<void>> recordLegalAcceptance({
    required int termsVersion,
    required int privacyVersion,
  });

  /// Stamps the post-login welcome gate so the welcome screen is not shown
  /// again for the current user. Used by the email/password register flow
  /// where the marketing opt-in is collected on the register form itself.
  Future<Result<void>> markWelcomed();

  /// Stamps the onboarding completion so the onboarding wizard is bypassed.
  Future<Result<void>> markOnboardingCompleted({required int version});

  /// Records the user's declared age 18+ status. Drives the AdMob
  /// `setTagForUnderAgeOfConsent` call so minors only see non-personalized
  /// ads. Called from the legal acceptance flow after the user checks the
  /// "I am 18+" checkbox.
  Future<Result<void>> setIsAdult({required bool isAdult});

  /// Reads the current OCR credit status for the active user.
  Future<Result<OcrCreditStatus>> getOcrCreditStatus();

  /// Reads Plus-gated monthly spending insight for the active user.
  ///
  /// [month] selects the period (only the month is used; the day is ignored)
  /// and is grouped by bill saved date (`created_at`) on the database.
  Future<Result<MonthlySpendingInsight>> getMonthlySpendingInsight({
    required DateTime month,
    required String currencyCode,
  });

  /// Reads the optional bank transfer destination saved on the current profile.
  Future<Result<TransferBankInfo?>> getTransferBankInfo();

  /// Saves or clears the current profile's single bank transfer destination.
  Future<Result<void>> updateTransferBankInfo(TransferBankInfo? info);

  /// Refreshes the user's app activity timestamp. No-op when signed out.
  Future<Result<void>> touchLastActive();
}
