import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/app_logger.dart';
import 'password_recovery_session.dart';

/// Listens for incoming deep links (email confirmation, password-reset
/// callbacks) and routes them to Supabase's `getSessionFromUrl()`.
///
/// This bridges the gap when the app is cold-started by a deep link — GoRouter
/// redirect alone cannot catch the initial URI because the router tree is not
/// yet mounted when `main()` runs.
///
/// A [PasswordRecoverySession] is injected by `main()` so the handler can
/// stamp the persistent recovery flag as early as possible (before the
/// `ProviderScope` mounts). Without this, the router's redirect runs
/// against `initialLocation: /scan` and loses the recovery context.
class DeepLinkHandler {
  DeepLinkHandler._({PasswordRecoverySession? recovery})
    : _recovery = recovery;

  static DeepLinkHandler? _instance;

  /// Lazily creates the singleton. The optional [recovery] is captured on
  /// first call; later calls re-use the same instance, so passing it from
  /// `main()` after Supabase is initialized is the supported flow.
  static DeepLinkHandler get instance =>
      _instance ??= DeepLinkHandler._();

  /// One-shot setter used by `main._bootstrap()` to inject the
  /// pre-warmed [PasswordRecoverySession]. Subsequent calls are ignored.
  static void configure({PasswordRecoverySession? recovery}) {
    _instance = DeepLinkHandler._(recovery: recovery);
  }

  final _appLinks = AppLinks();
  PasswordRecoverySession? _recovery;
  StreamSubscription<Uri>? _sub;

  /// Process the initial link that cold-started the app (if any).
  Future<void> handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        await _processUri(uri);
      }
    } catch (e) {
      AppLogger.warn('DeepLinkHandler: failed to process initial link', e);
    }
  }

  /// Start listening for links arriving while the app is already running.
  void listen() {
    _sub?.cancel();
    _sub = _appLinks.uriLinkStream.listen(
      _processUri,
      onError: (Object e) => AppLogger.warn('DeepLinkHandler: stream error', e),
    );
  }

  Future<void> _processUri(Uri uri) async {
    final raw = uri.toString();
    final isSupabaseCallback =
        raw.contains('access_token=') ||
        raw.contains('refresh_token=') ||
        raw.contains('code=') ||
        raw.contains('type=signup') ||
        raw.contains('type=email_change') ||
        raw.contains('type=recovery') ||
        raw.contains('error_description=');
    if (!isSupabaseCallback) return;

    // Never log the raw URI — its query/fragment carry access_token,
    // refresh_token and the OAuth code. Log only the non-sensitive location.
    AppLogger.log(
      'DeepLinkHandler: processing auth callback: ${_redactUri(uri)}',
    );
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      if (raw.contains('type=recovery')) {
        // Mark the persistent recovery flag as early as possible so the
        // router (which boots from `initialLocation: /scan`) can pull the
        // user back to /reset-password on the first frame. The
        // `AuthChangeEvent.passwordRecovery` stream event alone is too
        // late: it fires before `ProviderScope` rebuilds and the
        // [authStateProvider] seed misses the flag.
        await _recovery?.markActive();
      }
    } catch (e) {
      AppLogger.warn('DeepLinkHandler: getSessionFromUrl failed', e);
    }
  }

  /// A log-safe rendering of a callback URI: scheme/host/path only. Drops the
  /// query and fragment, which carry auth tokens and the OAuth code.
  static String _redactUri(Uri uri) => '${uri.scheme}://${uri.host}${uri.path}';

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
