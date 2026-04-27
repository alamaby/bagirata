import 'dart:typed_data';

import '../../core/error/result.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/repositories/i_ocr_repository.dart';
import '../services/ocr_service.dart';

class OcrRepositoryImpl implements IOCRRepository {
  OcrRepositoryImpl(this._service);
  final OCRService _service;

  @override
  Future<Result<OcrResult>> processReceipt(
    List<Uint8List> imagesBytes, {
    String? hint,
  }) async {
    final res = await _service.processReceipt(imagesBytes, hint: hint);
    return switch (res) {
      Success(:final data) => Result.success(data.toEntity()),
      ResultFailure(:final failure) => Result.failure(failure),
    };
  }
}
