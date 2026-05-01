import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/error/result.dart';
import '../../../core/router/routes.dart';
import '../../../data/providers.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../providers/ocr_notifier.dart';
import '../utils/ocr_messages.dart';
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
    // Tunggu satu frame paint dulu — tanpa ini, await pertama langsung
    // melanjutkan ke file IO + isolate dispatch sebelum engine sempat render
    // overlay loading, jadi user melihat tombol "membeku" beberapa ratus ms.
    await SchedulerBinding.instance.endOfFrame;
    try {
      // Lazy session bootstrap: pastikan ada `auth.uid()` sebelum OCR &
      // insert bill. Idempotent — kalau session login email/anon sudah ada,
      // tidak melakukan apa-apa.
      final ensured = await ref.read(authRepositoryProvider).ensureSignedIn();
      if (ensured is ResultFailure<String> && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal siapkan sesi: ${ensured.failure}')),
        );
        return;
      }
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
        final msg = friendlyOcrMessage(next.failure);
        final scheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: scheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              content: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: scheme.onErrorContainer, size: 20.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      msg.title,
                      style: TextStyle(
                        color: scheme.onErrorContainer,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
      }
    });
    final state = ref.watch(ocrProvider);
    final busy = _starting || state is OcrProcessing;
    final scanActive = _images.isNotEmpty && !busy;
    final l10n = AppL10n.of(context);
    return AppScaffold(
      title: l10n.scanScreenTitle,
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
            if (state is OcrFailure)
              _ErrorCard(
                message: friendlyOcrMessage(state.failure),
                onDismiss: () => ref.read(ocrProvider.notifier).reset(),
              )
            else
              _StatusLabel(state: state, starting: _starting),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : _addImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text(l10n.scanAddPhotos),
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
                      label: Text(busy ? l10n.scanInProgress : l10n.scanAction),
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
            OcrFailure() => '',
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

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onDismiss});

  final OcrMessage message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: scheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              color: scheme.onErrorContainer,
              size: 20.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: scheme.onErrorContainer,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message.body,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.4,
                    color: scheme.onErrorContainer.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          IconButton(
            tooltip: 'Tutup',
            visualDensity: VisualDensity.compact,
            iconSize: 18.r,
            onPressed: onDismiss,
            icon: Icon(Icons.close, color: scheme.onErrorContainer),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
  }
}
