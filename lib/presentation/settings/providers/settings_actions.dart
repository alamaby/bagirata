import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/result.dart';
import '../../../data/providers.dart';
import '../../bills/providers/bill_list_notifier.dart';
import '../../bills/providers/saved_participants_notifier.dart';
import 'profile_notifier.dart';

/// Drops the previous user's participant-library cache so suggestions never
/// leak across user boundaries (the notifier rebuilds on auth change, but the
/// SharedPreferences JSON would linger otherwise).
Future<void> clearSavedParticipantsCache(WidgetRef ref, String? userId) async {
  if (userId == null || userId.isEmpty) return;
  try {
    final cache = await ref.read(savedParticipantsCacheProvider.future);
    await cache.clear(userId);
  } catch (_) {
    // Best-effort: a stale cache is a privacy nit, never a logout blocker.
  }
  ref.invalidate(savedParticipantsProvider);
}

/// Signs the user out, invalidates every user-scoped Riverpod cache, then
/// re-establishes a fresh anonymous session so the app keeps working without
/// a forced login. The router redirect listens to `authStateProvider` and
/// will route the user back to `/scan` when the new snapshot fires.
Future<Result<void>> performLogout(WidgetRef ref) async {
  final auth = ref.read(authRepositoryProvider);
  final previousUserId = auth.currentUserId;
  final res = await auth.signOut();

  // Drop user-scoped state so a different account (or fresh anon) cannot see
  // the previous user's data flash on screen.
  await clearSavedParticipantsCache(ref, previousUserId);
  ref.invalidate(profileProvider);
  ref.invalidate(billListProvider);

  // Re-establish a clean anonymous session, consistent with lazy-anon design.
  await ref.read(authRemoteDataSourceProvider).ensureSignedIn();

  return res;
}

/// Deletes the active account on the server and drops all user-scoped client
/// caches. A fresh anonymous session is created lazily by the next gated flow.
Future<Result<void>> performDeleteAccount(WidgetRef ref) async {
  final auth = ref.read(authRepositoryProvider);
  final previousUserId = auth.currentUserId;
  final res = await auth.deleteAccount();

  await clearSavedParticipantsCache(ref, previousUserId);
  ref.invalidate(profileProvider);
  ref.invalidate(billListProvider);

  return res;
}
