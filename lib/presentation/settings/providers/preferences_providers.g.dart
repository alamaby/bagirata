// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Active locale derived from [ProfileNotifier]. Defaults to device language
/// until the profile row resolves.

@ProviderFor(localePref)
const localePrefProvider = LocalePrefProvider._();

/// Active locale derived from [ProfileNotifier]. Defaults to device language
/// until the profile row resolves.

final class LocalePrefProvider
    extends $FunctionalProvider<Locale, Locale, Locale>
    with $Provider<Locale> {
  /// Active locale derived from [ProfileNotifier]. Defaults to device language
  /// until the profile row resolves.
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

String _$localePrefHash() => r'e5425c982eeb664a835cf2e543490b9803645114';

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

String _$themeModePrefHash() => r'11bebe37d4f9bf74fa7c2c817675e6906463085b';

/// Transient theme override for live preview. Set by the onboarding theme
/// picker; cleared on pop / successful persist / replay-finish so it never
/// outlives the flow that created it. Null means "no preview, use the
/// profile value".

@ProviderFor(ThemePreview)
const themePreviewProvider = ThemePreviewProvider._();

/// Transient theme override for live preview. Set by the onboarding theme
/// picker; cleared on pop / successful persist / replay-finish so it never
/// outlives the flow that created it. Null means "no preview, use the
/// profile value".
final class ThemePreviewProvider
    extends $NotifierProvider<ThemePreview, ThemeMode?> {
  /// Transient theme override for live preview. Set by the onboarding theme
  /// picker; cleared on pop / successful persist / replay-finish so it never
  /// outlives the flow that created it. Null means "no preview, use the
  /// profile value".
  const ThemePreviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themePreviewProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themePreviewHash();

  @$internal
  @override
  ThemePreview create() => ThemePreview();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode?>(value),
    );
  }
}

String _$themePreviewHash() => r'930dc825330c6df00e208f64b05ea80fd91009c0';

/// Transient theme override for live preview. Set by the onboarding theme
/// picker; cleared on pop / successful persist / replay-finish so it never
/// outlives the flow that created it. Null means "no preview, use the
/// profile value".

abstract class _$ThemePreview extends $Notifier<ThemeMode?> {
  ThemeMode? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ThemeMode?, ThemeMode?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode?, ThemeMode?>,
              ThemeMode?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

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

String _$currencyPrefHash() => r'8ecc2000b43fafddf4289555d6660ec8a53c03dd';
