import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/format/device_locale_defaults.dart';
import 'profile_notifier.dart';

part 'preferences_providers.g.dart';

/// Active locale derived from [ProfileNotifier]. Defaults to device language
/// until the profile row resolves.
@Riverpod(keepAlive: true)
Locale localePref(Ref ref) {
  final profile = ref.watch(profileProvider);
  final code =
      profile.value?.languagePref ??
      DeviceLocaleDefaults.resolveLanguage(
        WidgetsBinding.instance.platformDispatcher.locales,
      );
  return Locale(code);
}

@Riverpod(keepAlive: true)
ThemeMode themeModePref(Ref ref) {
  // In-memory preview (e.g. onboarding theme picker) wins over the
  // persisted profile value so the user sees the effect immediately,
  // before anything is written to the database.
  final preview = ref.watch(themePreviewProvider);
  if (preview != null) return preview;
  final profile = ref.watch(profileProvider);
  final pref = profile.value?.themePref ?? 'system';
  return switch (pref) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

/// Transient theme override for live preview. Set by the onboarding theme
/// picker; cleared on pop / successful persist / replay-finish so it never
/// outlives the flow that created it. Null means "no preview, use the
/// profile value".
@Riverpod(keepAlive: true)
class ThemePreview extends _$ThemePreview {
  @override
  ThemeMode? build() => null;

  void set(ThemeMode? mode) => state = mode;

  void clear() => state = null;
}

@Riverpod(keepAlive: true)
String currencyPref(Ref ref) {
  final profile = ref.watch(profileProvider);
  return profile.value?.defaultCurrency ??
      DeviceLocaleDefaults.resolveCurrency(
        WidgetsBinding.instance.platformDispatcher.locales,
      );
}
