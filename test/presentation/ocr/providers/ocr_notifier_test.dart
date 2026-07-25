import 'dart:async';
import 'dart:typed_data';

import 'package:bagistruk/core/error/failure.dart';
import 'package:bagistruk/core/error/result.dart';
import 'package:bagistruk/data/providers.dart';
import 'package:bagistruk/domain/entities/ocr_result.dart';
import 'package:bagistruk/domain/repositories/i_ocr_repository.dart';
import 'package:bagistruk/presentation/ocr/providers/ocr_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ocr_notifier_test.mocks.dart';

@GenerateMocks([IOCRRepository])
void main() {
  late MockIOCRRepository mockRepo;
  late ProviderContainer container;
  late ProviderSubscription<OcrState> subscription;

  setUpAll(() {
    provideDummy<Result<OcrResult>>(
      const Result.success(
        OcrResult(
          items: [OcrLineItem(name: 'A', price: 100, qty: 1)],
          providerUsed: 'gemini',
        ),
      ),
    );
  });

  setUp(() {
    mockRepo = MockIOCRRepository();
    container = ProviderContainer(
      overrides: [ocrRepositoryProvider.overrideWithValue(mockRepo)],
    );
    // Keep the autoDispose notifier alive for the duration of each test so we
    // can observe intermediate state transitions.
    subscription = container.listen<OcrState>(
      ocrProvider,
      (previous, next) {},
    );
    addTearDown(() {
      subscription.close();
      container.dispose();
    });
  });

  test('build returns OcrIdle', () {
    expect(container.read(ocrProvider), isA<OcrIdle>());
  });

  group('process', () {
    test('success transitions idle -> processing -> success', () async {
      final completer = Completer<Result<OcrResult>>();
      const result = OcrResult(
        items: [OcrLineItem(name: 'Kopi', price: 18000, qty: 2)],
        detectedTotal: 36000,
        providerUsed: 'gemini',
      );
      when(mockRepo.processReceipt(any)).thenAnswer((_) => completer.future);

      final future = container
          .read(ocrProvider.notifier)
          .process([Uint8List.fromList([1, 2, 3])]);

      // Yield once so the synchronous state change inside `process` is
      // observed before the awaited repository call resolves.
      await Future<void>.delayed(Duration.zero);
      final processing = container.read(ocrProvider);
      expect(processing, isA<OcrProcessing>());
      expect((processing as OcrProcessing).imageCount, 1);

      completer.complete(const Result.success(result));
      await future;

      final state = container.read(ocrProvider);
      expect(state, isA<OcrSuccess>());
      expect((state as OcrSuccess).result, result);
    });

    test('failure transitions to OcrFailure with the mapped failure', () async {
      when(mockRepo.processReceipt(any)).thenAnswer(
        (_) async => const Result.failure(
          Failure.network('no internet'),
        ),
      );

      await container
          .read(ocrProvider.notifier)
          .process([Uint8List.fromList([0])]);

      final state = container.read(ocrProvider);
      expect(state, isA<OcrFailure>());
      expect((state as OcrFailure).failure, isA<NetworkFailure>());
    });

    test('processing state reflects image count', () async {
      final completer = Completer<Result<OcrResult>>();
      when(mockRepo.processReceipt(any)).thenAnswer((_) => completer.future);

      final images = List.generate(3, (_) => Uint8List.fromList([0]));

      final future = container
          .read(ocrProvider.notifier)
          .process(images);

      await Future<void>.delayed(Duration.zero);
      final processing = container.read(ocrProvider);
      expect(processing, isA<OcrProcessing>());
      expect((processing as OcrProcessing).imageCount, 3);

      completer.complete(
        const Result.success(
          OcrResult(
            items: [OcrLineItem(name: 'A', price: 100, qty: 1)],
            providerUsed: 'gemini',
          ),
        ),
      );
      await future;

      expect(container.read(ocrProvider), isA<OcrSuccess>());
    });

    test('forwards hint and currency to repository', () async {
      when(
        mockRepo.processReceipt(
          any,
          hint: 'menu includes 11% PB1',
          currency: 'IDR',
          fingerprintHeaders: null,
        ),
      ).thenAnswer(
        (_) async => const Result.success(
          OcrResult(
            items: [OcrLineItem(name: 'A', price: 100, qty: 1)],
            providerUsed: 'gemini',
          ),
        ),
      );

      await container.read(ocrProvider.notifier).process(
        [Uint8List.fromList([0])],
        hint: 'menu includes 11% PB1',
        currency: 'IDR',
      );

      verify(
        mockRepo.processReceipt(
          any,
          hint: 'menu includes 11% PB1',
          currency: 'IDR',
          fingerprintHeaders: null,
        ),
      ).called(1);
    });
  });

  test('reset returns state to idle', () async {
    when(mockRepo.processReceipt(any)).thenAnswer(
      (_) async => const Result.success(
        OcrResult(
          items: [OcrLineItem(name: 'A', price: 100, qty: 1)],
          providerUsed: 'gemini',
        ),
      ),
    );

    await container.read(ocrProvider.notifier).process(
      [Uint8List.fromList([0])],
    );
    expect(container.read(ocrProvider), isA<OcrSuccess>());

    container.read(ocrProvider.notifier).reset();
    expect(container.read(ocrProvider), isA<OcrIdle>());
  });
}
