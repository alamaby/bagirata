import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight SharedPreferences-backed flag that records whether the
/// currently-active Supabase session originated from a password-recovery
/// deep link (`type=recovery`).
///
/// The flag exists because `AuthChangeEvent.passwordRecovery` is delivered
/// once on the stream, but the link itself is consumed by
/// [DeepLinkHandler] in `main.dart` *before* the `ProviderScope` mounts.
/// Without a persisted marker the router has no way to know the user is
/// inside a recovery flow on cold start, and falls back to the default
/// `initialLocation` (Scan).
///
/// Lifecycle:
/// * Set by [DeepLinkHandler] when the URI contains `type=recovery` and the
///   session is recovered successfully.
/// * Read by [AuthRemoteDataSource] (and through it, [authStateProvider])
///   when seeding the initial auth snapshot.
/// * Cleared by [ResetPasswordScreen] after `updatePassword()` succeeds,
///   by [AuthRemoteDataSource.signOut] / [deleteAccount], and whenever the
///   user lands on the reset-password screen without an active recovery
///   session (token already expired).
class PasswordRecoverySession {
  PasswordRecoverySession._(this._prefs);

  static const _activeKey = 'password_recovery_active_v1';
  static const _startedAtKey = 'password_recovery_started_at_v1';
  static const _maxAge = Duration(hours: 1);

  final SharedPreferences _prefs;

  static Future<PasswordRecoverySession> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PasswordRecoverySession._(prefs);
  }

  /// True when the active Supabase session was created via a password-
  /// recovery deep link and the TTL has not yet expired. The TTL protects
  /// against a stale flag from a previous link surviving across sign-out.
  bool get isActive {
    final active = _prefs.getBool(_activeKey) ?? false;
    if (!active) return false;
    final startedAtMillis = _prefs.getInt(_startedAtKey);
    if (startedAtMillis == null) {
      // Inconsistent state: marker exists without timestamp. Treat as
      // inactive so we do not get stuck on the reset-password screen.
      return false;
    }
    final startedAt = DateTime.fromMillisecondsSinceEpoch(
      startedAtMillis,
      isUtc: true,
    );
    if (DateTime.now().toUtc().difference(startedAt) > _maxAge) {
      return false;
    }
    return true;
  }

  Future<void> markActive() async {
    await Future.wait<void>([
      _prefs.setBool(_activeKey, true),
      _prefs.setInt(
        _startedAtKey,
        DateTime.now().toUtc().millisecondsSinceEpoch,
      ),
    ]);
  }

  Future<void> clear() async {
    await Future.wait<void>([
      _prefs.remove(_activeKey),
      _prefs.remove(_startedAtKey),
    ]);
  }
}
