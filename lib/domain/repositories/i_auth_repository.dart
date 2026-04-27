import '../../core/error/result.dart';

abstract interface class IAuthRepository {
  /// Returns the current user's id, or null if signed out.
  String? get currentUserId;

  /// Stream of user-id transitions; null when signed out.
  Stream<String?> watchUserId();

  Future<Result<String>> signInAnonymously();

  /// Promotes an anonymous account to a permanent identity (email/OAuth)
  /// without changing `auth.uid()`, so existing rows keep their owner.
  Future<Result<void>> linkEmail({required String email, required String password});

  Future<Result<void>> signOut();
}
