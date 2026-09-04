import 'package:image_picker/image_picker.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Abstraction over `receive_sharing_intent` so the share-to-scan flow can
/// be unit-tested and the plugin swapped later without touching callers.
///
/// Only `image/*` entries are surfaced; text/video/other files shared into
/// the app are ignored because the OCR pipeline only accepts images.
abstract interface class ISharedMediaService {
  /// Shared media delivered while the app was closed (cold start).
  /// Must call [acknowledgeInitial] after consuming, per plugin contract.
  Future<List<XFile>> getInitialSharedImages();

  /// Shared media arriving while the app is already running.
  Stream<List<XFile>> get sharedImagesStream;

  /// Tells the plugin the initial intent was processed (clears it).
  void acknowledgeInitial();
}

class SharedMediaService implements ISharedMediaService {
  SharedMediaService([ReceiveSharingIntent? plugin])
    : _plugin = plugin ?? ReceiveSharingIntent.instance;

  final ReceiveSharingIntent _plugin;

  /// Max images accepted per share, aligned with the multi-photo scan draft.
  static const int maxSharedImages = 10;

  @override
  Future<List<XFile>> getInitialSharedImages() async {
    final media = await _plugin.getInitialMedia();
    return mapToImages(media);
  }

  @override
  Stream<List<XFile>> get sharedImagesStream =>
      _plugin.getMediaStream().map(mapToImages);

  @override
  void acknowledgeInitial() => _plugin.reset();

  /// Converts raw plugin entries to [XFile], keeping only images with a
  /// non-empty path, capped at [maxSharedImages].
  ///
  /// An entry counts as an image when the plugin typed it as
  /// [SharedMediaType.image] or its MIME type starts with `image/` (either
  /// signal may be absent depending on the sending app).
  static List<XFile> mapToImages(List<SharedMediaFile> media) {
    return media
        .where(
          (m) =>
              m.type == SharedMediaType.image ||
              (m.mimeType ?? '').toLowerCase().startsWith('image/'),
        )
        .where((m) => m.path.isNotEmpty)
        .take(maxSharedImages)
        .map((m) => XFile(m.path))
        .toList();
  }
}
