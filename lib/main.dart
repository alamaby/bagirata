import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/ads/ad_service.dart';
import 'core/config/env.dart';
import 'core/format/app_format.dart';
import 'core/format/device_locale_defaults.dart';
import 'core/utils/app_logger.dart';
import 'data/providers.dart';
import 'data/services/deep_link_handler.dart';
import 'data/services/password_recovery_session.dart';
import 'l10n/generated/app_l10n.dart';
import 'l10n/generated/app_l10n_en.dart';
import 'l10n/generated/app_l10n_id.dart';

/// Entry point.
///
/// Defensive flow: every step that can hang the splash (asset load, network
/// init, anonymous sign-in) is bounded by a timeout and wrapped so failures
/// surface as a visible error screen instead of a frozen Flutter logo.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final initError = await _bootstrap();

  if (initError != null) {
    final l10n = _resolveStartupL10n();
    runApp(_StartupErrorApp(error: initError, l10n: l10n));
    return;
  }

  final recovery = await PasswordRecoverySession.create();
  // Inject the recovery session into the deep-link handler so the cold-start
  // path can stamp the persistent recovery flag before ProviderScope mounts.
  DeepLinkHandler.configure(recovery: recovery);
  runApp(
    ProviderScope(
      overrides: [passwordRecoverySessionProvider.overrideWithValue(recovery)],
      child: const BagiStrukApp(),
    ),
  );
}

AppL10n _resolveStartupL10n() {
  return Intl.defaultLocale?.toLowerCase().startsWith('id') == true
      ? AppL10nId()
      : AppL10nEn();
}

Future<String?> _bootstrap() async {
  // Initialize Intl default locale and date symbols for all locales we may
  // switch to at runtime.
  Intl.defaultLocale = AppFormat.locale;
  // Load symbols for every locale we may switch to at runtime and every
  // currency formatter locale used by CurrencyFormatter. Passing no argument
  // loads all of them in one go.
  await initializeDateFormatting();

  try {
    await dotenv.load(fileName: '.env').timeout(const Duration(seconds: 5));
  } catch (e) {
    return 'Failed to load configuration (.env): $e';
  }

  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    ).timeout(const Duration(seconds: 10));
  } catch (e) {
    return 'Failed to initialize Supabase: $e';
  }

  // Sengaja TIDAK await AdService.initialize() di sini. AdMob SDK + UMP
  // initialization bisa makan 10+ detik di emulator (HTTP ke
  // fundingchoicesmessages.google.com + verifikasi class GMS), dan
  // keseluruhan proses terjadi di platform thread / main isolate, sehingga
  // `.timeout(8s)` di Dart cuma men-trigger cancellation di sisi Dart —
  // bukan membatalkan verifikasi native yang sedang berjalan. Hasilnya
  // app launch freeze + 'Lost connection to device' di emulator.
  //
  // Ads adalah monetization opsional, jadi kita jalankan di background
  // setelah UI muncul. `AdService.initialize()` sudah idempotent
  // (early-return kalau `_initialized == true`), aman dipanggil kapan saja.
  unawaited(_initAdsBestEffort());

  // Sengaja TIDAK eager-anonymous sign-in di sini. supabase_flutter sudah
  // Eager anonymous sign-in: jika tidak ada session sama sekali (fresh
  // install, no persisted session), sign-in anonymous sekarang supaya:
  // 1. Legal acceptance gate fire di cold start, BUKAN mid-flow setelah
  //    user sudah invest effort (pilih foto, dll).
  // 2. profileProvider emit real profile (bukan placeholder empty-id)
  //    sehingga router redirect bisa evaluate legal gate correctly.
  // Guard eksplisit `currentSession == null` -- kalau ada persisted email
  // session dari launch sebelumnya, signInAnonymously() TIDAK dipanggil
  // sehingga tidak terjadi race condition yang dulu jadi gotcha di
  // CLAUDE.md. Lihat TODO_EMAIL_CONFIRMATION_SIDE_EFFECTS.md untuk
  // side effect yang dulu menulis marketing opt-in + welcome marker sebelum
  // user konfirmasi email — sudah di-refactor ke pending action lokal yang
  // dieksekusi setelah email confirmation callback).
  try {
    final auth = Supabase.instance.client.auth;

    // Deep link callback: if the app was cold-started by a Supabase
    // email confirmation / password-reset link, process the callback
    // before anonymous sign-in so the verified session takes precedence.
    await DeepLinkHandler.instance.handleInitialLink();
    // Start listening for links arriving while the app is already open.
    DeepLinkHandler.instance.listen();

    if (auth.currentSession == null) {
      await auth.signInAnonymously().timeout(const Duration(seconds: 8));
      // Fresh install: stamp device-locale defaults into the new profile row
      // so the user sees the correct language and currency from the start.
      await _initializeProfileDefaults(auth.currentUser?.id);
    }
  } catch (e, st) {
    // Sign-in failure bukan blocker -- app TETAP boot. Scan/settings akan
    // trigger lazy ensureSignedIn() di action site; legal gate fire kemudian
    // (mid-flow) -- UX kurang ideal, tapi jauh lebih baik daripada memblokir
    // seluruh app dengan layar error hanya karena network flaky / latensi auth
    // di cold start. Karena itu kita LOG lalu lanjut boot (return null), bukan
    // mengembalikan string error yang memicu _StartupErrorApp.
    AppLogger.error('Eager anonymous sign-in failed (non-blocking)', e, st);
    return null;
  }

  return null;
}

/// Stamps device-locale defaults (language, currency) onto a freshly-created
/// profile row. Fails silently — the user can always change preferences in
/// Settings, and the app works with DB defaults even if this update doesn't
/// land.
Future<void> _initializeProfileDefaults(String? userId) async {
  if (userId == null) return;
  final defaults = DeviceLocaleDefaults.fromPlatform();
  try {
    await Supabase.instance.client
        .from('profiles')
        .update({
          'language_pref': defaults.language,
          'default_currency': defaults.currency,
        })
        .eq('id', userId);
  } catch (_) {
    // Non-critical: DB defaults and client-side fallbacks handle the case
    // where the update fails.
  }
}

Future<void> _initAdsBestEffort() async {
  try {
    await AdService.initialize().timeout(const Duration(seconds: 8));
  } catch (_) {
    // Ads adalah monetization opsional; jangan gagalkan startup kalau
    // AdMob/UMP tidak ready. Jika timeout, SDK mungkin masih init di
    // background — banner pertama akan muncul saat siap, dan UMP form
    // akan di-skip (user akan melihat iklan non-personalized sampai
    // consent di-refresh dari Settings).
  }
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error, required this.l10n});

  final String error;
  final AppL10n l10n;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 56,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.appInitErrorTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(error, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 24),
                Text(
                  l10n.appInitErrorRetryHint,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
