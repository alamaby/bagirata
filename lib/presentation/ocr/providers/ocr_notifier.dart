import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../data/providers.dart';
import '../../../domain/entities/ocr_result.dart';

part 'ocr_notifier.freezed.dart';
part 'ocr_notifier.g.dart';

/// State for the OCR flow. A discriminated union (rather than nullable fields
/// on a single record) so the UI's `switch` is exhaustive and impossible
/// states (e.g. "processing" + "success" simultaneously) cannot be expressed.
@freezed
sealed class OcrState with _$OcrState {
  const factory OcrState.idle() = OcrIdle;
  const factory OcrState.processing(int imageCount) = OcrProcessing;
  const factory OcrState.success(OcrResult result) = OcrSuccess;
  const factory OcrState.failure(Failure failure) = OcrFailure;
}

@riverpod
class OcrNotifier extends _$OcrNotifier {
  @override
  OcrState build() => const OcrState.idle();

  Future<void> process(List<Uint8List> images, {String? hint}) async {
    state = OcrState.processing(images.length);
    final repo = ref.read(ocrRepositoryProvider);
    final res = await repo.processReceipt(images, hint: hint);
    state = switch (res) {
      Success(:final data) => OcrState.success(data),
      ResultFailure(:final failure) => OcrState.failure(failure),
    };
  }

  void reset() => state = const OcrState.idle();
}
