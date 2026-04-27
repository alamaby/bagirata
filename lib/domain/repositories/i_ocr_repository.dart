import 'dart:typed_data';

import '../../core/error/result.dart';
import '../entities/ocr_result.dart';

abstract interface class IOCRRepository {
  /// [imagesBytes] are raw bytes of one or more receipt photos. The repository
  /// is responsible for downscaling/encoding before invoking the Edge Function.
  Future<Result<OcrResult>> processReceipt(
    List<Uint8List> imagesBytes, {
    String? hint,
  });
}
