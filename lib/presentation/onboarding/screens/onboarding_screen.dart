import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/error/result.dart';
import '../../../core/format/currency_formatter.dart';
import '../../../core/router/routes.dart';
import '../../../data/providers.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../../settings/providers/preferences_providers.dart';
import '../../settings/providers/profile_notifier.dart';
import '../../settings/widgets/currency_picker_sheet.dart';
import '../../settings/widgets/language_picker_sheet.dart';
import '../providers/onboarding_notifier.dart';

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

  // Local selections for the preference slide. Kept out of provider state so
  // switching language re-renders the slide without persisting prematurely.
  String? _selectedLanguage;
  String? _selectedCurrency;

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

  List<Widget> _pages({
    required AppL10n l10n,
    required bool showPromo,
    required String promoTitle,
    required String promoBody,
    required String prefLanguage,
    required String prefCurrency,
    required void Function(String) onPickLanguage,
    required void Function(String) onPickCurrency,
    required bool isReplay,
  }) {
    final pages = <Widget>[
      _page(
        l10n.onboardingTitle1,
        l10n.onboardingBody1,
        _assetPaths[0],
      ),
      _page(
        l10n.onboardingTitle2,
        l10n.onboardingBody2,
        _assetPaths[1],
      ),
      _page(
        l10n.onboardingTitle3,
        l10n.onboardingBody3,
        _assetPaths[2],
      ),
      if (showPromo)
        _page(promoTitle, promoBody, 'assets/images/onboarding/onboarding_promo.png'),
    ];

    if (!isReplay) {
      // Preference slide is only shown in first-run onboarding.
      pages.insert(
        0,
        _preferencePage(
          l10n: l10n,
          language: prefLanguage,
          currency: prefCurrency,
          onPickLanguage: onPickLanguage,
          onPickCurrency: onPickCurrency,
        ),
      );
    }

    return pages;
  }

@override
  Widget build(BuildContext context) {
    final appConfig = ref.watch(appConfigProvider).value;
    final profileLocale = ref.watch(localePrefProvider).languageCode;
    final profileCurrency = ref.watch(currencyPrefProvider);
    // Preview locale lets the user switch the app language on the preference
    // slide before any profile write — the whole screen re-renders in the
    // chosen language immediately, and the choice is only persisted on submit.
    final previewLocale = _selectedLanguage ?? profileLocale;
    final l10n = lookupAppL10n(Locale(previewLocale));
    final currency = _selectedCurrency ?? profileCurrency;
    final showPromo = appConfig != null &&
        appConfig.promoOnboardingEnabled &&
        appConfig.hasCompletePromoOnboardingCopy;
    final promoTitle = showPromo
        ? (previewLocale == 'id'
            ? appConfig.promoOnboardingTitleId
            : appConfig.promoOnboardingTitleEn)
        : '';
    final promoBody = showPromo
        ? (previewLocale == 'id'
            ? appConfig.promoOnboardingBodyId
            : appConfig.promoOnboardingBodyEn)
        : '';

    // Build the pages list for the PageView
    final pages = _pages(
      l10n: l10n,
      showPromo: showPromo,
      promoTitle: promoTitle,
      promoBody: promoBody,
      prefLanguage: previewLocale,
      prefCurrency: currency,
      onPickLanguage: _pickLanguage,
      onPickCurrency: _pickCurrency,
      isReplay: widget.isReplay,
    );

    final dotCount = pages.length;
    final lastIndex = dotCount - 1;

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
                      count: dotCount,
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
                  children: pages,
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

  Widget _preferencePage({
    required AppL10n l10n,
    required String language,
    required String currency,
    required void Function(String) onPickLanguage,
    required void Function(String) onPickCurrency,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 24.h),
          Icon(
            Icons.tune_outlined,
            size: 88.r,
            color: scheme.primary,
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              l10n.onboardingPreferencesTitle,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              l10n.onboardingPreferencesBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(l10n.onboardingPreferencesLanguage),
                    subtitle: Text(
                      language == 'id'
                          ? l10n.languageIndonesian
                          : l10n.languageEnglish,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final next = await showLanguagePickerSheet(context, language);
                      if (next != null && next != language) onPickLanguage(next);
                    },
                  ),
                  const Divider(height: 1),
ListTile(
      leading: const Icon(Icons.payments_outlined),
      title: Text(l10n.onboardingPreferencesCurrency),
      subtitle: Text(CurrencyFormatter.displayName(currency)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final next = await showCurrencyPickerSheet(context, currency);
        if (next != null && next != currency) {
          onPickCurrency(next);
        }
      },
    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings_outlined, size: 16.sp, color: scheme.onSurfaceVariant),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    l10n.onboardingPreferencesChangeLater,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.sp, color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _page(String title, String body, String imageAsset) {
    final scheme = Theme.of(context).colorScheme;
    // ConstrainedBox(minHeight) makes the Column fill the viewport so
    // MainAxisAlignment.center actually centers the content vertically;
    // scrolling still kicks in on short screens.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
          ),
        );
      },
    );
  }

  void _pickLanguage(String next) {
    setState(() => _selectedLanguage = next);
  }

  void _pickCurrency(String next) {
    setState(() => _selectedCurrency = next);
  }

  Future<void> _finish() async {
    if (widget.isReplay) {
      if (mounted) context.pop();
      return;
    }

    // Persist the preference choice (or the current effective defaults when
    // the user skipped straight through) before completing onboarding, so
    // language + currency are saved or fail together in a single UPDATE.
    setState(() => _submitting = true);
    final currency = (_selectedCurrency ?? ref.read(currencyPrefProvider))!;
    final language = _selectedLanguage ?? ref.read(localePrefProvider).languageCode;
    final prefs = await ref
        .read(profileProvider.notifier)
        .updateOnboardingPreferences(
          currencyCode: currency,
          languageCode: language,
        );
    if (!mounted) return;
    if (prefs is ResultFailure<void>) {
      setState(() => _submitting = false);
      _showError(lookupAppL10n(Locale(language)).onboardingPreferencesSaveError);
      return;
    }

    final res = await ref
        .read(onboardingProvider.notifier)
        .completeOnboarding();
    if (!mounted) return;

    setState(() => _submitting = false);

switch (res) {
      case Success<void>():
        context.go(Routes.scan);
      case ResultFailure<void>():
        _showError(
          lookupAppL10n(Locale(language)).onboardingSaveError,
        );
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
