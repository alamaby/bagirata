import '../../core/error/result.dart';
import '../entities/auth_snapshot.dart';

abstract interface class IAuthRepository {
  /// Returns the current user's id, or null if signed out.
  String? get currentUserId;

  /// True when the active session belongs to an anonymous user.
  bool get isAnonymous;

  /// True once the current user has confirmed their email. For anonymous
  /// users this is always false. The router needs this to keep a freshly
  /// registered user parked on the verify-email screen.
  bool get isEmailConfirmed;

  /// True when the active Supabase session originated from a
  /// `type=recovery` deep link (password reset email). Sourced from a
  /// persistent flag set by [DeepLinkHandler] because the underlying
  /// `AuthChangeEvent.passwordRecovery` is delivered once on the stream
  /// and is consumed before the router can read it on cold start.
  /// Cleared automatically on sign-out / delete-account / after a
  /// successful `updatePassword` call.
  bool get isPasswordRecovery;

  /// The current session user's email, or null when signed out or the
  /// session is anonymous. Used as the identity source for matching
  /// pending post-signup actions that were deferred from the register
  /// screen, since `profileProvider` may still hold stale data right
  /// after a Supabase callback swaps the session.
  String? get currentEmail;

  /// Stream of user-id transitions; null when signed out.
  Stream<String?> watchUserId();

  /// Stream of full auth state — emits on every Supabase auth event so the
  /// router can refresh its redirect logic.
  Stream<AuthSnapshot> watchAuthState();

  Future<Result<String>> signInAnonymously();

  /// Returns the current user id, signing in anonymously only if there is no
  /// session at all. Idempotent.
  Future<Result<String>> ensureSignedIn();

  /// Promotes an anonymous account to a permanent identity (email/password)
  /// without changing `auth.uid()`, so existing rows keep their owner.
  Future<Result<void>> linkEmail({
    required String email,
    required String password,
  });

  /// Sign-up flow used by the Register screen. Same uid-preserving semantics
  /// as [linkEmail] — anon data stays accessible after upgrade.
  Future<Result<void>> signUp({
    required String email,
    required String password,
  });

  /// Sign-in to an existing account. When called from an anonymous session,
  /// the impl reassigns rows owned by the old anon uid to the new uid via
  /// the `migrate_anon_data` RPC so in-progress receipts are not lost.
  Future<Result<void>> signInWithPassword({
    required String email,
    required String password,
  });

  /// Sends a passwordless email OTP. Existing users sign in; new users are
  /// created by Supabase so the flow can also upgrade guest users.
  Future<Result<void>> sendEmailOtp({
    required String email,
    required String languageCode,
  });

  /// Verifies a passwordless email OTP and migrates any rows owned by the
  /// previous anonymous uid to the verified user.
  Future<Result<void>> verifyEmailOtp({
    required String email,
    required String token,
  });

  /// Native Google Sign-In bridged into Supabase auth.
  Future<Result<void>> signInWithGoogle();

  /// Resends the verification email after [signUp] / [linkEmail].
  Future<Result<void>> resendEmailChange({required String email});

  /// Persists a Supabase email-link callback session from a deep link URL.
  Future<Result<void>> recoverSessionFromUri(Uri uri);

  Future<Result<void>> signOut();

  /// Permanently deletes the current user's app data and Auth account.
  Future<Result<void>> deleteAccount();

  /// Sends a password-reset email to [email].
  Future<Result<void>> resetPasswordForEmail(String email);

  /// Updates the current user's password. Must be invoked within an active
  /// recovery session (after consuming the `type=recovery` deep link) or as a
  /// fully signed-in user. Supabase's server-side password policy applies.
  Future<Result<void>> updatePassword(String newPassword);

  /// Clears the persistent password-recovery flag. Used by the
  /// reset-password screen when it detects the session is no longer in
  /// recovery mode (e.g. token expired) so the user is not bounced back
  /// to /reset-password on the next cold start.
  Future<void> clearPasswordRecovery();
}
