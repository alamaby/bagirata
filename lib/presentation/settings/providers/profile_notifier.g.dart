// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loads and exposes the current user's profile (with email + anon flag merged
/// in from the active session). All preference mutations go through this
/// notifier so the UI updates instantly via `state = AsyncData(...)` and the
/// row is persisted in the background.

@ProviderFor(ProfileNotifier)
const profileProvider = ProfileNotifierProvider._();

/// Loads and exposes the current user's profile (with email + anon flag merged
/// in from the active session). All preference mutations go through this
/// notifier so the UI updates instantly via `state = AsyncData(...)` and the
/// row is persisted in the background.
final class ProfileNotifierProvider
    extends $AsyncNotifierProvider<ProfileNotifier, UserProfile> {
  /// Loads and exposes the current user's profile (with email + anon flag merged
  /// in from the active session). All preference mutations go through this
  /// notifier so the UI updates instantly via `state = AsyncData(...)` and the
  /// row is persisted in the background.
  const ProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileNotifierHash();

  @$internal
  @override
  ProfileNotifier create() => ProfileNotifier();
}

String _$profileNotifierHash() => r'fbdd2f09e4759f1f30377cad2cf8ab9ee10e2d67';

/// Loads and exposes the current user's profile (with email + anon flag merged
/// in from the active session). All preference mutations go through this
/// notifier so the UI updates instantly via `state = AsyncData(...)` and the
/// row is persisted in the background.

abstract class _$ProfileNotifier extends $AsyncNotifier<UserProfile> {
  FutureOr<UserProfile> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<UserProfile>, UserProfile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfile>, UserProfile>,
              AsyncValue<UserProfile>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
