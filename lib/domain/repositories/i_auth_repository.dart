import '../../core/error/result.dart';
import '../entities/auth_snapshot.dart';

abstract interface class IAuthRepository {
  /// Returns the current user's id, or null if signed out.
  String? get currentUserId;

  /// True when the active session belongs to an anonymous user.
  bool get isAnonymous;

  /// Stream of user-id transitions; null when signed out.
  Stream<String?> watchUserId();

  /// Stream of full auth state — emits on every Supabase auth event so the
  /// router can refresh its redirect logic.
  Stream<AuthSnapshot> watchAuthState();

  Future<Result<String>> signInAnonymously();

  /// Promotes an anonymous account to a permanent identity (email/password)
  /// without changing `auth.uid()`, so existing rows keep their owner.
  Future<Result<void>> linkEmail({required String email, required String password});

  /// Sign-up flow used by the Register screen. Same uid-preserving semantics
  /// as [linkEmail] — anon data stays accessible after upgrade.
  Future<Result<void>> signUp({required String email, required String password});

  /// Sign-in to an existing account. When called from an anonymous session,
  /// the impl reassigns rows owned by the old anon uid to the new uid via
  /// the `migrate_anon_data` RPC so in-progress receipts are not lost.
  Future<Result<void>> signInWithPassword({required String email, required String password});

  /// UI placeholder. Real OAuth flow is out of scope for this iteration.
  Future<Result<void>> signInWithGoogle();

  Future<Result<void>> signOut();
}
