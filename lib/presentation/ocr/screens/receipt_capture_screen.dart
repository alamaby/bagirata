import 'package:flutter/material.dart';
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

  Future<void> _addImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 90);
    if (picked.isEmpty) return;
    setState(() => _images.addAll(picked));
  }

  Future<void> _process() async {
    final bytes = await Future.wait(_images.map((f) => f.readAsBytes()));
    await ref.read(ocrProvider.notifier).process(bytes);
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
                  onRemove: (i) => setState(() => _images.removeAt(i)),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            _StatusLabel(state: state),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add photos'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _images.isEmpty || state is OcrProcessing
                        ? null
                        : _process,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Scan'),
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
  const _StatusLabel({required this.state});
  final OcrState state;

  @override
  Widget build(BuildContext context) {
    final text = switch (state) {
      OcrIdle() => 'Add photos and tap Scan',
      OcrProcessing(:final imageCount) => 'Scanning $imageCount image(s)…',
      OcrSuccess(:final result) =>
        '${result.items.length} items detected via ${result.providerUsed}',
      OcrFailure(:final failure) => 'Failed: $failure',
    };
    return Text(text, style: TextStyle(fontSize: 13.sp));
  }
}

