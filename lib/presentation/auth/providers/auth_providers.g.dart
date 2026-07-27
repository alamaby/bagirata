// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(authState)
const authStateProvider = AuthStateProvider._();

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

final class AuthStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthSnapshot>,
          AuthSnapshot,
          Stream<AuthSnapshot>
        >
    with $FutureModifier<AuthSnapshot>, $StreamProvider<AuthSnapshot> {
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

String _$authStateHash() => r'44e4df37bb05b7fc78cad0bc8189ee69ca7bd9b7';
