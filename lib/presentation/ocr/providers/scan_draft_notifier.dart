import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/providers.dart';
import '../../../data/services/image_picker_wrapper.dart';

part 'scan_draft_notifier.freezed.dart';
part 'scan_draft_notifier.g.dart';

/// Draft state for the multi-photo receipt capture flow. Held in a
/// `keepAlive` provider so the picked images survive any redirect that
/// pops the user out of the scan tab (e.g. the legal-acceptance gate
/// firing mid-flow on first scan) — the user does not lose their work
/// when they come back. The previous design kept `_images` in the
/// `StatefulWidget` and the legal round-trip wiped them, which was a
/// blocking UX issue.
@freezed
sealed class ScanDraftState with _$ScanDraftState {
  const factory ScanDraftState({required List<XFile> images}) = _ScanDraftState;
}

@Riverpod(keepAlive: true)
class ScanDraftNotifier extends _$ScanDraftNotifier {
  static const _imageQuality = 90;

  /// M4/F14.3 client mirror of the Edge Function `OCR_MAX_IMAGES` guard.
  /// Enforced at every draft entry point (gallery, camera, share-in) so an
  /// over-cap draft can never reach the network — the server 413 becomes a
  /// defensive backstop, not the primary UX.
  static const maxImages = 10;

  /// True once the draft hit [maxImages]; pickers should refuse with a
  /// friendly message instead of silently dropping photos.
  bool get isFull => state.images.length >= maxImages;

  @override
  ScanDraftState build() => const ScanDraftState(images: []);

  IImagePicker get _picker => ref.read(imagePickerProvider);

  /// Picks from gallery, keeping only what fits under [maxImages].
  /// Returns the number of picked photos dropped by the cap (0 = all kept).
  Future<int> pickFromGallery() async {
    final picked = await _picker.pickMultiImage(imageQuality: _imageQuality);
    if (picked.isEmpty) return 0;
    final room = maxImages - state.images.length;
    if (room <= 0) return picked.length;
    final kept = picked.take(room).toList(growable: false);
    state = ScanDraftState(images: [...state.images, ...kept]);
    return picked.length - kept.length;
  }

  /// Returns null when the user cancels OR the draft is full ([isFull]);
  /// callers must check [isFull] first to tell the two apart.
  Future<XFile?> pickFromCamera() async {
    if (isFull) return null;
    final shot = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: _imageQuality,
    );
    if (shot != null) {
      state = ScanDraftState(images: [...state.images, shot]);
    }
    return shot;
  }

  /// Appends images received via Android share (`SEND` / `SEND_MULTIPLE`)
  /// to the draft. Entries whose path is already in the draft are skipped
  /// so a cold-start initial intent followed by the same stream event does
  /// not duplicate images. Returns the number of images actually added.
  int addSharedFiles(List<XFile> files) {
    if (files.isEmpty) return 0;
    final known = state.images.map((f) => f.path).toSet();
    final fresh = files.where((f) => known.add(f.path)).toList();
    if (fresh.isEmpty) return 0;
    // Same [maxImages] cap as the pickers; the `_process` guard below
    // stays as a defensive backstop for drafts built before this cap.
    final room = maxImages - state.images.length;
    if (room <= 0) return 0;
    final kept = fresh.take(room).toList(growable: false);
    state = ScanDraftState(images: [...state.images, ...kept]);
    return kept.length;
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.images.length) return;
    final next = [...state.images]..removeAt(index);
    state = ScanDraftState(images: next);
  }

  /// Drop the draft after a successful scan lands the user in the review
  /// screen — they no longer need the picker results and we should not
  /// leak references to the underlying temp files.
  void clear() {
    if (state.images.isEmpty) return;
    state = const ScanDraftState(images: []);
  }
}
