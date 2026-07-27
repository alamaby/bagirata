// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(billRemoteDataSource)
const billRemoteDataSourceProvider = BillRemoteDataSourceProvider._();

final class BillRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          BillRemoteDataSource,
          BillRemoteDataSource,
          BillRemoteDataSource
        >
    with $Provider<BillRemoteDataSource> {
  const BillRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<BillRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BillRemoteDataSource create(Ref ref) {
    return billRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BillRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BillRemoteDataSource>(value),
    );
  }
}

String _$billRemoteDataSourceHash() =>
    r'f75f77ccd54f300719d588cc44bc2138fb0b3f84';

@ProviderFor(passwordRecoverySession)
const passwordRecoverySessionProvider = PasswordRecoverySessionProvider._();

final class PasswordRecoverySessionProvider
    extends
        $FunctionalProvider<
          PasswordRecoverySession,
          PasswordRecoverySession,
          PasswordRecoverySession
        >
    with $Provider<PasswordRecoverySession> {
  const PasswordRecoverySessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordRecoverySessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordRecoverySessionHash();

  @$internal
  @override
  $ProviderElement<PasswordRecoverySession> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PasswordRecoverySession create(Ref ref) {
    return passwordRecoverySession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PasswordRecoverySession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PasswordRecoverySession>(value),
    );
  }
}

String _$passwordRecoverySessionHash() =>
    r'70a7c4e820f191efe054bc96eab2c8e9cd5f7339';

@ProviderFor(authRemoteDataSource)
const authRemoteDataSourceProvider = AuthRemoteDataSourceProvider._();

final class AuthRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AuthRemoteDataSource,
          AuthRemoteDataSource,
          AuthRemoteDataSource
        >
    with $Provider<AuthRemoteDataSource> {
  const AuthRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthRemoteDataSource create(Ref ref) {
    return authRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDataSource>(value),
    );
  }
}

String _$authRemoteDataSourceHash() =>
    r'119732ce2135e9044fe206a852bb89000b8ad2c6';

@ProviderFor(billRepository)
const billRepositoryProvider = BillRepositoryProvider._();

final class BillRepositoryProvider
    extends
        $FunctionalProvider<IBillRepository, IBillRepository, IBillRepository>
    with $Provider<IBillRepository> {
  const BillRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'billRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$billRepositoryHash();

  @$internal
  @override
  $ProviderElement<IBillRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IBillRepository create(Ref ref) {
    return billRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IBillRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IBillRepository>(value),
    );
  }
}

String _$billRepositoryHash() => r'faeadd71e8e4d3dad1667e7ce4c75058c7b401db';

@ProviderFor(ocrRepository)
const ocrRepositoryProvider = OcrRepositoryProvider._();

final class OcrRepositoryProvider
    extends $FunctionalProvider<IOCRRepository, IOCRRepository, IOCRRepository>
    with $Provider<IOCRRepository> {
  const OcrRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ocrRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ocrRepositoryHash();

  @$internal
  @override
  $ProviderElement<IOCRRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IOCRRepository create(Ref ref) {
    return ocrRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IOCRRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IOCRRepository>(value),
    );
  }
}

String _$ocrRepositoryHash() => r'd090e369bc1c658eff0a2f0e21c4a33d995d9921';

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends
        $FunctionalProvider<IAuthRepository, IAuthRepository, IAuthRepository>
    with $Provider<IAuthRepository> {
  const AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<IAuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IAuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IAuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'd9fdb1ac61b0d6fbd34b041d2c64cd0f0c7f6c0d';

@ProviderFor(profileRemoteDataSource)
const profileRemoteDataSourceProvider = ProfileRemoteDataSourceProvider._();

final class ProfileRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ProfileRemoteDataSource,
          ProfileRemoteDataSource,
          ProfileRemoteDataSource
        >
    with $Provider<ProfileRemoteDataSource> {
  const ProfileRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ProfileRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRemoteDataSource create(Ref ref) {
    return profileRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRemoteDataSource>(value),
    );
  }
}

String _$profileRemoteDataSourceHash() =>
    r'ca4f9ff96dc67ce5cc890ee4af7a5532ceb3d3d1';

