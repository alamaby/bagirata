import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:crypto/crypto.dart';
import 'dart:convert';

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


  /// Mirrors the server-side `public.canonical_email()` (lowercase + trim +
  /// googlemail.com alias). Kept in sync so the hash computed here matches
  /// what the database will compute and look up.
  static String canonicaliseEmail(String raw) {
    final trimmed = raw.trim().toLowerCase();
    if (trimmed.endsWith('@googlemail.com')) {
      return trimmed.replaceFirst('@googlemail.com', '@gmail.com');
    }
    return trimmed;
  }

  static String hashEmail(String canonical) {
    final bytes = utf8.encode(canonical);
    return sha256.convert(bytes).toString();
  }

  /// Dual-writes the marketing opt-in to the unified `marketing_subscribers`
  /// table so the landing page and the app stay in sync. RLS policy
  /// `Authenticated users manage own marketing row` restricts the write to
  /// rows where `linked_user_id = auth.uid()` or `email_canonical =
  /// auth.email()`, so no cross-user writes are possible.
  ///
  /// Idempotent: re-uses the same `email_canonical_hash` so the
  /// post-login subscribe (sync 3) and the settings toggle (sync 4) both
  /// collapse to the same row.
  Future<void> upsertMarketingSubscriber({
    required String email,
    required bool optedIn,
    required String source,
    String preferredLanguage = 'en',
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      throw const AuthException('No active session');
    }
    final canonical = canonicaliseEmail(email);
    final emailHash = hashEmail(canonical);
    final now = DateTime.now().toUtc().toIso8601String();

    await _client.from('marketing_subscribers').upsert({
      'email_canonical': canonical,
      'email_canonical_hash': emailHash,
      'linked_user_id': uid,
      'source': source,
      'status': optedIn ? 'subscribed' : 'unsubscribed',
      'preferred_language': preferredLanguage,
      'subscribed_at': optedIn ? now : null,
      'unsubscribed_at': optedIn ? null : now,
    }, onConflict: 'email_canonical_hash');
  }
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
    final row = await _client.from(_table).select().eq('id', uid).maybeSingle();
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

  /// Writes multiple columns in a single UPDATE so multi-field mutations
  /// (legal acceptance, marketing opt-in, welcome stamp) are atomic on the
  /// server. Falls back to a per-field loop in `updateField` for single
  /// column writes.
  Future<void> updateFields(Map<String, Object?> values) async {
    final uid = currentUserId;
    if (uid == null) {
      throw const AuthException('No active session');
    }
    if (values.isEmpty) return;
    await _client.from(_table).update(values).eq('id', uid);
  }

  Future<Map<String, dynamic>> getTransferBankInfo() async {
    final uid = currentUserId;
    if (uid == null) {
      throw const AuthException('No active session');
    }
    final row = await _client
        .from(_table)
        .select(
          'transfer_bank_name, transfer_account_name, transfer_account_number',
        )
        .eq('id', uid)
        .maybeSingle();
    return Map<String, dynamic>.from(row ?? const {});
  }

  Future<void> updateTransferBankInfo({
    required String? bankName,
    required String? accountName,
    required String? accountNumber,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      throw const AuthException('No active session');
    }
    await _client
        .from(_table)
        .update({
          'transfer_bank_name': bankName,
          'transfer_account_name': accountName,
          'transfer_account_number': accountNumber,
        })
        .eq('id', uid);
  }

  Future<Map<String, dynamic>> getOcrCreditStatus() async {
    final uid = currentUserId;
    if (uid == null) {
      throw const AuthException('No active session');
    }
    final row = await _client
        .rpc<Map<String, dynamic>>(
          'get_ocr_credit_status',
          params: {'p_user_id': uid},
        )
        .single();
    return Map<String, dynamic>.from(row as Map);
  }

  Future<Map<String, dynamic>> getMonthlySpendingInsight({
    required DateTime month,
    required String currencyCode,
    String? category,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      throw const AuthException('No active session');
    }
    final row = await _client
        .rpc<Map<String, dynamic>>(
          'get_monthly_spending_insight',
          params: {
            'p_user_id': uid,
            'p_month': _monthParam(month),
            'p_currency_code': currencyCode,
            if (category != null) 'p_category': category,
          },
        )
        .single();
    return Map<String, dynamic>.from(row as Map);
  }

  /// Formats [month] as a date-only string (`YYYY-MM-DD`) normalized to the
  /// first day of its month, matching the RPC's PostgreSQL `DATE` parameter.
  static String _monthParam(DateTime month) {
    final m = DateTime.utc(month.year, month.month);
    return m.toIso8601String().substring(0, 10);
  }

  Future<void> touchLastActive() async {
    if (currentUserId == null) return;
    await _client.rpc<void>('touch_last_active_at');
  }
}
