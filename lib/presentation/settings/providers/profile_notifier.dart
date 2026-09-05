import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/ads/ad_service.dart';
import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/providers.dart';
import '../../../domain/entities/user_profile.dart';
import '../../auth/providers/auth_providers.dart';

part 'profile_notifier.g.dart';

/// Loads and exposes the current user's profile (with email + anon flag merged
/// in from the active session). All preference mutations go through this
/// notifier so the UI updates instantly via `state = AsyncData(...)` and the
/// row is persisted in the background.
@Riverpod(keepAlive: true)
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<UserProfile> build() async {
    // Rebuild whenever the active session changes (anon ↔ email, sign-out,
    // etc.) so the profile mirrors the current user.
    ref.watch(authStateProvider);
    final auth = ref.watch(authRepositoryProvider);
    final uid = auth.currentUserId;
    if (uid == null) {
      // No session yet — return a default placeholder so locale / theme /
      // currency providers can read sensible defaults instead of throwing.
      // This is a synthetic profile, intentionally not persisted; the notifier
      // re-runs the moment a real session appears.
      return const UserProfile(id: '', isAnonymous: true);
    }
    final repo = ref.watch(profileRepositoryProvider);
    final result = await repo.getCurrentProfile();
    return switch (result) {
      Success(:final data) => data,
      ResultFailure(:final failure) => throw _FailureException(failure),
    };
  }

  Future<Result<void>> updateDisplayName(String name) async {
    final res = await ref
        .read(profileRepositoryProvider)
        .updateDisplayName(name);
    if (res is Success<void>) {
      _patch((p) => p.copyWith(displayName: name.trim()));
    }
    return res;
  }

  Future<Result<void>> updateCurrency(String code) async {
    final res = await ref
        .read(profileRepositoryProvider)
        .updateDefaultCurrency(code);
    if (res is Success<void>) {
      _patch((p) => p.copyWith(defaultCurrency: code));
    }
    return res;
  }

  Future<Result<void>> updateLanguage(String code) async {
    final res = await ref.read(profileRepositoryProvider).updateLanguage(code);
    if (res is Success<void>) {
      _patch((p) => p.copyWith(languagePref: code));
    }
    return res;
  }

  /// Saves the currency, language, and theme chosen during onboarding in
  /// one atomic call and patches the local profile only on success, so
  /// `currencyPrefProvider`, `localePrefProvider`, and `themeModePrefProvider`
  /// update together.
  Future<Result<void>> updateOnboardingPreferences({
    required String currencyCode,
    required String languageCode,
    required String themeMode,
  }) async {
    final res = await ref
        .read(profileRepositoryProvider)
        .updateOnboardingPreferences(
          currencyCode: currencyCode,
          languageCode: languageCode,
          themeMode: themeMode,
        );
    if (res is Success<void>) {
      _patch(
        (p) => p.copyWith(
          defaultCurrency: currencyCode,
          languagePref: languageCode,
          themePref: themeMode,
        ),
      );
    }
    return res;
  }

  Future<Result<void>> updateTheme(String mode) async {
    final res = await ref.read(profileRepositoryProvider).updateThemePref(mode);
    if (res is Success<void>) {
      _patch((p) => p.copyWith(themePref: mode));
    }
    return res;
  }

  /// Records the user's acceptance of the current Terms of Service and
  /// Privacy Policy. The notifier pulls the current versions from
  /// `appConfigProvider` so the call site does not have to know the version
  /// numbers; the router compares the stamped versions to decide whether
  /// to re-prompt on future launches.
  Future<Result<void>> recordLegalAcceptance() async {
    // Defensive guard: the router only renders the legal screen when
    // `profile.id.isNotEmpty`, which requires `auth.currentUserId != null`,
    // but the session can drop between screen mount and submit (e.g. anon
    // session expired, or user cleared app data mid-flow). Surface this as
    // an explicit Failure instead of letting the datasource throw a bare
    // AuthException that the screen shows as a generic "save failed".
    if (ref.read(authRepositoryProvider).currentUserId == null) {
      AppLogger.error(
        'recordLegalAcceptance: no active session (auth.currentUserId null)',
      );
      return Result.failure(
        const Failure.auth('No active session. Please restart the app.'),
      );
    }
    final cfg = await ref.read(appConfigProvider.future);
    final res = await ref
        .read(profileRepositoryProvider)
        .recordLegalAcceptance(
          termsVersion: cfg.termsVersion,
          privacyVersion: cfg.privacyVersion,
        );
    if (res is Success<void>) {
      final now = DateTime.now().toUtc();
      _patch(
        (p) => p.copyWith(
          acceptedTermsAt: now,
          acceptedPrivacyAt: now,
          acceptedTermsVersion: cfg.termsVersion,
          acceptedPrivacyVersion: cfg.privacyVersion,
        ),
      );
    }
    return res;
  }

  /// Records or withdraws the marketing email opt-in. [source] is recorded
  /// for audit and must be one of
  /// `register_form` | `settings_toggle` | `post_login_welcome` (mirrors
  /// the `profiles_marketing_source_check` DB constraint). Withdrawing
  /// (optedIn=false) clears the timestamp and source columns.
  Future<Result<void>> updateMarketingOptIn({
    required bool optedIn,
    required String source,
    String? preferredLanguage,
  }) async {
    // Defensive guard: right after `signUp()` (which is `linkEmail`),
    // `_auth.updateUser` can emit a transient state where the session
    // has been swapped but `currentUser` has not been re-read yet, so
    // `_ds.updateFields` would throw AuthException. Same reasoning as
    // `recordLegalAcceptance` -- return an explicit Failure so the
    // caller can decide whether to retry or surface to the user.
    if (ref.read(authRepositoryProvider).currentUserId == null) {
      AppLogger.error(
        'updateMarketingOptIn: no active session (auth.currentUserId null)',
      );
      return Result.failure(
        const Failure.auth('No active session. Please restart the app.'),
      );
    }
    final res = await ref
        .read(profileRepositoryProvider)
        .setMarketingEmailOptIn(
          optedIn: optedIn,
          source: source,
          preferredLanguage:
              preferredLanguage ?? state.value?.languagePref ?? 'en',
        );
    if (res is Success<void>) {
      final now = DateTime.now().toUtc();
      _patch(
        (p) => p.copyWith(
          marketingEmailOptIn: optedIn,
          marketingEmailOptInAt: optedIn ? now : null,
          marketingEmailOptInSource: optedIn ? source : null,
        ),
      );
    }
    return res;
  }

  /// Records the user's declared age 18+ status. Also propagates the
  /// change to AdService so the UMP underage tag is updated synchronously
  /// with the profile patch — banner ads reload with the new consent
  /// signal on the next refresh.
  Future<Result<void>> setIsAdult({required bool isAdult}) async {
    final res = await ref
        .read(profileRepositoryProvider)
        .setIsAdult(isAdult: isAdult);
    if (res is Success<void>) {
      _patch((p) => p.copyWith(isAdult: isAdult));
      // Fire-and-forget: AdService is best-effort and the user has
      // already committed to the new value in DB. Failures are silent
      // because ads will still respect the new tag on next app launch
      // when AdService.initialize() runs again.
      unawaited(AdService.setUserIsMinor(!isAdult));
    }
    return res;
  }

  /// Stamps the post-login welcome marker so the post-login welcome gate
  /// is bypassed on subsequent app launches. The router reads
  /// `profile.welcomedAt` to decide whether to redirect non-anonymous
  /// users to [PostLoginWelcomeScreen].
  Future<Result<void>> markWelcomed() async {
    // Defensive guard: same reasoning as `recordLegalAcceptance` and
    // `updateMarketingOptIn` -- on transient auth state during sign-up
    // `currentUserId` can be momentarily null. Returning explicit
    // Failure lets the screen surface a clear error instead of letting
    // the welcome gate keep firing on every app launch.
    if (ref.read(authRepositoryProvider).currentUserId == null) {
      AppLogger.error(
        'markWelcomed: no active session (auth.currentUserId null)',
      );
      return Result.failure(
        const Failure.auth('No active session. Please restart the app.'),
      );
    }
    final res = await ref.read(profileRepositoryProvider).markWelcomed();
    if (res is Success<void>) {
      _patch((p) => p.copyWith(welcomedAt: DateTime.now().toUtc()));
    }
    return res;
  }

  void _patch(UserProfile Function(UserProfile) update) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(update(current));
  }
}

class _FailureException implements Exception {
  _FailureException(this.failure);
  final Failure failure;
  @override
  String toString() => failure.toString();
}
