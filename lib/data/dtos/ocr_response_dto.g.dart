// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OcrLineItemDto _$OcrLineItemDtoFromJson(Map<String, dynamic> json) =>
    _OcrLineItemDto(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      qty: (json['qty'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$OcrLineItemDtoToJson(_OcrLineItemDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'qty': instance.qty,
    };

_OcrResponseDto _$OcrResponseDtoFromJson(Map<String, dynamic> json) =>
    _OcrResponseDto(
      items: (json['items'] as List<dynamic>)
          .map((e) => OcrLineItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      detectedTotal: (json['detected_total'] as num?)?.toDouble(),
      detectedTax: (json['detected_tax'] as num?)?.toDouble(),
      detectedService: (json['detected_service'] as num?)?.toDouble(),
      merchant: json['merchant'] as String?,
      receiptDate: json['receipt_date'] == null
          ? null
          : DateTime.parse(json['receipt_date'] as String),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      providerUsed: json['provider_used'] as String,
    );

Map<String, dynamic> _$OcrResponseDtoToJson(_OcrResponseDto instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'detected_total': ?instance.detectedTotal,
      'detected_tax': ?instance.detectedTax,
      'detected_service': ?instance.detectedService,
      'merchant': ?instance.merchant,
      'receipt_date': ?instance.receiptDate?.toIso8601String(),
      'confidence': instance.confidence,
      'provider_used': instance.providerUsed,
    };
