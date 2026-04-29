import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/providers.dart';
import '../../../domain/entities/auth_snapshot.dart';

part 'auth_providers.g.dart';

/// Live auth snapshot. Seeded with the current Supabase session so the router
/// can read a synchronous value on first navigation, then updated by the
/// `onAuthStateChange` stream for every subsequent transition.
@Riverpod(keepAlive: true)
Stream<AuthSnapshot> authState(Ref ref) async* {
  final repo = ref.watch(authRepositoryProvider);
  yield AuthSnapshot(
    userId: repo.currentUserId,
    isAnonymous: repo.isAnonymous,
  );
  yield* repo.watchAuthState();
}
