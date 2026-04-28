import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/routes.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../providers/ocr_notifier.dart';
import '../widgets/receipt_preview_component.dart';

/// Placeholder capture flow — wires together image_picker, the preview
/// component, and the OCR notifier so the foundation is end-to-end clickable.
/// Final UI/copy will land in a follow-up.
class ReceiptCaptureScreen extends ConsumerStatefulWidget {
  const ReceiptCaptureScreen({super.key});

  @override
  ConsumerState<ReceiptCaptureScreen> createState() =>
      _ReceiptCaptureScreenState();
}

class _ReceiptCaptureScreenState extends ConsumerState<ReceiptCaptureScreen> {
  final _picker = ImagePicker();
  final List<XFile> _images = [];
  ReceiptPreviewMode _mode = ReceiptPreviewMode.carousel;

  // Local "starting" flag supaya tombol langsung bereaksi saat di-tap.
  // Tanpa ini ada delay terlihat: bytes loading + downscale (~ratusan ms)
  // berjalan sebelum OcrNotifier sempat set state ke processing.
  bool _starting = false;

  Future<void> _addImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 90);
    if (picked.isEmpty) return;
    setState(() => _images.addAll(picked));
  }

  Future<void> _process() async {
    setState(() => _starting = true);
    try {
      final bytes = await Future.wait(_images.map((f) => f.readAsBytes()));
      await ref.read(ocrProvider.notifier).process(bytes);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<OcrState>(ocrProvider, (prev, next) {
      if (next is OcrSuccess && prev is! OcrSuccess) {
        ref.read(ocrProvider.notifier).reset();
        context.pushNamed(Routes.billReviewName, extra: next.result);
      }
      if (next is OcrFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal scan: ${next.failure}')),
        );
      }
    });
    final state = ref.watch(ocrProvider);
    final busy = _starting || state is OcrProcessing;
    final scanActive = _images.isNotEmpty && !busy;
    return AppScaffold(
      title: 'Scan receipt',
      actions: [
        IconButton(
          icon: Icon(_mode == ReceiptPreviewMode.carousel
              ? Icons.grid_view
              : Icons.view_carousel),
          onPressed: () => setState(() => _mode =
              _mode == ReceiptPreviewMode.carousel
                  ? ReceiptPreviewMode.grid
                  : ReceiptPreviewMode.carousel),
        ),
      ],
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ReceiptPreviewComponent(
                  images: _images,
                  mode: _mode,
                  busy: busy,
                  onRemove: (i) => setState(() => _images.removeAt(i)),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            _StatusLabel(state: state, starting: _starting),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : _addImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add photos'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: FilledButton.icon(
                      key: ValueKey<bool>(scanActive),
                      onPressed: scanActive ? _process : null,
                      icon: busy
                          ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(busy ? 'Scanning…' : 'Scan'),
                    )
                        .animate(target: scanActive ? 1 : 0)
                        .fadeIn(duration: 300.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 300.ms,
                          curve: Curves.easeOut,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.state, required this.starting});
  final OcrState state;
  final bool starting;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isProcessing = starting || state is OcrProcessing;
    final text = starting && state is! OcrProcessing
        ? 'Memproses gambar…'
        : switch (state) {
            OcrIdle() => 'Add photos and tap Scan',
            OcrProcessing(:final imageCount) =>
              'Scanning $imageCount image(s)…',
            OcrSuccess(:final result) =>
              '${result.items.length} items detected via ${result.providerUsed}',
            OcrFailure(:final failure) => 'Failed: $failure',
          };
    final label = Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        color: scheme.onSurfaceVariant,
        fontWeight: isProcessing ? FontWeight.w600 : FontWeight.w400,
      ),
    );
    if (!isProcessing) return label;
    return label
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: scheme.primary,
        );
  }
}
