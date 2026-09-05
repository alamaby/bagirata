import 'package:freezed_annotation/freezed_annotation.dart';

part 'ocr_result.freezed.dart';

@freezed
abstract class OcrLineItem with _$OcrLineItem {
  const factory OcrLineItem({
    required String name,
    required double price,
    @Default(1.0) double qty,
  }) = _OcrLineItem;
}

/// Provider-agnostic parsed payload returned by the Edge Function. Carries
/// `providerUsed` so the UI can show which model answered and so we can
/// diagnose failover behaviour from telemetry.
@freezed
abstract class OcrResult with _$OcrResult {
  const factory OcrResult({
    required List<OcrLineItem> items,
    double? detectedTotal,
    double? detectedTax,
    double? detectedService,
    String? merchant,
    DateTime? receiptDate,
    @Default(0.0) double confidence,
    required String providerUsed,
  }) = _OcrResult;

  const OcrResult._();

  /// Sentinel for bills created manually without OCR (0 credit). The review
  /// screen treats this as a blank form: no confidence warning, no mismatch
  /// banner, no receipt-date row.
  static const String manualProviderUsed = 'manual';

  static OcrResult manual() => const OcrResult(
    items: [],
    confidence: 0,
    providerUsed: manualProviderUsed,
  );

  bool get isManual => providerUsed == manualProviderUsed;
}
