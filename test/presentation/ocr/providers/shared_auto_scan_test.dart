import 'package:bagistruk/data/providers.dart';
import 'package:bagistruk/data/services/image_picker_wrapper.dart';
import 'package:bagistruk/presentation/ocr/providers/scan_draft_notifier.dart';
import 'package:bagistruk/presentation/ocr/providers/shared_auto_scan_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  group('ScanDraftNotifier.addSharedFiles', () {
    test('appends fresh paths and returns the added count', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(scanDraftProvider.notifier);

      final added = notifier.addSharedFiles([
        XFile('/tmp/share-a.jpg'),
        XFile('/tmp/share-b.jpg'),
      ]);

      expect(added, 2);
      expect(
        container.read(scanDraftProvider).images.map((f) => f.path),
        ['/tmp/share-a.jpg', '/tmp/share-b.jpg'],
      );
    });

    test('skips duplicate paths from repeated intents', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(scanDraftProvider.notifier);

      expect(
        notifier.addSharedFiles([XFile('/tmp/share-a.jpg')]),
        1,
      );
      // Cold-start initial intent followed by the same stream event.
      expect(
        notifier.addSharedFiles([
          XFile('/tmp/share-a.jpg'),
          XFile('/tmp/share-b.jpg'),
        ]),
        1,
      );
      expect(
        container.read(scanDraftProvider).images.map((f) => f.path),
        ['/tmp/share-a.jpg', '/tmp/share-b.jpg'],
      );
    });

    test('empty input is a no-op returning zero', () {
      final container = _createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(scanDraftProvider.notifier);
      expect(notifier.addSharedFiles([]), 0);
      expect(container.read(scanDraftProvider).images, isEmpty);
    });
  });

  group('SharedAutoScan', () {
    test('request sets pending; consume clears it', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(sharedAutoScanProvider).pending, isFalse);
      container.read(sharedAutoScanProvider.notifier).request(3);
      expect(container.read(sharedAutoScanProvider), (
        pending: true,
        imageCount: 3,
      ));
      container.read(sharedAutoScanProvider.notifier).consume();
      expect(container.read(sharedAutoScanProvider), (
        pending: false,
        imageCount: 0,
      ));
    });

    test('request with zero count is ignored', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(sharedAutoScanProvider.notifier).request(0);
      expect(container.read(sharedAutoScanProvider).pending, isFalse);
    });

    test('consume without pending is a no-op', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(sharedAutoScanProvider.notifier).consume();
      expect(container.read(sharedAutoScanProvider).pending, isFalse);
    });
  });
}

ProviderContainer _createContainer() => ProviderContainer(
  overrides: [imagePickerProvider.overrideWithValue(_FakeImagePicker())],
);

class _FakeImagePicker implements IImagePicker {
  @override
  Future<List<XFile>> pickMultiImage({int? imageQuality}) async => [];

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    int? imageQuality,
  }) async => null;
}
