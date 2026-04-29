import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/auth_snapshot.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);
  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  String? get currentUserId => _auth.currentUser?.id;

  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  Stream<String?> watchUserId() =>
      _auth.onAuthStateChange.map((s) => s.session?.user.id);

  Stream<AuthSnapshot> watchAuthState() =>
      _auth.onAuthStateChange.map((s) {
        final user = s.session?.user;
        return AuthSnapshot(
          userId: user?.id,
          isAnonymous: user?.isAnonymous ?? false,
        );
      });

  Future<String> signInAnonymously() async {
    final res = await _auth.signInAnonymously();
    final user = res.user;
    if (user == null) {
      throw const AuthException('Anonymous sign-in returned no user');
    }
    return user.id;
  }

  /// Promotes the current anon user. Supabase preserves `auth.uid()` when
  /// linking, so any rows owned by the anon user remain accessible after.
  Future<void> linkEmail({required String email, required String password}) async {
    await _auth.updateUser(UserAttributes(email: email, password: password));
  }

  /// Same uid-preserving upgrade as [linkEmail] — exposed under a name that
  /// matches the Register screen's intent.
  Future<void> signUp({required String email, required String password}) =>
      linkEmail(email: email, password: password);

  /// Logs into an existing account. If the previous session was anonymous,
  /// reassigns its rows to the new uid via `migrate_anon_data` RPC so the
  /// user does not lose work in progress.
  Future<void> signInWithPassword({required String email, required String password}) async {
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

  /// Resends the email-change confirmation. Used after [signUp] / [linkEmail]
  /// when the user wants another copy of the verification link.
  Future<void> resendEmailChange({required String email}) =>
      _auth.resend(type: OtpType.emailChange, email: email);

  Future<void> signOut() => _auth.signOut();
}