@ProviderFor(profileRepository)
const profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          IProfileRepository,
          IProfileRepository,
          IProfileRepository
        >
    with $Provider<IProfileRepository> {
  const ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<IProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'4540dcf3060645d8150c54eaa2421425904c1f93';

@ProviderFor(appConfigRemoteDataSource)
const appConfigRemoteDataSourceProvider = AppConfigRemoteDataSourceProvider._();

final class AppConfigRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          AppConfigRemoteDataSource,
          AppConfigRemoteDataSource,
          AppConfigRemoteDataSource
        >
    with $Provider<AppConfigRemoteDataSource> {
  const AppConfigRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appConfigRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appConfigRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<AppConfigRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppConfigRemoteDataSource create(Ref ref) {
    return appConfigRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppConfigRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppConfigRemoteDataSource>(value),
    );
  }
}

String _$appConfigRemoteDataSourceHash() =>
    r'14e41f302095882a79d31dc930f07f52ce78074b';

@ProviderFor(appConfigRepository)
const appConfigRepositoryProvider = AppConfigRepositoryProvider._();

final class AppConfigRepositoryProvider
    extends
        $FunctionalProvider<
          IAppConfigRepository,
          IAppConfigRepository,
          IAppConfigRepository
        >
    with $Provider<IAppConfigRepository> {
  const AppConfigRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appConfigRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<IAppConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IAppConfigRepository create(Ref ref) {
    return appConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IAppConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IAppConfigRepository>(value),
    );
  }
}

String _$appConfigRepositoryHash() =>
    r'8efe8a6d66d5742ca56ab2af62c246763c966814';

@ProviderFor(savedParticipantRemoteDataSource)
const savedParticipantRemoteDataSourceProvider =
    SavedParticipantRemoteDataSourceProvider._();

final class SavedParticipantRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          SavedParticipantRemoteDataSource,
          SavedParticipantRemoteDataSource,
          SavedParticipantRemoteDataSource
        >
    with $Provider<SavedParticipantRemoteDataSource> {
  const SavedParticipantRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedParticipantRemoteDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedParticipantRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<SavedParticipantRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavedParticipantRemoteDataSource create(Ref ref) {
    return savedParticipantRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedParticipantRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedParticipantRemoteDataSource>(
        value,
      ),
    );
  }
}

String _$savedParticipantRemoteDataSourceHash() =>
    r'fcc3fe4f25fce00d3ea3b8fb00a2ec860330ee5a';

@ProviderFor(savedParticipantRepository)
const savedParticipantRepositoryProvider =
    SavedParticipantRepositoryProvider._();

final class SavedParticipantRepositoryProvider
    extends
        $FunctionalProvider<
          ISavedParticipantRepository,
          ISavedParticipantRepository,
          ISavedParticipantRepository
        >
    with $Provider<ISavedParticipantRepository> {
  const SavedParticipantRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedParticipantRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedParticipantRepositoryHash();

  @$internal
  @override
  $ProviderElement<ISavedParticipantRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ISavedParticipantRepository create(Ref ref) {
    return savedParticipantRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ISavedParticipantRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ISavedParticipantRepository>(value),
    );
  }
}

String _$savedParticipantRepositoryHash() =>
    r'60d046706f858cf4c01d1a5ffb8126827ec277ae';

/// Local SharedPreferences cache for the cross-bill participant library.
/// Created once on first read; reads/writes are awaited by the consumer
/// (typically the suggestion chips widget on first paint).

@ProviderFor(savedParticipantsCache)
const savedParticipantsCacheProvider = SavedParticipantsCacheProvider._();

/// Local SharedPreferences cache for the cross-bill participant library.
/// Created once on first read; reads/writes are awaited by the consumer
/// (typically the suggestion chips widget on first paint).

final class SavedParticipantsCacheProvider
    extends
        $FunctionalProvider<
          AsyncValue<SavedParticipantsCache>,
          SavedParticipantsCache,
          FutureOr<SavedParticipantsCache>
        >
    with
        $FutureModifier<SavedParticipantsCache>,
        $FutureProvider<SavedParticipantsCache> {
  /// Local SharedPreferences cache for the cross-bill participant library.
  /// Created once on first read; reads/writes are awaited by the consumer
  /// (typically the suggestion chips widget on first paint).
  const SavedParticipantsCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedParticipantsCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedParticipantsCacheHash();

  @$internal
  @override
  $FutureProviderElement<SavedParticipantsCache> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SavedParticipantsCache> create(Ref ref) {
    return savedParticipantsCache(ref);
  }
}

String _$savedParticipantsCacheHash() =>
    r'08aaccd4a107b35b8276fd3082aa3a8dcd1cea9d';

