// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live auth snapshot. Seeded with the current Supabase session so the router
/// can read a synchronous value on first navigation, then updated by the
/// `onAuthStateChange` stream for every subsequent transition.

@ProviderFor(authState)
const authStateProvider = AuthStateProvider._();

/// Live auth snapshot. Seeded with the current Supabase session so the router
/// can read a synchronous value on first navigation, then updated by the
/// `onAuthStateChange` stream for every subsequent transition.

final class AuthStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthSnapshot>,
          AuthSnapshot,
          Stream<AuthSnapshot>
        >
    with $FutureModifier<AuthSnapshot>, $StreamProvider<AuthSnapshot> {
  /// Live auth snapshot. Seeded with the current Supabase session so the router
  /// can read a synchronous value on first navigation, then updated by the
  /// `onAuthStateChange` stream for every subsequent transition.
  const AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<AuthSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AuthSnapshot> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'70fcac17860ed4a2a01816ae8b06111fec651268';
