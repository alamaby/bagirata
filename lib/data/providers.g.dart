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
    r'9913d41192aa8525aa5615455a5d02e74cc65336';

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
