import 'dart:typed_data';

import 'package:bagistruk/core/error/result.dart';
import 'package:bagistruk/data/providers.dart';
import 'package:bagistruk/data/services/device_fingerprint_service.dart';
import 'package:bagistruk/data/services/image_picker_wrapper.dart';
import 'package:bagistruk/domain/entities/auth_snapshot.dart';
import 'package:bagistruk/domain/entities/ocr_credit_status.dart';
import 'package:bagistruk/domain/entities/ocr_result.dart';
import 'package:bagistruk/domain/repositories/i_auth_repository.dart';
import 'package:bagistruk/domain/repositories/i_ocr_repository.dart';
import 'package:bagistruk/domain/repositories/i_profile_repository.dart';
import 'package:bagistruk/presentation/ocr/providers/ocr_notifier.dart';
import 'package:bagistruk/presentation/ocr/providers/scan_draft_notifier.dart';
import 'package:bagistruk/presentation/ocr/providers/shared_auto_scan_provider.dart';
import 'package:bagistruk/presentation/ocr/screens/receipt_capture_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/widget_test_harness.dart';
import 'share_auto_scan_screen_test.mocks.dart';

@GenerateMocks([IAuthRepository, IProfileRepository, IOCRRepository])
void main() {
  late Uint8List pngBytes;

  setUpAll(() async {
    // A decodable 1x1 PNG kept in memory: the preview widget renders draft
    // bytes, so arbitrary bytes would throw an image-codec exception.
    // Encoded here (outside testWidgets) because dart:io-adjacent work
    // inside the widget-test zone proved unreliable; XFile.fromData keeps
    // the pump itself free of real file IO (`readAsBytes` is then pure
    // memory). Single image on purpose: fromData paths are all empty, so
    // two of them would trip the draft's share dedup.
    pngBytes = img.encodePng(img.Image(width: 1, height: 1));
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad(
      mergeWith: {
        'ADS_ENABLED': 'false',
        'SUPABASE_URL': 'http://test',
        'SUPABASE_ANON_KEY': 'test',
        'GOOGLE_WEB_CLIENT_ID': 'test',
      },
    );
    provideDummy<Result<String>>(const Result.success('uid'));
    provideDummy<Result<OcrResult>>(
      const Result.success(
        OcrResult(items: [], providerUsed: 'test', confidence: 0),
      ),
    );
    provideDummy<Result<OcrCreditStatus>>(
      const Result.success(
        OcrCreditStatus(
          planCode: 'free',
          balance: 10,
          monthlyAllowance: 20,
          adsEnabled: true,
          plusFeaturesEnabled: false,
        ),
      ),
    );
    provideDummy<AuthSnapshot>(
      const AuthSnapshot(userId: null, isAnonymous: true),
    );
  });

  ProviderContainer createContainer({
    required MockIAuthRepository auth,
    required MockIProfileRepository profiles,
    required MockIOCRRepository ocr,
  }) {
    when(auth.currentUserId).thenReturn(null);
    when(auth.isAnonymous).thenReturn(true);
    when(auth.watchAuthState()).thenAnswer(
      (_) => const Stream<AuthSnapshot>.empty(),
    );
    when(auth.ensureSignedIn()).thenAnswer(
      (_) async => const Result.success('uid'),
    );
    // Empty items + zero confidence hits the not-a-receipt guard, which
    // resets without navigating — safe to pump without a GoRouter.
    // Named args must be spelled out: the screen passes non-null
    // currency/fingerprintHeaders, and an unstated named parameter only
    // matches calls that omit it.
    when(
      ocr.processReceipt(
        any,
        hint: anyNamed('hint'),
        currency: anyNamed('currency'),
        fingerprintHeaders: anyNamed('fingerprintHeaders'),
      ),
    ).thenAnswer(
      (_) async => const Result.success(
        OcrResult(items: [], providerUsed: 'test', confidence: 0),
      ),
    );
    when(profiles.getOcrCreditStatus()).thenAnswer(
      (_) async => const Result.success(
        OcrCreditStatus(
          planCode: 'free',
          balance: 10,
          monthlyAllowance: 20,
          adsEnabled: true,
          plusFeaturesEnabled: false,
        ),
      ),
    );
    return ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(profiles),
        ocrRepositoryProvider.overrideWithValue(ocr),
        imagePickerProvider.overrideWithValue(_FakeImagePicker()),
        deviceFingerprintServiceProvider.overrideWithValue(
          _FakeFingerprintService(),
        ),
      ],
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    // Match the production design size so the preview empty-state fits.
    await setTestViewport(tester);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: buildTestApp(child: const ReceiptCaptureScreen()),
      ),
    );
    // No pumpAndSettle: BannerAdController schedules retries on a timer,
    // so the frame scheduler never settles. Pump fixed frames instead —
    // enough for the post-frame auto-scan trigger and the mocked OCR
    // round-trip to complete.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('ReceiptCaptureScreen share auto-scan', () {
    testWidgets('pending flag with draft images triggers one OCR run', (
      tester,
    ) async {
      final auth = MockIAuthRepository();
      final profiles = MockIProfileRepository();
      final ocr = MockIOCRRepository();
      final container = createContainer(
        auth: auth,
        profiles: profiles,
        ocr: ocr,
      );
      addTearDown(container.dispose);

      final added = container.read(scanDraftProvider.notifier).addSharedFiles([
        XFile.fromData(pngBytes, name: 'a.png', mimeType: 'image/png'),
      ]);
      expect(added, 1);
      container.read(sharedAutoScanProvider.notifier).request(1);

      await pumpScreen(tester, container);

      verify(
        ocr.processReceipt(
          any,
          hint: anyNamed('hint'),
          currency: anyNamed('currency'),
          fingerprintHeaders: anyNamed('fingerprintHeaders'),
        ),
      ).called(1);
      // The empty-items + zero-confidence payload hits the not-a-receipt
      // guard, which clears the draft and resets the OCR state (and shows
      // a localized hint).
      expect(container.read(sharedAutoScanProvider).pending, isFalse);
      expect(container.read(scanDraftProvider).images, isEmpty);
      expect(container.read(ocrProvider), isA<OcrIdle>());
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('no pending flag means no automatic OCR run', (tester) async {
      final auth = MockIAuthRepository();
      final profiles = MockIProfileRepository();
      final ocr = MockIOCRRepository();
      final container = createContainer(
        auth: auth,
        profiles: profiles,
        ocr: ocr,
      );
      addTearDown(container.dispose);

      container.read(scanDraftProvider.notifier).addSharedFiles([
        XFile.fromData(pngBytes, name: 'a.png', mimeType: 'image/png'),
      ]);

      await pumpScreen(tester, container);

      verifyNever(
        ocr.processReceipt(
          any,
          hint: anyNamed('hint'),
          currency: anyNamed('currency'),
          fingerprintHeaders: anyNamed('fingerprintHeaders'),
        ),
      );
    });

    testWidgets('pending flag with empty draft is dropped without scanning', (
      tester,
    ) async {
      final auth = MockIAuthRepository();
      final profiles = MockIProfileRepository();
      final ocr = MockIOCRRepository();
      final container = createContainer(
        auth: auth,
        profiles: profiles,
        ocr: ocr,
      );
      addTearDown(container.dispose);

      container.read(sharedAutoScanProvider.notifier).request(2);

      await pumpScreen(tester, container);

      verifyNever(ocr.processReceipt(any));
      expect(container.read(sharedAutoScanProvider).pending, isFalse);
    });
  });
}

class _FakeImagePicker implements IImagePicker {
  @override
  Future<List<XFile>> pickMultiImage({int? imageQuality}) async => [];

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    int? imageQuality,
  }) async => null;
}

class _FakeFingerprintService extends DeviceFingerprintService {
  @override
  Future<Map<String, String>> collectHeaders({context}) async => {};
}
