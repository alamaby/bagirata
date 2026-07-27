import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/providers.dart';
import '../../../domain/entities/auth_snapshot.dart';

part 'auth_providers.g.dart';

/// Live auth snapshot. Seeded with the current Supabase session so the
/// router can read a synchronous value on first navigation, then updated by the
/// `onAuthStateChange` stream for every subsequent transition.
///
/// The seed also reads the persistent `isPasswordRecovery` flag from
/// [IAuthRepository]. The flag is set by `DeepLinkHandler` in `main()`
/// when the cold-start URI is a `type=recovery` callback, which is the
/// only signal that survives the gap between cold-start and the first
/// stream emission. Without it, `ResetPasswordScreen` would lose its
/// active-session guard and the router would let the user bounce back to
/// `/scan` after the link is consumed.
@Riverpod(keepAlive: true)
Stream<AuthSnapshot> authState(Ref ref) async* {
  final repo = ref.watch(authRepositoryProvider);
  yield AuthSnapshot(
    userId: repo.currentUserId,
    isAnonymous: repo.isAnonymous,
    emailConfirmed: repo.isEmailConfirmed,
    isPasswordRecovery: repo.isPasswordRecovery,
  );
  yield* repo.watchAuthState();
}
