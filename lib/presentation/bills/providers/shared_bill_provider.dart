import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/share_link_token.dart';
import '../../../core/error/result.dart';
import '../../../data/providers.dart';
import '../../../domain/entities/shared_bill.dart';

/// Resolves a public share-link token (no login required) via
/// `resolve_share_token`. Returns null when the token is invalid, expired,
/// revoked, or the bill was deleted — the screen then renders the expired
/// view. Auto-disposed: the raw token lives only while the screen is open.
final sharedBillProvider =
    FutureProvider.autoDispose.family<SharedBill?, String>((ref, token) async {
      final repo = ref.read(billRepositoryProvider);
      final res = await repo.resolveShareToken(ShareLinkToken.hash(token));
      // Null data = invalid/expired/revoked/deleted token → expired view.
      // Genuine failures (network, server) rethrow → error view with retry.
      return switch (res) {
        Success(:final data) => data,
        ResultFailure(:final failure) => throw failure,
      };
    });
