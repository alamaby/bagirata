import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

enum ReceiptPreviewMode { carousel, grid }

/// Reusable preview for one or many receipt images.
///
/// - **Carousel** is the default for capture flow (full-image inspection,
///   pinch-to-zoom).
/// - **Grid** is for the review/upload step where users want to scan many
///   thumbnails at once and remove duplicates.
///
/// All sizing flows through ScreenUtil so the same widget renders correctly
/// on the iPhone 12 baseline (390×844) and the larger Android targets.
class ReceiptPreviewComponent extends StatefulWidget {
  const ReceiptPreviewComponent({
    super.key,
    required this.images,
    required this.onRemove,
    this.mode = ReceiptPreviewMode.carousel,
    this.busy = false,
  });

  final List<XFile> images;
  final ValueChanged<int> onRemove;
  final ReceiptPreviewMode mode;
  final bool busy;

  @override
  State<ReceiptPreviewComponent> createState() =>
      _ReceiptPreviewComponentState();
}

class _ReceiptPreviewComponentState extends State<ReceiptPreviewComponent> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return _EmptyState();
    }
    return widget.mode == ReceiptPreviewMode.carousel
        ? _buildCarousel(context)
        : _buildGrid(context);
  }

  Widget _buildCarousel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 320.h,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final file = widget.images[i];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Card(
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          side: BorderSide(
                            color: scheme.primary,
                            width: 2,
                          ),
                        ),
                        child: InteractiveViewer(
                          child: _ImageThumb(file: file, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    if (widget.busy)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: _ScanningLottieOverlay(),
                        ),
                      ),
                    Positioned(
                      top: -6.h,
                      right: -6.w,
                      child: _RemoveButton(
                        onPressed: () => widget.onRemove(i),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.images.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: i == _page ? 14.w : 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: i == _page
                    ? scheme.primary
                    : scheme.outlineVariant,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.w,
        crossAxisSpacing: 10.w,
      ),
      itemCount: widget.images.length,
      itemBuilder: (context, i) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Card(
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: BorderSide(color: scheme.primary, width: 1.5),
                ),
                child: _ImageThumb(file: widget.images[i], fit: BoxFit.cover),
              ),
            ),
            if (widget.busy)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: _ScanningLottieOverlay(),
                ),
              ),
            Positioned(
              top: -6.h,
              right: -6.w,
              child: _RemoveButton(onPressed: () => widget.onRemove(i)),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 320.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: ganti placeholder ini dengan Lottie/SVG ilustrasi final.
            Container(
              width: 180.w,
              height: 180.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.08),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.receipt_long_rounded,
                size: 96.r,
                color: scheme.primary.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'Ambil foto struk belanja atau makan bareng untuk mulai berbagi adil!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(
              begin: 0.05,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOut,
            ),
      ),
    );
  }
}

class _ScanningLottieOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      alignment: Alignment.center,
      // TODO: ganti dengan Lottie asset final (mis. 'assets/lottie/scanning.json').
      child: Lottie.asset(
        'assets/lottie/scanning.json',
        width: 180.w,
        height: 180.w,
        repeat: true,
        errorBuilder: (context, error, stack) => SizedBox(
          width: 64.w,
          height: 64.w,
          child: const CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.file, required this.fit});
  final XFile file;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: file.readAsBytes(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          );
        }
        return Image.memory(snap.data!, fit: fit);
      },
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      color: scheme.surface,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(6.r),
          child: Icon(
            Icons.close_rounded,
            color: scheme.onSurface,
            size: 18.r,
          ),
        ),
      ),
    );
  }
}
