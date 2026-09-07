import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/billing/share_link_token.dart';
import '../../../core/error/result.dart';
import '../../../core/network/supabase_client_provider.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/providers.dart';

part 'bill_share_link_notifier.g.dart';

class BillShareState {
  const BillShareState({required this.tokenId, required this.expiresAt, this.lastLink});

  final String tokenId;
  final DateTime expiresAt;

  /// Raw `bagistruk://share/<token>` link from the most recent create call.
  /// Memory-only (never persisted): the server stores only the SHA-256 hash,
  /// so a re-share is possible only in the session that created the link.
  final String? lastLink;
}

@riverpod
class BillShareLink extends _$BillShareLink {
  @override
  Future<BillShareState?> build() async => null;

  Future<void> load(String billId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final client = ref.read(supabaseClientProvider);
      final rows = await client
          .from('bill_share_tokens')
          .select('id,expires_at')
          .eq('bill_id', billId)
          .isFilter('revoked_at', null)
          .gt('expires_at', DateTime.now().toUtc().toIso8601String())
          .order('created_at', ascending: false)
          .limit(1);
      if (rows.isEmpty) return null;
      return BillShareState(
        tokenId: rows.first['id'].toString(),
        expiresAt: DateTime.parse(rows.first['expires_at'].toString()),
      );
    });
    if (state.hasError) {
      AppLogger.error('BillShareLink.load failed', state.error);
    }
  }

  Future<String?> createAndCopy(String billId) async {
    final token = ShareLinkToken.generate();
    final hash = ShareLinkToken.hash(token);
    state = const AsyncLoading();
    try {
      final repo = ref.read(billRepositoryProvider);
      final res = await repo.createShareToken(billId: billId, tokenHash: hash);
      switch (res) {
        case ResultFailure(:final failure):
          if (failure.toString().contains('share_token_limit')) {
            state = AsyncError('share_token_limit', StackTrace.current);
          } else {
            state = AsyncError(failure, StackTrace.current);
          }
          return null;
        case Success(:final data):
          final link = 'bagistruk://share/$token';
          state = AsyncData(
            BillShareState(
              tokenId: data.tokenId,
              expiresAt: data.expiresAt,
              lastLink: link,
            ),
          );
          await Clipboard.setData(ClipboardData(text: link));
          return link;
      }
    } catch (e, st) {
      AppLogger.error('BillShareLink.createAndCopy failed', e, st);
      if (e.toString().contains('share_token_limit')) {
        state = AsyncError('share_token_limit', st);
      } else {
        state = AsyncError(e, st);
      }
      return null;
    }
  }

  Future<bool> revoke(String tokenId) async {
    try {
      final repo = ref.read(billRepositoryProvider);
      final res = await repo.revokeShareToken(tokenId);
      if (res is ResultFailure) {
        state = AsyncError(res.failure, StackTrace.current);
        return false;
      }
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      AppLogger.error('BillShareLink.revoke failed', e, st);
      state = AsyncError(e, st);
      return false;
    }
  }
}
