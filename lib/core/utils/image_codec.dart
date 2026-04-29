import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../config/app_constants.dart';

/// Pure helpers for preparing images for the OCR Edge Function.
///
/// Why downscale before upload: Gemini/OpenRouter charge per image token, and
/// receipts past ~1600px add cost without measurably improving extraction.
///
/// Why off-isolate: `img.decodeImage`/`copyResize`/`encodeJpg` are pure-Dart
/// synchronous CPU work — running them on the main isolate blocks the UI for
/// 800-1500ms per receipt, which delays the scanning animation by several
/// frames. We dispatch through `Isolate.run` so the main thread stays free to
/// paint the loading overlay the instant the user taps Scan.
class ImageCodec {
  const ImageCodec._();

  /// Decodes [bytes], rescales so the long edge ≤ [AppConstants.ocrMaxImageEdgePx],
  /// re-encodes as JPEG q85, and returns base64 (no `data:` prefix).
  static Future<String> downscaleToBase64(Uint8List bytes) {
    return Isolate.run(() => _downscaleToBase64Sync(bytes));
  }
}

/// Top-level so it can be sent to a background isolate without capturing
/// closure state from the caller.
String _downscaleToBase64Sync(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('Unsupported or corrupt image bytes');
  }
  final longEdge =
      decoded.width > decoded.height ? decoded.width : decoded.height;
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
  final encoded = img.encodeJpg(resized, quality: 85);
  return base64Encode(encoded);
}
