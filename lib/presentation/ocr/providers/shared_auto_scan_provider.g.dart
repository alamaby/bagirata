// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_auto_scan_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One-shot flag requesting the scan screen to auto-run the OCR pipeline
/// for images that arrived via Android share.
///
/// The flag is set when a share intent is received and consumed by
/// `ReceiptCaptureScreen` on first paint. It stays pending across router
/// gates (legal acceptance / onboarding / welcome) so the auto-scan fires
/// only once the scan screen is actually visible — never blindly from the
/// background listener, which lacks the `BuildContext` and mounted checks
/// `_process()` needs.

@ProviderFor(SharedAutoScan)
const sharedAutoScanProvider = SharedAutoScanProvider._();

/// One-shot flag requesting the scan screen to auto-run the OCR pipeline
/// for images that arrived via Android share.
///
/// The flag is set when a share intent is received and consumed by
/// `ReceiptCaptureScreen` on first paint. It stays pending across router
/// gates (legal acceptance / onboarding / welcome) so the auto-scan fires
/// only once the scan screen is actually visible — never blindly from the
/// background listener, which lacks the `BuildContext` and mounted checks
/// `_process()` needs.
final class SharedAutoScanProvider
    extends
        $NotifierProvider<SharedAutoScan, ({int imageCount, bool pending})> {
  /// One-shot flag requesting the scan screen to auto-run the OCR pipeline
  /// for images that arrived via Android share.
  ///
  /// The flag is set when a share intent is received and consumed by
  /// `ReceiptCaptureScreen` on first paint. It stays pending across router
  /// gates (legal acceptance / onboarding / welcome) so the auto-scan fires
  /// only once the scan screen is actually visible — never blindly from the
  /// background listener, which lacks the `BuildContext` and mounted checks
  /// `_process()` needs.
  const SharedAutoScanProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedAutoScanProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedAutoScanHash();

  @$internal
  @override
  SharedAutoScan create() => SharedAutoScan();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({int imageCount, bool pending}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<({int imageCount, bool pending})>(
        value,
      ),
    );
  }
}

String _$sharedAutoScanHash() => r'f464c726a5af21db138ef723171fbd1d451b6a3a';

/// One-shot flag requesting the scan screen to auto-run the OCR pipeline
/// for images that arrived via Android share.
///
/// The flag is set when a share intent is received and consumed by
/// `ReceiptCaptureScreen` on first paint. It stays pending across router
/// gates (legal acceptance / onboarding / welcome) so the auto-scan fires
/// only once the scan screen is actually visible — never blindly from the
/// background listener, which lacks the `BuildContext` and mounted checks
/// `_process()` needs.

abstract class _$SharedAutoScan
    extends $Notifier<({int imageCount, bool pending})> {
  ({int imageCount, bool pending}) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              ({int imageCount, bool pending}),
              ({int imageCount, bool pending})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({int imageCount, bool pending}),
                ({int imageCount, bool pending})
              >,
              ({int imageCount, bool pending}),
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
