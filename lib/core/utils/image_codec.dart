import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../config/app_constants.dart';

/// Pure helpers for preparing images for the OCR Edge Function.
///
/// Why downscale before upload: Gemini/OpenRouter charge per image token, and
/// receipts past ~1600px add cost without measurably improving extraction.
class ImageCodec {
  const ImageCodec._();

  /// Decodes [bytes], rescales so the long edge ≤ [AppConstants.ocrMaxImageEdgePx],
  /// re-encodes as JPEG q85, and returns base64 (no `data:` prefix).
  static Future<String> downscaleToBase64(Uint8List bytes) async {
    final encoded = await _encode(bytes);
    return base64Encode(encoded);
  }

  static Future<Uint8List> _encode(Uint8List bytes) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      // Caller passed something we can't decode (HEIC w/o codec, corrupt, …).
      // Fail loud — datasource will translate to a ParsingFailure.
      throw const FormatException('Unsupported or corrupt image bytes');
    }
    final longEdge = decoded.width > decoded.height ? decoded.width : decoded.height;
    final resized = longEdge <= AppConstants.ocrMaxImageEdgePx
        ? decoded
        : img.copyResize(
            decoded,
            width: decoded.width >= decoded.height
                ? AppConstants.ocrMaxImageEdgePx
                : null,
            height: decoded.height > decoded.width
                ? AppConstants.ocrMaxImageEdgePx
                : null,
            interpolation: img.Interpolation.average,
          );
    return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
  }
}
