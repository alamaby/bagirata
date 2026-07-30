import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/error/result.dart';
import '../../../core/router/routes.dart';
import '../../../data/providers.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../../settings/providers/preferences_providers.dart';
import '../providers/onboarding_notifier.dart';

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.body,
    required this.imageAsset,
  });

  final String title;
  final String body;
  final String imageAsset;
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.isReplay = false});

  final bool isReplay;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _submitting = false;

  bool get _busy => _submitting;

  static const _assetPaths = [
    'assets/images/onboarding/onboarding_scan.png',
    'assets/images/onboarding/onboarding_split.png',
    'assets/images/onboarding/onboarding_settle.png',
  ];

  @override
  void initState() {
    super.initState();
    // Refresh app config so a recently-disabled promo takes effect
    // without requiring an app restart.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appConfigProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_OnboardingSlide> _slides({
    required String title1,
    required String body1,
    required String title2,
    required String body2,
    required String title3,
    required String body3,
    required bool showPromo,
    required String promoTitle,
    required String promoBody,
  }) {
    return [
      _OnboardingSlide(
        imageAsset: _assetPaths[0],
        title: title1,
        body: body1,
      ),
      _OnboardingSlide(
        imageAsset: _assetPaths[1],
        title: title2,
        body: body2,
      ),
      _OnboardingSlide(
        imageAsset: _assetPaths[2],
        title: title3,
        body: body3,
      ),
      if (showPromo)
        _OnboardingSlide(
          imageAsset: 'assets/images/onboarding/onboarding_promo.png',
          title: promoTitle,
          body: promoBody,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final appConfig = ref.watch(appConfigProvider).value;
    final locale = ref.watch(localePrefProvider).languageCode;
    final showPromo = appConfig != null &&
        appConfig.promoOnboardingEnabled &&
        appConfig.hasCompletePromoOnboardingCopy;
    final promoTitle = showPromo
        ? (locale == 'id'
            ? appConfig.promoOnboardingTitleId
            : appConfig.promoOnboardingTitleEn)
        : '';
    final promoBody = showPromo
        ? (locale == 'id'
            ? appConfig.promoOnboardingBodyId
            : appConfig.promoOnboardingBodyEn)
        : '';
    final lastIndex = showPromo ? 3 : 2;

    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmoothPageIndicator(
                      controller: _controller,
                      count: showPromo ? 4 : 3,
                      effect: ExpandingDotsEffect(
                        activeDotColor: Theme.of(context).colorScheme.primary,
                        dotColor: Theme.of(context).colorScheme.outlineVariant,
                        dotHeight: 8.h,
                        dotWidth: 8.w,
                        expansionFactor: 3,
                      ),
                    ),
                    if (!widget.isReplay)
                      TextButton(
                        onPressed: _busy ? null : () => _finish(),
                        child: Text(l10n.onboardingSkip),
                      )
                    else
                      SizedBox(width: 64.w),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  physics: _busy
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  onPageChanged: (i) => setState(() => _index = i),
                  children: _slides(
                    title1: l10n.onboardingTitle1,
                    body1: l10n.onboardingBody1,
                    title2: l10n.onboardingTitle2,
                    body2: l10n.onboardingBody2,
                    title3: l10n.onboardingTitle3,
                    body3: l10n.onboardingBody3,
                    showPromo: showPromo,
                    promoTitle: promoTitle,
                    promoBody: promoBody,
                  ).map((s) => _page(s.title, s.body, s.imageAsset)).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24.r),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy
                        ? null
                        : _index == lastIndex
                            ? _finish
                            : () => _controller.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                ),
                    child: _busy
                        ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            _index == lastIndex
                                ? (widget.isReplay
                                    ? l10n.onboardingReplayFinish
                                    : l10n.onboardingFinish)
                                : l10n.onboardingNext,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _page(String title, String body, String imageAsset) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 24.h),
          Semantics(
            image: true,
            label: title,
            child: Image.asset(
              imageAsset,
              height: 250.h,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(
                Icons.image_not_supported_outlined,
                size: 100.r,
                color: scheme.primary,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finish() async {
    if (widget.isReplay) {
      if (mounted) context.pop();
      return;
    }

    setState(() => _submitting = true);
    final res = await ref
        .read(onboardingProvider.notifier)
        .completeOnboarding();
    if (!mounted) return;

    setState(() => _submitting = false);

    switch (res) {
      case Success<void>():
        context.go(Routes.scan);
      case ResultFailure<void>():
        _showError(AppL10n.of(context).onboardingSaveError);
    }
  }

  void _showError(String message) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: scheme.errorContainer,
          content: Text(
            message,
            style: TextStyle(color: scheme.onErrorContainer),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class SmoothPageIndicator extends StatelessWidget {
  const SmoothPageIndicator({
    super.key,
    required this.controller,
    required this.count,
    required this.effect,
  });

  final PageController controller;
  final int count;
  final ExpandingDotsEffect effect;

  @override
  Widget build(BuildContext context) {
    return _SmoothPageIndicator(
      controller: controller,
      count: count,
      effect: effect,
    );
  }
}

class ExpandingDotsEffect {
  const ExpandingDotsEffect({
    required this.activeDotColor,
    required this.dotColor,
    required this.dotHeight,
    required this.dotWidth,
    required this.expansionFactor,
  });

  final Color activeDotColor;
  final Color dotColor;
  final double dotHeight;
  final double dotWidth;
  final int expansionFactor;
}

class _SmoothPageIndicator extends StatefulWidget {
  const _SmoothPageIndicator({
    required this.controller,
    required this.count,
    required this.effect,
  });

  final PageController controller;
  final int count;
  final ExpandingDotsEffect effect;

  @override
  State<_SmoothPageIndicator> createState() => _SmoothPageIndicatorState();
}

class _SmoothPageIndicatorState extends State<_SmoothPageIndicator> {
  int _current = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    final page = widget.controller.page?.round() ?? 0;
    if (page != _current) setState(() => _current = page);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.count, (i) {
        final isActive = i == _current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          width: isActive
              ? widget.effect.dotWidth * widget.effect.expansionFactor
              : widget.effect.dotWidth,
          height: widget.effect.dotHeight,
          decoration: BoxDecoration(
            color:
                isActive ? widget.effect.activeDotColor : widget.effect.dotColor,
            borderRadius: BorderRadius.circular(999.r),
          ),
        );
      }),
    );
  }
}
