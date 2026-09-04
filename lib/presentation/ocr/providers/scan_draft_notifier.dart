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

  @override
  ScanDraftState build() => const ScanDraftState(images: []);

  IImagePicker get _picker => ref.read(imagePickerProvider);

  Future<void> pickFromGallery() async {
    final picked = await _picker.pickMultiImage(imageQuality: _imageQuality);
    if (picked.isEmpty) return;
    state = ScanDraftState(images: [...state.images, ...picked]);
  }

  Future<XFile?> pickFromCamera() async {
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
    state = ScanDraftState(images: [...state.images, ...fresh]);
    return fresh.length;
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
