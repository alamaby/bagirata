import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data/providers.dart';
import '../../../domain/entities/user_profile.dart';
import '../../auth/providers/auth_providers.dart';

part 'profile_notifier.g.dart';

/// Loads and exposes the current user's profile (with email + anon flag merged
/// in from the active session). All preference mutations go through this
/// notifier so the UI updates instantly via `state = AsyncData(...)` and the
/// row is persisted in the background.
@Riverpod(keepAlive: true)
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<UserProfile> build() async {
    // Rebuild whenever the active session changes (anon ↔ email, sign-out,
    // etc.) so the profile mirrors the current user.
    ref.watch(authStateProvider);
    final auth = ref.watch(authRepositoryProvider);
    final uid = auth.currentUserId;
    if (uid == null) {
      // No session yet — return a default placeholder so locale / theme /
      // currency providers can read sensible defaults instead of throwing.
      // This is a synthetic profile, intentionally not persisted; the notifier
      // re-runs the moment a real session appears.
      return const UserProfile(id: '', isAnonymous: true);
    }
    final repo = ref.watch(profileRepositoryProvider);
    final result = await repo.getCurrentProfile();
    return switch (result) {
      Success(:final data) => data,
      ResultFailure(:final failure) => throw _FailureException(failure),
    };
  }

  Future<Result<void>> updateDisplayName(String name) async {
    final res =
        await ref.read(profileRepositoryProvider).updateDisplayName(name);
    if (res is Success<void>) {
      _patch((p) => p.copyWith(displayName: name.trim()));
    }
    return res;
  }

  Future<Result<void>> updateCurrency(String code) async {
    final res =
        await ref.read(profileRepositoryProvider).updateDefaultCurrency(code);
    if (res is Success<void>) {
      _patch((p) => p.copyWith(defaultCurrency: code));
    }
    return res;
  }

  Future<Result<void>> updateLanguage(String code) async {
    final res = await ref.read(profileRepositoryProvider).updateLanguage(code);
    if (res is Success<void>) {
      _patch((p) => p.copyWith(languagePref: code));
    }
    return res;
  }

  Future<Result<void>> updateTheme(String mode) async {
    final res = await ref.read(profileRepositoryProvider).updateThemePref(mode);
    if (res is Success<void>) {
      _patch((p) => p.copyWith(themePref: mode));
    }
    return res;
  }

  void _patch(UserProfile Function(UserProfile) update) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(update(current));
  }
}

class _FailureException implements Exception {
  _FailureException(this.failure);
  final Failure failure;
  @override
  String toString() => failure.toString();
}
