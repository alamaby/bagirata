import 'package:freezed_annotation/freezed_annotation.dart';

part 'ocr_request_dto.freezed.dart';
part 'ocr_request_dto.g.dart';

/// Wire format for `process-receipt`. `images` are base64 strings (no
/// `data:` prefix); the function inspects bytes to detect format.
@freezed
abstract class OcrRequestDto with _$OcrRequestDto {
  const factory OcrRequestDto({
    required List<String> images,
    String? hint,
  }) = _OcrRequestDto;

  factory OcrRequestDto.fromJson(Map<String, dynamic> json) =>
      _$OcrRequestDtoFromJson(json);
}
