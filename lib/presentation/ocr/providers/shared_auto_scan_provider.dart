import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shared_auto_scan_provider.g.dart';

/// One-shot flag requesting the scan screen to auto-run the OCR pipeline
/// for images that arrived via Android share.
///
/// The flag is set when a share intent is received and consumed by
/// `ReceiptCaptureScreen` on first paint. It stays pending across router
/// gates (legal acceptance / onboarding / welcome) so the auto-scan fires
/// only once the scan screen is actually visible — never blindly from the
/// background listener, which lacks the `BuildContext` and mounted checks
/// `_process()` needs.
@Riverpod(keepAlive: true)
class SharedAutoScan extends _$SharedAutoScan {
  @override
  ({bool pending, int imageCount}) build() =>
      (pending: false, imageCount: 0);

  void request(int imageCount) {
    if (imageCount <= 0) return;
    state = (pending: true, imageCount: imageCount);
  }

  void consume() {
    if (!state.pending) return;
    state = (pending: false, imageCount: 0);
  }
}
