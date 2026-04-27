import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/ocr_result.dart';

part 'ocr_response_dto.freezed.dart';
part 'ocr_response_dto.g.dart';

@freezed
abstract class OcrLineItemDto with _$OcrLineItemDto {
  const OcrLineItemDto._();

  const factory OcrLineItemDto({
    required String name,
    required double price,
    @Default(1) int qty,
  }) = _OcrLineItemDto;

  factory OcrLineItemDto.fromJson(Map<String, dynamic> json) =>
      _$OcrLineItemDtoFromJson(json);

  OcrLineItem toEntity() => OcrLineItem(name: name, price: price, qty: qty);
}

@freezed
abstract class OcrResponseDto with _$OcrResponseDto {
  const OcrResponseDto._();

  const factory OcrResponseDto({
    required List<OcrLineItemDto> items,
    double? detectedTotal,
    double? detectedTax,
    double? detectedService,
    String? merchant,
    DateTime? receiptDate,
    @Default(0.0) double confidence,
    required String providerUsed,
  }) = _OcrResponseDto;

  factory OcrResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OcrResponseDtoFromJson(json);

  OcrResult toEntity() => OcrResult(
        items: items.map((e) => e.toEntity()).toList(growable: false),
        detectedTotal: detectedTotal,
        detectedTax: detectedTax,
        detectedService: detectedService,
        merchant: merchant,
        receiptDate: receiptDate,
        confidence: confidence,
        providerUsed: providerUsed,
      );
}
