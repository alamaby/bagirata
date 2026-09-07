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
  DeepLinkHandler._(this._recovery);
  final PasswordRecoverySession _recovery;

  static DeepLinkHandler? _instance;

  /// Lazily creates the singleton. The [recovery] session is captured on
  /// first call; later calls re-use the same instance.
  static DeepLinkHandler get instance =>
      _instance ??= DeepLinkHandler._(_BootstrapOnlyRecovery());

  /// One-shot setter used by `main()` to inject the
  /// pre-warmed [PasswordRecoverySession]. Must be called before any
  /// link processing.
  static void configure(PasswordRecoverySession recovery) {
    _instance = DeepLinkHandler._(recovery);
  }

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  /// Token from the most recent `bagistruk://share/<token>` link that the
  /// router has not consumed yet. Kept outside the widget tree because the
  /// handler runs before `ProviderScope` mounts on cold start.
  static String? _pendingShareToken;

  /// Extracts the share token from a `bagistruk://share/<token>` URI, or
  /// null for anything else. Pure — unit-tested.
  static String? parseShareToken(Uri uri) {
    if (uri.scheme != 'bagistruk' || uri.host != 'share') return null;
    if (uri.pathSegments.isEmpty) return null;
    final token = uri.pathSegments.first.trim();
    return token.isEmpty ? null : token;
  }

  /// Takes the pending share token, if any. One-shot: the router redirect
  /// consumes it when routing to `/share/:token`.
  static String? consumeShareToken() {
    final token = _pendingShareToken;
    _pendingShareToken = null;
    return token;
  }

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
    // Public share-links (M2/F5) never touch Supabase auth: stash the token
    // for the router redirect and stop. The token itself is never logged.
    final shareToken = parseShareToken(uri);
    if (shareToken != null) {
      _pendingShareToken = shareToken;
      AppLogger.log('DeepLinkHandler: share link received');
      return;
    }
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
        await _recovery.markActive();
      }
    } catch (e) {
      // On failure, clear any partial recovery flag to avoid stale state.
      if (raw.contains('type=recovery')) {
        await _recovery.clear();
      }
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

/// Stand-in recovery session used only if [configure] is never called.
/// Prevents NPE during tests or edge-case bootstrap.
class _BootstrapOnlyRecovery implements PasswordRecoverySession {
  PasswordRecoverySession? _inner;

  _BootstrapOnlyRecovery();

  Future<PasswordRecoverySession> _delegate() async {
    return _inner ??= await PasswordRecoverySession.create();
  }

  @override
  bool get isActive {
    final inner = _inner;
    if (inner != null) return inner.isActive;
    return false;
  }

  @override
  Future<void> markActive() async {
    final inner = await _delegate();
    await inner.markActive();
  }

  @override
  Future<void> clear() async {
    final inner = await _delegate();
    await inner.clear();
  }
}
