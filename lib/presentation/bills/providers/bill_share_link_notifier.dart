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

/// Outcome of [BillShareLink.createAndCopy] without touching displayed data.
class ShareLinkResult {
  const ShareLinkResult._({this.link, this.limited = false});

  const ShareLinkResult.created(this.link) : limited = false;
  const ShareLinkResult.limited() : link = null, limited = true;
  const ShareLinkResult.failed() : link = null, limited = false;

  final String? link;
  final bool limited;
}

@riverpod
class BillShareLink extends _$BillShareLink {
  @override
  Future<BillShareState?> build(String billId) async {
    // No network in build: the screen calls load() explicitly. This keeps
    // the provider unit-testable without a Supabase client and makes the
    // per-bill family state (not a global singleton) the fix for stale A→B
    // detail navigation.
    return null;
  }

  /// Resolves the currently active link (if any) for [billId].
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

  /// Centralized Free-limit match (case-insensitive; the RPC raises
  /// `share_token_limit: ...` which PostgREST surfaces in the message).
  static bool isLimitError(Object e) =>
      e.toString().toLowerCase().contains('share_token_limit');

  Future<ShareLinkResult> createAndCopy(String billId) async {
    final token = ShareLinkToken.generate();
    final hash = ShareLinkToken.hash(token);
    try {
      final repo = ref.read(billRepositoryProvider);
      final res = await repo.createShareToken(billId: billId, tokenHash: hash);
      switch (res) {
        case ResultFailure(:final failure):
          AppLogger.error(
            'BillShareLink.createAndCopy failed',
            failure,
            StackTrace.current,
          );
          // Preserve displayed data: a failed create must not wipe a
          // previously loaded expiry/revoke.
          return isLimitError(failure)
              ? const ShareLinkResult.limited()
              : const ShareLinkResult.failed();
        case Success(:final data):
          final link = 'bagistruk://share/$token';
          state = AsyncData(
            BillShareState(
              tokenId: data.tokenId,
              expiresAt: data.expiresAt,
              lastLink: link,
            ),
          );
          // Best-effort: a clipboard failure (e.g. headless env) must
          // not lose the link — the screen re-shares from `lastLink`.
          try {
            await Clipboard.setData(ClipboardData(text: link));
          } catch (e, st) {
            AppLogger.error('BillShareLink.clipboard failed', e, st);
          }
          return ShareLinkResult.created(link);
      }
    } catch (e, st) {
      AppLogger.error('BillShareLink.createAndCopy failed', e, st);
      return isLimitError(e)
          ? const ShareLinkResult.limited()
          : const ShareLinkResult.failed();
    }
  }

  Future<bool> revoke(String tokenId) async {
    try {
      final repo = ref.read(billRepositoryProvider);
      final res = await repo.revokeShareToken(tokenId);
      if (res is ResultFailure) {
        AppLogger.error(
          'BillShareLink.revoke failed',
          res.failure,
          StackTrace.current,
        );
        return false;
      }
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      AppLogger.error('BillShareLink.revoke failed', e, st);
      return false;
    }
  }
}
