// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Active locale derived from [ProfileNotifier]. Defaults to Indonesian until
/// the profile row resolves, mirroring the previous hard-coded MaterialApp
/// locale so first-frame text never flickers from English to Indonesian.

@ProviderFor(localePref)
const localePrefProvider = LocalePrefProvider._();

/// Active locale derived from [ProfileNotifier]. Defaults to Indonesian until
/// the profile row resolves, mirroring the previous hard-coded MaterialApp
/// locale so first-frame text never flickers from English to Indonesian.

final class LocalePrefProvider
    extends $FunctionalProvider<Locale, Locale, Locale>
    with $Provider<Locale> {
  /// Active locale derived from [ProfileNotifier]. Defaults to Indonesian until
  /// the profile row resolves, mirroring the previous hard-coded MaterialApp
  /// locale so first-frame text never flickers from English to Indonesian.
  const LocalePrefProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localePrefProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localePrefHash();

  @$internal
  @override
  $ProviderElement<Locale> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Locale create(Ref ref) {
    return localePref(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$localePrefHash() => r'167b41a1d0258b7d4579d9e0f95ba900bea14568';

@ProviderFor(themeModePref)
const themeModePrefProvider = ThemeModePrefProvider._();

final class ThemeModePrefProvider
    extends $FunctionalProvider<ThemeMode, ThemeMode, ThemeMode>
    with $Provider<ThemeMode> {
  const ThemeModePrefProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModePrefProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModePrefHash();

  @$internal
  @override
  $ProviderElement<ThemeMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeMode create(Ref ref) {
    return themeModePref(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModePrefHash() => r'b5598f8b5d1230ce5e825e9709df395bab5a4799';

@ProviderFor(currencyPref)
const currencyPrefProvider = CurrencyPrefProvider._();

final class CurrencyPrefProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  const CurrencyPrefProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currencyPrefProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currencyPrefHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return currencyPref(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$currencyPrefHash() => r'6d6d4a9553b88873944403fc4646f7094727f762';
