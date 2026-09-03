import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/app_logger.dart';
import 'ad_config.dart';

class AdService {
  const AdService._();

  static bool _initialized = false;
  static final Completer<void> _readyCompleter = Completer<void>();

  /// Completes once the UMP consent request and
  /// `MobileAds.instance.initialize()` have finished — or immediately when
  /// ads are disabled. Consumers must await this (with their own timeout)
  /// before issuing the first ad load of the process: loads issued before
  /// the SDK is ready can be dropped silently by the AdMob SDK (no
  /// `onAdLoaded`, no `onAdFailedToLoad`), which is why the cold-start scan
  /// banner never loaded for existing users (see
  /// `plans/2026-09-03-scan-banner-ad-rca-fix.md`).
  static Future<void> get ready => _readyCompleter.future;

  /// Whether [ready] has completed.
  static bool get isReady => _readyCompleter.isCompleted;

  static Future<void> initialize() async {
    if (_initialized || _readyCompleter.isCompleted) return;
    if (!AdConfig.adsEnabled) {
      _completeReady();
      return;
    }
    _initialized = true;
    final stopwatch = Stopwatch()..start();
    try {
      // In debug builds, register the test device so the AdMob SDK serves
      // test creatives. Note: in google_mobile_ads v8 there is no public
      // API to force the EEA geography — the consent form will only show
      // on devices whose actual region is regulated. No-op in release.
      if (kDebugMode) {
        await MobileAds.instance.updateRequestConfiguration(
          // Empty list lets AdMob auto-detect debug devices via the
          // `adb shell setprop debug.firebase.analytics.app` flag or by
          // the device's build flavor. Supplying a placeholder string
          // like `'TEST-DEVICE-HASH'` makes the SDK try to look it up,
          // fail, and log spurious warnings at every ad request.
          RequestConfiguration(testDeviceIds: const <String>[]),
        );
      }

      await _requestConsent();
      await MobileAds.instance.initialize();
    } catch (e, st) {
      // Best effort: a failed init must never deadlock ad consumers. The
      // GMA SDK can still self-initialize on the first ad request.
      AppLogger.warn('AdService init failed; ads proceed best-effort', e, st);
    } finally {
      stopwatch.stop();
      AppLogger.log('AdService ready in ${stopwatch.elapsedMilliseconds}ms');
      _completeReady();
    }
  }

  static void _completeReady() {
    if (!_readyCompleter.isCompleted) _readyCompleter.complete();
  }

  static Future<void> _requestConsent() async {
    final params = ConsentRequestParameters();
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        try {
          await _loadAndShowConsentFormIfRequired();
        } finally {
          if (!completer.isCompleted) completer.complete();
        }
      },
      (_) {
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
  }

  static Future<void> _loadAndShowConsentFormIfRequired() async {
    await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
  }

  /// Updates the UMP underage tag. Call this whenever `profile.isAdult`
  /// changes (e.g. after the user finishes the legal acceptance flow and
  /// checks the "I am 18+" box). When the user is a minor, UMP skips
  /// personalized ad requests and the AdMob SDK only serves contextual
  /// (non-personalized) ads.
  static Future<void> setUserIsMinor(bool isMinor) async {
    if (!AdConfig.adsEnabled) return;
    // google_mobile_ads v8 exposes the UMP TFUA enum via the
    // `TagForUnderAgeOfConsent` constants (1 = under age, 0 = not).
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForUnderAgeOfConsent: isMinor
            ? TagForUnderAgeOfConsent.yes
            : TagForUnderAgeOfConsent.no,
      ),
    );
  }

  /// Re-triggers the UMP consent form so the user can review or change
  /// their ad privacy choices from a Settings surface. No-op when ads are
  /// disabled or on unsupported platforms.
  static Future<void> showConsentFormIfAvailable() async {
    if (!AdConfig.adsEnabled) return;
    try {
      // v8 exposes the privacy options form via the static
      // `showPrivacyOptionsForm` (no separate `load` step required).
      await ConsentForm.showPrivacyOptionsForm((_) {});
    } catch (_) {
      // UMP may not have a form ready (e.g. user is in a non-regulated
      // region) — surface this gracefully so Settings callers do not
      // need a try/catch of their own.
    }
  }

  /// Returns true if the user has provided consent and ads can be
  /// requested. Call before every ad load to respect the user's consent
  /// choice. Returns false when ads are disabled, on unsupported
  /// platforms, or when consent is not yet available.
  static Future<bool> canRequestAds() async {
    if (!AdConfig.adsEnabled) return false;
    return ConsentInformation.instance.canRequestAds();
  }

  /// Returns true when a privacy options entry point is required so the
  /// user can review or change their ad privacy choices at any time.
  /// Call after `requestConsentInfoUpdate()` has completed — otherwise
  /// the status is always `unknown`.
  static Future<bool> isPrivacyOptionsRequired() async {
    if (!AdConfig.adsEnabled) return false;
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }
}
