// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ocrService)
const ocrServiceProvider = OcrServiceProvider._();

final class OcrServiceProvider
    extends $FunctionalProvider<OCRService, OCRService, OCRService>
    with $Provider<OCRService> {
  const OcrServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ocrServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ocrServiceHash();

  @$internal
  @override
  $ProviderElement<OCRService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OCRService create(Ref ref) {
    return ocrService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OCRService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OCRService>(value),
    );
  }
}

String _$ocrServiceHash() => r'3866e5aad2737f5da8bc48ec6e50d8af76660200';
