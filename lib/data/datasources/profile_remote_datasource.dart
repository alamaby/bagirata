import 'package:supabase_flutter/supabase_flutter.dart';

import '../dtos/profile_dto.dart';

/// Thin PostgREST wrapper for the `profiles` table. Errors bubble to the
/// repository layer where [guardAsync] translates them into [Failure]s.
class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._client);
  final SupabaseClient _client;

  static const _table = 'profiles';

  String? get currentUserId => _client.auth.currentUser?.id;
  String? get currentEmail => _client.auth.currentUser?.email;
  bool get isAnonymous => _client.auth.currentUser?.isAnonymous ?? false;

  /// Fetches the row for the current user. Upserts a default row first so the
  /// app keeps working even when the `auth.users` trigger has not fired yet
  /// (e.g. against a database that pre-dates that migration).
  Future<ProfileDto> getCurrentProfile() async {
    final uid = currentUserId;
    if (uid == null) {
      throw const AuthException('No active session');
    }
    await _client
        .from(_table)
        .upsert({'id': uid}, onConflict: 'id', ignoreDuplicates: true);
    final row =
        await _client.from(_table).select().eq('id', uid).maybeSingle();
    if (row == null) {
      // Fallback: brand-new row that didn't return from upsert above.
      return ProfileDto(id: uid);
    }
    return ProfileDto.fromJson(row);
  }

  Future<void> updateField(String column, Object? value) async {
    final uid = currentUserId;
    if (uid == null) {
      throw const AuthException('No active session');
    }
    await _client.from(_table).update({column: value}).eq('id', uid);
  }
}
