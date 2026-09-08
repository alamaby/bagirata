// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_draft_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScanDraftNotifier)
const scanDraftProvider = ScanDraftNotifierProvider._();

final class ScanDraftNotifierProvider
    extends $NotifierProvider<ScanDraftNotifier, ScanDraftState> {
  const ScanDraftNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scanDraftProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scanDraftNotifierHash();

  @$internal
  @override
  ScanDraftNotifier create() => ScanDraftNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScanDraftState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScanDraftState>(value),
    );
  }
}

String _$scanDraftNotifierHash() => r'b61480278c9d13e9a10d96fdee95e4635a7a7479';

abstract class _$ScanDraftNotifier extends $Notifier<ScanDraftState> {
  ScanDraftState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ScanDraftState, ScanDraftState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScanDraftState, ScanDraftState>,
              ScanDraftState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
