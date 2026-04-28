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
}
