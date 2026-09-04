import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/result.dart';
import '../../../core/router/routes.dart';
import '../../../data/providers.dart';
import '../../../data/services/device_fingerprint_service.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../../../core/ads/ad_config.dart';
import '../../ads/widgets/banner_ad_widget.dart';
import '../../credits/providers/ocr_credit_status_provider.dart';
import '../../settings/providers/preferences_providers.dart';
import '../../settings/providers/profile_notifier.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../providers/ocr_notifier.dart';
import '../providers/scan_draft_notifier.dart';
import '../providers/shared_auto_scan_provider.dart';
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
  ReceiptPreviewMode _mode = ReceiptPreviewMode.carousel;

  // Local "starting" flag supaya tombol langsung bereaksi saat di-tap.
  // Tanpa ini ada delay terlihat: bytes loading + downscale (~ratusan ms)
  // berjalan sebelum OcrNotifier sempat set state ke processing.
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    // Share-to-scan: a share intent set the pending flag before routing
    // here. Run after first paint — the router gates (legal / onboarding /
    // welcome) already resolved since this screen is actually visible.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoScan());
  }

  /// Fires the one-shot auto-scan requested by an Android share intent.
  /// No-op when there is no pending request, the draft is empty, or a
  /// scan is already running.
  Future<void> _maybeAutoScan() async {
    if (!mounted) return;
    final request = ref.read(sharedAutoScanProvider);
    if (!request.pending) return;
    ref.read(sharedAutoScanProvider.notifier).consume();
    if (!mounted) return;
    if (ref.read(scanDraftProvider).images.isEmpty) return;
    final state = ref.read(ocrProvider);
    if (_starting || state is OcrProcessing) {
      // Rare: user tapped Scan manually in the same frame the share
      // landed. Their manual scan wins; drop the auto request.
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            AppL10n.of(context).shareImagesAdded(request.imageCount),
          ),
        ),
      );
    await _process();
  }

  Future<void> _addFromGallery() async {
    await ref.read(scanDraftProvider.notifier).pickFromGallery();
  }

  Future<void> _addFromCamera() async {
    final l10n = AppL10n.of(context);
    while (true) {
      final shot = await ref.read(scanDraftProvider.notifier).pickFromCamera();
      if (shot == null) return;
      if (!mounted) return;

      final again = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(l10n.scanCameraContinuePrompt),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.scanCameraDone),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.scanCameraTakeAnother),
            ),
          ],
        ),
      );
      if (again != true) return;
      if (!mounted) return;
    }
  }

  Future<void> _showAddPhotoSheet() async {
    final l10n = AppL10n.of(context);
    final source = await showModalBottomSheet<_PhotoSource>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.scanSourceSheetTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(l10n.scanSourceCamera),
              onTap: () => Navigator.of(ctx).pop(_PhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.scanSourceGallery),
              onTap: () => Navigator.of(ctx).pop(_PhotoSource.gallery),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    switch (source) {
      case _PhotoSource.camera:
        await _addFromCamera();
      case _PhotoSource.gallery:
        await _addFromGallery();
    }
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
          SnackBar(
            content: Text(
              AppL10n.of(
                context,
              ).scanPreparingSessionFailed(ensured.failure.toString()),
            ),
          ),
        );
        return;
      }
      final canScan = await _checkOcrCredit();
      if (!canScan) return;
      final draft = ref.read(scanDraftProvider).images;
      final bytes = await Future.wait(draft.map((f) => f.readAsBytes()));
      // Build the device fingerprint payload up front so the user pays the
      // Android plugin round-trip once per scan rather than during the
      // hot path below. MediaQuery is read here while the screen is still
      // mounted; the service caches the Android device info internally.
      if (!mounted) return;
      final fingerprintHeaders = await ref
          .read<DeviceFingerprintService>(deviceFingerprintServiceProvider)
          .collectHeaders(context: context);
      // Pass currency dari profile user supaya Edge Function bisa pakai
      // konvensi locale yg tepat saat parsing harga (mis. IDR gunakan '.'
      // sebagai pemisah ribuan, bukan desimal). Fallback ke device locale
      // currency, atau 'USD' jika tidak ada match.
      final currency =
          ref.read(profileProvider).value?.defaultCurrency ??
          ref.read(currencyPrefProvider);
      await ref
          .read(ocrProvider.notifier)
          .process(
            bytes,
            currency: currency,
            fingerprintHeaders: fingerprintHeaders,
          );
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<bool> _checkOcrCredit() async {
    final res = await ref.read(profileRepositoryProvider).getOcrCreditStatus();
    if (!mounted) return false;

    switch (res) {
      case Success(:final data):
        final imageCount = ref.read(scanDraftProvider).images.length;
        final creditCost = _creditCostForPlan(
          planCode: data.planCode,
          imageCount: imageCount,
        );
        if (data.balance >= creditCost) return true;
        await _showNoCreditDialog(
          planCode: data.planCode,
          monthlyAllowance: data.monthlyAllowance,
          requiredCredits: creditCost,
          balance: data.balance,
        );
        return false;
      case ResultFailure(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppL10n.of(context).scanCreditCheckFailed(failure.toString()),
            ),
          ),
        );
        return false;
    }
  }

  Future<void> _showNoCreditDialog({
    required String planCode,
    required int monthlyAllowance,
    required int requiredCredits,
    required int balance,
  }) {
    final isAnonymous = planCode == 'anonymous';
    final l10n = AppL10n.of(context);
    final title = isAnonymous
        ? l10n.scanNoCreditAnonymousTitle
        : l10n.scanNoCreditFreeTitle;
    final body = isAnonymous
        ? l10n.scanNoCreditAnonymousBody
        : planCode == 'plus'
        ? l10n.scanNoCreditPlusBody(monthlyAllowance)
        : l10n.scanNoCreditFreeBody(monthlyAllowance);
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(body),
            SizedBox(height: 12.h),
            Text(
              l10n.scanCreditRequired(requiredCredits, balance),
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.scanNoCreditLater),
          ),
          if (isAnonymous)
            FilledButton.icon(
              icon: const Icon(Icons.person_add_alt_1),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.goNamed(Routes.registerName);
              },
              label: Text(l10n.scanNoCreditRegister),
            )
          else if (planCode == 'free')
            FilledButton.icon(
              icon: const Icon(Icons.workspace_premium),
              onPressed: () => Navigator.of(ctx).pop(),
              label: Text(l10n.scanNoCreditPlusSoon),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<OcrState>(ocrProvider, (prev, next) {
      if (next is OcrSuccess && prev is! OcrSuccess) {
        final result = next.result;
        // Clear the draft now that the user is moving to the review screen.
        // If the user navigates back without reviewing (rare), they can
        // re-pick without leaking references to the old temp files.
        ref.read(scanDraftProvider.notifier).clear();
        // Safety net: provider lama yang belum kenal `is_receipt` bisa lolos
        // dengan items kosong + confidence sangat rendah. Edge Function juga
        // sudah memfilter kasus ini, tapi double-guard di client agar user
        // tidak masuk BillReviewScreen kosong tanpa konteks.
        if (result.items.isEmpty && result.confidence < 0.3) {
          ref.read(ocrProvider.notifier).reset();
          final scheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: scheme.errorContainer,
                behavior: SnackBarBehavior.floating,
                content: Text(
                  AppL10n.of(context).scanNotReceiptHint,
                  style: TextStyle(
                    color: scheme.onErrorContainer,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          return;
        }
        ref.invalidate(ocrCreditStatusProvider);
        ref.read(ocrProvider.notifier).reset();
        context.pushNamed(Routes.billReviewName, extra: result);
      }
      if (next is OcrFailure) {
        final msg = friendlyOcrMessage(next.failure, AppL10n.of(context));
        final scheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: scheme.errorContainer,
              behavior: SnackBarBehavior.floating,
              content: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: scheme.onErrorContainer,
                    size: 20.r,
                  ),
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
    final creditStatus = switch (ref.watch(ocrCreditStatusProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final images = ref.watch(scanDraftProvider).images;
    final busy = _starting || state is OcrProcessing;
    final scanActive = images.isNotEmpty && !busy;
    final l10n = AppL10n.of(context);
    return AppScaffold(
      title: l10n.scanScreenTitle,
      actions: [
        IconButton(
          icon: Icon(
            _mode == ReceiptPreviewMode.carousel
                ? Icons.grid_view
                : Icons.view_carousel,
          ),
          onPressed: () => setState(
            () => _mode = _mode == ReceiptPreviewMode.carousel
                ? ReceiptPreviewMode.grid
                : ReceiptPreviewMode.carousel,
          ),
        ),
      ],
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ReceiptPreviewComponent(
                  images: images,
                  mode: _mode,
                  busy: busy,
                  onRemove: (i) =>
                      ref.read(scanDraftProvider.notifier).removeAt(i),
                ),
              ),
            ),
            const BannerAdWidget(placement: BannerAdPlacement.scan),
            SizedBox(height: 12.h),
            if (state is OcrFailure)
              _ErrorCard(
                message: friendlyOcrMessage(state.failure, l10n),
                onDismiss: () => ref.read(ocrProvider.notifier).reset(),
              )
            else
              _StatusLabel(state: state, starting: _starting),
            if (images.isNotEmpty && creditStatus != null) ...[
              SizedBox(height: 6.h),
              _ScanCreditCostLabel(
                imageCount: images.length,
                balance: creditStatus.balance,
                creditCost: _creditCostForPlan(
                  planCode: creditStatus.planCode,
                  imageCount: images.length,
                ),
              ),
            ],
            SizedBox(height: 12.h),
            _OcrAiDisclosureBanner(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : _showAddPhotoSheet,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text(l10n.scanAddPhotos),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child:
                        FilledButton.icon(
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
                              label: Text(
                                busy ? l10n.scanInProgress : l10n.scanAction,
                              ),
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

enum _PhotoSource { camera, gallery }

int _creditCostForPlan({required String? planCode, required int imageCount}) {
  if (imageCount <= 0) return 0;
  return planCode == 'plus' ? 1 : imageCount;
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.state, required this.starting});
  final OcrState state;
  final bool starting;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isProcessing = starting || state is OcrProcessing;
    final l10n = AppL10n.of(context);
    final text = starting && state is! OcrProcessing
        ? l10n.scanStatusPreparingImages
        : switch (state) {
            OcrIdle() => l10n.scanStatusIdle,
            OcrProcessing(:final imageCount) => l10n.scanStatusScanning(
              imageCount,
            ),
            OcrSuccess(:final result) => l10n.scanStatusSuccess(
              result.items.length,
              result.providerUsed,
            ),
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
        .shimmer(duration: 1200.ms, color: scheme.primary);
  }
}

class _ScanCreditCostLabel extends StatelessWidget {
  const _ScanCreditCostLabel({
    required this.imageCount,
    required this.balance,
    required this.creditCost,
  });

  final int imageCount;
  final int balance;
  final int creditCost;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final insufficient = balance < creditCost;
    final color = insufficient ? scheme.error : scheme.onSurfaceVariant;
    final text = l10n.scanCreditCostWithBalance(
      imageCount,
      creditCost,
      balance,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          insufficient
              ? Icons.error_outline
              : Icons.account_balance_wallet_outlined,
          size: 16.r,
          color: color,
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: insufficient ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
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
        border: Border.all(color: scheme.error.withValues(alpha: 0.3)),
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
            tooltip: AppL10n.of(context).cancelAction,
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

class _OcrAiDisclosureBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16.r,
            color: scheme.onSurfaceVariant,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              l10n.ocrAiDisclosure,
              style: TextStyle(
                fontSize: 11.sp,
                color: scheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
