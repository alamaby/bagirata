// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OcrRequestDto _$OcrRequestDtoFromJson(Map<String, dynamic> json) =>
    _OcrRequestDto(
      images: (json['images'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      hint: json['hint'] as String?,
    );

Map<String, dynamic> _$OcrRequestDtoToJson(_OcrRequestDto instance) =>
    <String, dynamic>{'images': instance.images, 'hint': ?instance.hint};
