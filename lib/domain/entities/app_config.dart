/// Runtime app configuration sourced from the `app_config` table. Currently
/// carries legal document version numbers and promo feature flags; designed
/// to be extended with feature flags or remote-toggleable settings without a
/// code release.
class AppConfig {
  const AppConfig({
    required this.termsVersion,
    required this.privacyVersion,
    this.promoOnboardingEnabled = false,
    this.promoOnboardingTitleId = '',
    this.promoOnboardingTitleEn = '',
    this.promoOnboardingBodyId = '',
    this.promoOnboardingBodyEn = '',
  });

  /// Conservative fallback used when the `app_config` table cannot be read
  /// (network error, RLS denial, missing rows). Version `1` matches the
  /// initial seed so a fresh install sees a working gate even offline.
  static const AppConfig fallback = AppConfig(
    termsVersion: 1,
    privacyVersion: 1,
  );

  final int termsVersion;
  final int privacyVersion;

  /// Whether the 4th onboarding promo slide should be shown.
  final bool promoOnboardingEnabled;

  /// Promo title in Bahasa Indonesia.
  final String promoOnboardingTitleId;

  /// Promo title in English.
  final String promoOnboardingTitleEn;

  /// Promo body in Bahasa Indonesia.
  final String promoOnboardingBodyId;

  /// Promo body in English.
  final String promoOnboardingBodyEn;

  /// True when all promo copy fields are non-empty in both languages.
  /// The UI should also check this before showing the 4th slide, so an
  /// incomplete config (e.g. missing title or body) does not render a blank
  /// slide even when [promoOnboardingEnabled] is true.
  bool get hasCompletePromoOnboardingCopy =>
      promoOnboardingTitleId.isNotEmpty &&
      promoOnboardingTitleEn.isNotEmpty &&
      promoOnboardingBodyId.isNotEmpty &&
      promoOnboardingBodyEn.isNotEmpty;

  /// Parses the rows returned by `select key, value from app_config`. Unknown
  /// keys fall back to `1`; malformed values fall back to `1`. The app does
  /// not crash on a missing or misconfigured config row. Promo fields default
  /// to empty strings / `false` when the promo key is absent. Malformed JSON
  /// values (wrong type, null inside object, etc.) also degrade gracefully
  /// instead of throwing.
  factory AppConfig.fromRows(List<Map<String, dynamic>> rows) {
    int parse(String key) {
      final match = rows
          .where((r) => r['key'] == key)
          .map((r) => r['value'])
          .firstOrNull;
      if (match is num) return match.toInt();
      if (match is String) return int.tryParse(match) ?? 1;
      return 1;
    }

    dynamic promoValue(String key) {
      return rows
          .where((r) => r['key'] == key)
          .map((r) => r['value'])
          .firstOrNull;
    }

    bool parseBool(dynamic value) => value == true;

    String parseString(dynamic value) => value is String ? value.trim() : '';

    final promo = promoValue('promo.onboarding_plus_trial');

    bool promoEnabled = false;
    String promoTitleId = '';
    String promoTitleEn = '';
    String promoBodyId = '';
    String promoBodyEn = '';

    if (promo is Map) {
      promoEnabled = parseBool(promo['enabled']);
      promoTitleId = parseString(promo['title_id']);
      promoTitleEn = parseString(promo['title_en']);
      promoBodyId = parseString(promo['body_id']);
      promoBodyEn = parseString(promo['body_en']);
    }

    return AppConfig(
      termsVersion: parse('legal.terms_version'),
      privacyVersion: parse('legal.privacy_version'),
      promoOnboardingEnabled: promoEnabled,
      promoOnboardingTitleId: promoTitleId,
      promoOnboardingTitleEn: promoTitleEn,
      promoOnboardingBodyId: promoBodyId,
      promoOnboardingBodyEn: promoBodyEn,
    );
  }

  AppConfig copyWith({
    int? termsVersion,
    int? privacyVersion,
    bool? promoOnboardingEnabled,
    String? promoOnboardingTitleId,
    String? promoOnboardingTitleEn,
    String? promoOnboardingBodyId,
    String? promoOnboardingBodyEn,
  }) =>
      AppConfig(
        termsVersion: termsVersion ?? this.termsVersion,
        privacyVersion: privacyVersion ?? this.privacyVersion,
        promoOnboardingEnabled:
            promoOnboardingEnabled ?? this.promoOnboardingEnabled,
        promoOnboardingTitleId:
            promoOnboardingTitleId ?? this.promoOnboardingTitleId,
        promoOnboardingTitleEn:
            promoOnboardingTitleEn ?? this.promoOnboardingTitleEn,
        promoOnboardingBodyId:
            promoOnboardingBodyId ?? this.promoOnboardingBodyId,
        promoOnboardingBodyEn:
            promoOnboardingBodyEn ?? this.promoOnboardingBodyEn,
      );
}
