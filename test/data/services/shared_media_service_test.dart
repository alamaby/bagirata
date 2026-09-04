import 'package:bagistruk/data/services/shared_media_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

void main() {
  group('SharedMediaService.mapToImages', () {
    test('keeps images typed by the plugin', () {
      final media = [
        SharedMediaFile(path: '/tmp/a.jpg', type: SharedMediaType.image),
      ];
      final result = SharedMediaService.mapToImages(media);
      expect(result.single.path, '/tmp/a.jpg');
    });

    test('keeps entries with image mime type even if typed as file', () {
      final media = [
        SharedMediaFile(
          path: '/tmp/b.png',
          type: SharedMediaType.file,
          mimeType: 'image/png',
        ),
      ];
      final result = SharedMediaService.mapToImages(media);
      expect(result.single.path, '/tmp/b.png');
    });

    test('drops video, text, url and empty paths', () {
      final media = [
        SharedMediaFile(
          path: '/tmp/c.mp4',
          type: SharedMediaType.video,
          mimeType: 'video/mp4',
        ),
        SharedMediaFile(
          path: 'https://example.com',
          type: SharedMediaType.url,
        ),
        SharedMediaFile(path: '', type: SharedMediaType.image),
        SharedMediaFile(
          path: '/tmp/d.pdf',
          type: SharedMediaType.file,
          mimeType: 'application/pdf',
        ),
      ];
      expect(SharedMediaService.mapToImages(media), isEmpty);
    });

    test('caps at maxSharedImages', () {
      final media = List.generate(
        SharedMediaService.maxSharedImages + 5,
        (i) => SharedMediaFile(
          path: '/tmp/$i.jpg',
          type: SharedMediaType.image,
        ),
      );
      final result = SharedMediaService.mapToImages(media);
      expect(result.length, SharedMediaService.maxSharedImages);
    });
  });
}
