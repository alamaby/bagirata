import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_constants.dart';
import '../../core/config/env.dart';
import '../../domain/entities/auth_snapshot.dart';
import '../services/password_recovery_session.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client, this._recovery);
  final SupabaseClient _client;
  final PasswordRecoverySession _recovery;
  static Future<void>? _googleInitFuture;

  GoTrueClient get _auth => _client.auth;

  String? get currentUserId => _auth.currentUser?.id;

  String? get currentEmail => _auth.currentUser?.email;

  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  bool get isEmailConfirmed => _auth.currentUser?.emailConfirmedAt != null;

  /// True when the active session originated from a `type=recovery`
  /// deep link. Backed by [PasswordRecoverySession] so the value survives
  /// across cold-start: the `passwordRecovery` auth event is delivered
  /// once and consumed by `DeepLinkHandler` in `main()` before the
  /// `ProviderScope` is mounted, so the in-memory event alone is not
  /// enough for the router to gate `/reset-password`.
  bool get isPasswordRecovery => _recovery.isActive;

  Stream<String?> watchUserId() =>
      _auth.onAuthStateChange.map((s) => s.session?.user.id);

  Stream<AuthSnapshot> watchAuthState() => _auth.onAuthStateChange.asyncMap(
    (s) async {
      // Persist the recovery flag across cold-start so [authStateProvider]
      // can seed `isPasswordRecovery: true` before the stream emits.
      // Cleared automatically by the TTL or on `signedOut`.
      switch (s.event) {
        case AuthChangeEvent.passwordRecovery:
          await _recovery.markActive();
        case AuthChangeEvent.signedOut:
          await _recovery.clear();
        case AuthChangeEvent.userDeleted:
          await _recovery.clear();
        default:
          break;
      }
      final user = s.session?.user;
      return AuthSnapshot(
        userId: user?.id,
        isAnonymous: user?.isAnonymous ?? false,
        emailConfirmed: user?.emailConfirmedAt != null,
        isPasswordRecovery:
            _recovery.isActive || s.event == AuthChangeEvent.passwordRecovery,
      );
    },
  );

  Future<String> signInAnonymously() async {
    final res = await _auth.signInAnonymously();
    final user = res.user;
    if (user == null) {
      throw const AuthException('Anonymous sign-in returned no user');
    }
    return user.id;
  }

  /// Returns the current user id if a valid session exists, otherwise creates
  /// an anonymous one. Idempotent — safe to call before any auth-gated action.
  /// Checks [currentSession] rather than just [currentUser] because
  /// Supabase can retain a stale `currentUser` while `currentSession` is null
  /// (e.g. after a deep-link callback replaces the anonymous session).
  Future<String> ensureSignedIn() async {
    final session = _auth.currentSession;
    if (session?.accessToken != null && session!.accessToken.isNotEmpty) {
      final uid = _auth.currentUser?.id;
      if (uid != null) return uid;
    }
    return signInAnonymously();
  }

  /// Promotes the current anon user. Supabase preserves `auth.uid()` when
  /// linking, so any rows owned by the anon user remain accessible after.
  Future<void> linkEmail({
    required String email,
    required String password,
  }) async {
    await _validateRegistrationEmail(email);
    await _auth.updateUser(
      UserAttributes(email: email, password: password),
      emailRedirectTo: _authEmailRedirectTo,
    );
    await _recordRegisteredEmailIdentity(email);
  }

  /// Same uid-preserving upgrade as [linkEmail] — exposed under a name that
  /// matches the Register screen's intent.
  Future<void> signUp({required String email, required String password}) =>
      linkEmail(email: email, password: password);

  /// Logs into an existing account. If the previous session was anonymous,
  /// reassigns its rows to the new uid via `migrate_anon_data` RPC so the
  /// user does not lose work in progress.
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final oldUid = _auth.currentUser?.id;
    final wasAnon = _auth.currentUser?.isAnonymous ?? false;
    await _auth.signInWithPassword(email: email, password: password);
    final newUid = _auth.currentUser?.id;
    if (wasAnon && oldUid != null && newUid != null && oldUid != newUid) {
      await _client.rpc<void>(
        'migrate_anon_data',
        params: {'p_old_uid': oldUid},
      );
    }
  }

  /// Sends a passwordless email OTP via Supabase Magic Link /
  /// Confirm signup templates (`{{ .Token }}`). The language metadata is
  /// available in the template as `{{ .Data.language }}` for localized
  /// email content. `emailRedirectTo` ensures the fallback link opens the
  /// mobile app via the registered custom scheme instead of the Site URL.
  Future<void> sendEmailOtp({
    required String email,
    required String languageCode,
  }) async {
    await _auth.signInWithOtp(
      email: email,
      emailRedirectTo: _authEmailRedirectTo,
      shouldCreateUser: true,
      data: {'language': languageCode},
    );
  }

  /// Verifies the email code and preserves any guest-owned bill rows by moving
  /// them from the previous anonymous uid to the new verified uid.
  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final oldUid = _auth.currentUser?.id;
    final wasAnon = _auth.currentUser?.isAnonymous ?? false;

    await _auth.verifyOTP(email: email, token: token, type: OtpType.email);
    await _recordRegisteredEmailIdentity(email);

    final newUid = _auth.currentUser?.id;
    if (wasAnon && oldUid != null && newUid != null && oldUid != newUid) {
      await _client.rpc<void>(
        'migrate_anon_data',
        params: {'p_old_uid': oldUid},
      );
    }
  }

  /// Native Google Sign-In bridged into Supabase via the Google ID token.
  /// If the app had an anonymous session, any in-progress bills are migrated
  /// to the Google-backed Supabase user after the new session is established.
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      throw const AuthException(
        'Google sign-in web flow is not enabled in this app build',
      );
    }

    final oldUid = _auth.currentUser?.id;
    final wasAnon = _auth.currentUser?.isAnonymous ?? false;

    final GoogleSignInAccount googleUser;
    try {
      await _ensureGoogleInitialized();
      googleUser = await GoogleSignIn.instance.authenticate();
    } on StateError catch (e) {
      throw AuthException(e.message);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException(
          'Google sign-in dibatalkan atau konfigurasi OAuth Android belum cocok',
        );
      }
      final description = e.description;
      throw AuthException(
        description == null || description.isEmpty
            ? 'Google sign-in gagal: ${e.code.name}'
            : description,
      );
    }

    final idToken = googleUser.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const AuthException('Google sign-in returned no ID token');
    }

    await _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    final newUid = _auth.currentUser?.id;
    if (wasAnon && oldUid != null && newUid != null && oldUid != newUid) {
      await _client.rpc<void>(
        'migrate_anon_data',
        params: {'p_old_uid': oldUid},
      );
    }
  }

  /// Resends the email-change confirmation. Used after [signUp] / [linkEmail]
  /// when the user wants another copy of the verification link.
  Future<void> resendEmailChange({required String email}) => _auth.resend(
    type: OtpType.emailChange,
    email: email,
    emailRedirectTo: _authEmailRedirectTo,
  );

  /// Consumes a Supabase email-link callback. Idempotent for the same URI:
  /// re-invoking with a URI Supabase has already consumed is swallowed so
  /// the router redirect can safely call this twice (once on cold start
  /// before `ProviderScope` mounts, once inside the redirect). Proactively
  /// stamps [PasswordRecoverySession] when the URI is a `type=recovery`
  /// callback so the router can route the user to `/reset-password` even
  /// when the corresponding `AuthChangeEvent.passwordRecovery` has already
  /// fired before `runApp`.
  ///
  /// Error handling rules:
  /// - On success: mark recovery active for `type=recovery` URIs.
  /// - On failure:
  ///   - If URI was already consumed by DeepLinkHandler (flow_state_not_found /
  ///     already_used), treat as success ONLY if recovery flag is already
  ///     active AND a Supabase session exists. This prevents double-consume
  ///     from being treated as fresh recovery.
  ///   - If token is expired/invalid (otp_expired), clear recovery flag and
  ///     propagate failure so router routes to login with expired reason.
  ///   - Other errors are propagated.
  Future<void> recoverSessionFromUri(Uri uri) async {
    final raw = uri.toString();
    final isRecovery = raw.contains('type=recovery');
    try {
      await _auth.getSessionFromUrl(uri);
      if (isRecovery) {
        await _recovery.markActive();
      }
    } on AuthException catch (e) {
      // Distinguish between "already consumed" (safe to swallow if we already
      // have a valid recovery session) vs genuine failures like expired tokens.
      final msg = e.message.toLowerCase();

      // Genuine failures that should NOT activate recovery and should bubble
      // up so the router can show expired error.
      if (msg.contains('otp_expired') || msg.contains('invalid')) {
        if (isRecovery) await _recovery.clear();
        rethrow;
      }

      // Already consumed by DeepLinkHandler on cold start.
      // Only treat as success if we already have an active recovery flag
      // AND a current Supabase session. This prevents a stale/already-consumed
      // URI from reactivating a cleared flag.
      final alreadyConsumed =
          msg.contains('flow_state') ||
          msg.contains('already');

      if (alreadyConsumed) {
        if (isRecovery &&
            _recovery.isActive &&
            _auth.currentSession != null) {
          return;
        }
        rethrow;
      }

      // Unknown auth error - propagate.
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _signOutGoogleBestEffort();
    await _recovery.clear();
  }

  Future<void> _signOutGoogleBestEffort() async {
    if (_googleInitFuture == null) return;
    try {
      await _googleInitFuture;
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Supabase sign-out is the source of truth; local Google cleanup is best-effort.
    }
  }

  Future<void> deleteAccount() async {
    final response = await _client.functions.invoke(
      AppConstants.deleteAccountEdgeFunctionName,
    );
    if (response.status >= 400) {
      throw FunctionException(status: response.status, details: response.data);
    }
    await _auth.signOut(scope: SignOutScope.local);
    await _signOutGoogleBestEffort();
    await _recovery.clear();
  }

  /// Triggers a password reset email for [email]. The link in the email opens
  /// the Supabase recovery flow; the app's router catches `type=recovery`
  /// fragments and lands the user on a real route.
  Future<void> resetPasswordForEmail(String email) =>
      _auth.resetPasswordForEmail(email, redirectTo: _authEmailRedirectTo);

  /// Updates the current user's password. Must be invoked within an active
  /// recovery session (after consuming the `type=recovery` deep link) or as a
  /// fully signed-in user. Supabase's server-side password policy applies.
  /// Clears the persistent recovery flag on success so the user cannot
  /// navigate back into the reset-password flow after they have saved a
  /// new password.
  Future<void> updatePassword(String newPassword) async {
    await _auth.updateUser(UserAttributes(password: newPassword));
    await _recovery.clear();
  }

  /// Clears the persistent password-recovery flag. Called by the
  /// reset-password screen when the active session is no longer in
  /// recovery mode (token expired / tampered URL / navigation drift).
  Future<void> clearPasswordRecovery() => _recovery.clear();

  Future<void> _ensureGoogleInitialized() {
    return _googleInitFuture ??= GoogleSignIn.instance.initialize(
      clientId: switch (defaultTargetPlatform) {
        TargetPlatform.iOS || TargetPlatform.macOS => Env.googleIosClientId,
        _ => null,
      },
      serverClientId: Env.googleWebClientId,
    );
  }

  String get _authEmailRedirectTo => Env.authEmailRedirectTo;

  Future<void> _validateRegistrationEmail(String email) async {
    final rows = await _client.rpc<List<dynamic>>(
      'validate_registration_email',
      params: {'p_email': email},
    );
    final row = rows.isEmpty ? null : rows.first as Map<String, dynamic>;
    final allowed = row?['allowed'] == true;
    if (allowed) return;

    final reason = row?['reason']?.toString() ?? 'invalid_email';
    throw AuthException(reason);
  }

  Future<void> _recordRegisteredEmailIdentity(String email) async {
    final userId = _auth.currentUser?.id;
    if (userId == null) return;
    await _client.rpc<void>(
      'record_registered_email_identity',
      params: {'p_user_id': userId, 'p_email': email},
    );
  }
}
