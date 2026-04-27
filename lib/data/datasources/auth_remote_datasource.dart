import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);
  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  String? get currentUserId => _auth.currentUser?.id;

  Stream<String?> watchUserId() =>
      _auth.onAuthStateChange.map((s) => s.session?.user.id);

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

  Future<void> signOut() => _auth.signOut();
}