/// Exposes the runtime app configuration (legal doc versions, future feature
/// flags) to the rest of the app. Loaded once on first read and cached
/// in-memory by the repository; [refresh] drops the cache and re-reads.
/// Falls back to [AppConfig.fallback] when the read fails so the legal gate
/// still works offline (the user accepts v1, the next online read may bump
/// the version and re-prompt).

@ProviderFor(AppConfigNotifier)
const appConfigProvider = AppConfigNotifierProvider._();

/// Exposes the runtime app configuration (legal doc versions, future feature
/// flags) to the rest of the app. Loaded once on first read and cached
/// in-memory by the repository; [refresh] drops the cache and re-reads.
/// Falls back to [AppConfig.fallback] when the read fails so the legal gate
/// still works offline (the user accepts v1, the next online read may bump
/// the version and re-prompt).
final class AppConfigNotifierProvider
    extends $AsyncNotifierProvider<AppConfigNotifier, AppConfig> {
  /// Exposes the runtime app configuration (legal doc versions, future feature
  /// flags) to the rest of the app. Loaded once on first read and cached
  /// in-memory by the repository; [refresh] drops the cache and re-reads.
  /// Falls back to [AppConfig.fallback] when the read fails so the legal gate
  /// still works offline (the user accepts v1, the next online read may bump
  /// the version and re-prompt).
  const AppConfigNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appConfigNotifierHash();

  @$internal
  @override
  AppConfigNotifier create() => AppConfigNotifier();
}

String _$appConfigNotifierHash() => r'b40df654b5802183ca8499e9a1188b8b18fbb9c7';

/// Exposes the runtime app configuration (legal doc versions, future feature
/// flags) to the rest of the app. Loaded once on first read and cached
/// in-memory by the repository; [refresh] drops the cache and re-reads.
/// Falls back to [AppConfig.fallback] when the read fails so the legal gate
/// still works offline (the user accepts v1, the next online read may bump
/// the version and re-prompt).

abstract class _$AppConfigNotifier extends $AsyncNotifier<AppConfig> {
  FutureOr<AppConfig> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AppConfig>, AppConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppConfig>, AppConfig>,
              AsyncValue<AppConfig>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(imagePicker)
const imagePickerProvider = ImagePickerProvider._();

final class ImagePickerProvider
    extends $FunctionalProvider<IImagePicker, IImagePicker, IImagePicker>
    with $Provider<IImagePicker> {
  const ImagePickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imagePickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imagePickerHash();

  @$internal
  @override
  $ProviderElement<IImagePicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IImagePicker create(Ref ref) {
    return imagePicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IImagePicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IImagePicker>(value),
    );
  }
}

String _$imagePickerHash() => r'9b74f9f7be3e39f55705d805e70af42fbabf20bc';

@ProviderFor(historyPlusBannerPreferences)
const historyPlusBannerPreferencesProvider =
    HistoryPlusBannerPreferencesProvider._();

final class HistoryPlusBannerPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<HistoryPlusBannerPreferences>,
          HistoryPlusBannerPreferences,
          FutureOr<HistoryPlusBannerPreferences>
        >
    with
        $FutureModifier<HistoryPlusBannerPreferences>,
        $FutureProvider<HistoryPlusBannerPreferences> {
  const HistoryPlusBannerPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyPlusBannerPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyPlusBannerPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<HistoryPlusBannerPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HistoryPlusBannerPreferences> create(Ref ref) {
    return historyPlusBannerPreferences(ref);
  }
}

String _$historyPlusBannerPreferencesHash() =>
    r'680bc1a88a8c97a0ada959140f11755171874d2b';

@ProviderFor(pendingRegistrationPreferences)
const pendingRegistrationPreferencesProvider =
    PendingRegistrationPreferencesProvider._();

final class PendingRegistrationPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<PendingRegistrationPreferences>,
          PendingRegistrationPreferences,
          FutureOr<PendingRegistrationPreferences>
        >
    with
        $FutureModifier<PendingRegistrationPreferences>,
        $FutureProvider<PendingRegistrationPreferences> {
  const PendingRegistrationPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingRegistrationPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingRegistrationPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<PendingRegistrationPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PendingRegistrationPreferences> create(Ref ref) {
    return pendingRegistrationPreferences(ref);
  }
}

String _$pendingRegistrationPreferencesHash() =>
    r'9de2cafaa81966a8588ce29f68f484b8e1cb4b39';
