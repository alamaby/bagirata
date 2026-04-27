import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_constants.dart';
import '../../core/error/exception_mapper.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../core/network/supabase_client_provider.dart';
import '../../core/utils/image_codec.dart';
import '../dtos/ocr_request_dto.dart';
import '../dtos/ocr_response_dto.dart';

part 'ocr_service.g.dart';

/// Single-responsibility client for the `process-receipt` Edge Function.
///
/// Lives in the data layer (not the repository) because it deals only with
/// transport: downscale → encode → invoke → parse. Provider failover (Gemini
/// → OpenRouter) is the Edge Function's concern, not the client's.
class OCRService {
  OCRService(this._client);
  final SupabaseClient _client;

  Future<Result<OcrResponseDto>> processReceipt(
    List<Uint8List> imagesBytes, {
    String? hint,
  }) {
    return guardAsync(() async {
      // Downscale + base64 in parallel — encoding is CPU-bound but the image
      // package releases the isolate between calls, so a Future.wait is fine.
      final encoded = await Future.wait(
        imagesBytes.map(ImageCodec.downscaleToBase64),
      );
      final request = OcrRequestDto(images: encoded, hint: hint);

      final response = await _client.functions.invoke(
        AppConstants.ocrEdgeFunctionName,
        body: request.toJson(),
      );

      if (response.status >= 400) {
        // FunctionException isn't always thrown for non-2xx — guard explicitly.
        throw FunctionException(
          status: response.status,
          details: response.data,
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('process-receipt returned non-object body');
      }
      return OcrResponseDto.fromJson(data);
    });
  }
}

@Riverpod(keepAlive: true)
OCRService ocrService(Ref ref) => OCRService(ref.watch(supabaseClientProvider));

// Re-export Failure so consumers don't need a second import just for typing.
typedef OcrFailure = Failure;
