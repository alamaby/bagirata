import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

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
  });

  final List<XFile> images;
  final ValueChanged<int> onRemove;
  final ReceiptPreviewMode mode;

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
      return SizedBox(
        height: 220.h,
        child: const Center(child: Text('No images selected')),
      );
    }
    return widget.mode == ReceiptPreviewMode.carousel
        ? _buildCarousel(context)
        : _buildGrid(context);
  }

  Widget _buildCarousel(BuildContext context) {
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
              return Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveViewer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: _ImageThumb(file: file, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: _RemoveButton(
                      onPressed: () => widget.onRemove(i),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
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
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8.w,
        crossAxisSpacing: 8.w,
      ),
      itemCount: widget.images.length,
      itemBuilder: (context, i) {
        return Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: _ImageThumb(file: widget.images[i], fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 4.h,
              right: 4.w,
              child: _RemoveButton(onPressed: () => widget.onRemove(i)),
            ),
          ],
        );
      },
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
          return Container(color: Theme.of(context).colorScheme.surfaceContainerHighest);
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
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(4.r),
          child: Icon(Icons.close, color: Colors.white, size: 16.r),
        ),
      ),
    );
  }
}
