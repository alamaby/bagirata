import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/ads/ad_config.dart';
import '../../../core/ads/ad_service.dart';
import '../../../core/ads/banner_ad_controller.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../presentation/settings/providers/profile_notifier.dart';
import '../../credits/providers/ocr_credit_status_provider.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key, required this.placement});

  final BannerAdPlacement placement;

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget>
    with WidgetsBindingObserver {
  static const double _placeholderHeight = 58;

  BannerAd? _ad;
  late final BannerAdController _controller;
  bool _hasBuilt = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = BannerAdController(
      source: _SdkBannerAdSource(
        placement: widget.placement,
        onAdChanged: _onAdChanged,
      ),
      tag: widget.placement.name,
      onStatusChanged: (status) {
        // Status changes before the first build are already reflected via
        // the direct `status` read in build(); only schedule a rebuild
        // once the widget has built at least once.
        if (_hasBuilt && mounted) setState(() {});
      },
    );
    _controller.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _controller.appResumed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _onAdChanged(BannerAd? ad) {
    if (!mounted || identical(_ad, ad)) return;
    setState(() => _ad = ad);
  }

  @override
  Widget build(BuildContext context) {
    _hasBuilt = true;
    final creditStatusAsync = ref.watch(ocrCreditStatusProvider);
    final creditStatus = switch (creditStatusAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (creditStatus?.adsEnabled == false) {
      return const SizedBox.shrink();
    }

    ref.listen<UserProfile?>(
      profileProvider.select(
        (s) => switch (s) {
          AsyncData(:final value) => value,
          _ => null,
        },
      ),
      (prev, next) {
        final wasMinor = !(prev?.isAdult ?? false);
        final isMinor = !(next?.isAdult ?? false);
        if (wasMinor != isMinor) _controller.reset();
      },
    );

    final ad = _ad;
    switch (_controller.status) {
      case BannerAdStatus.loaded:
        if (ad == null) {
          return const SizedBox(height: _placeholderHeight);
        }
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Center(
              child: SizedBox(
                width: ad.size.width.toDouble(),
                height: ad.size.height.toDouble(),
                child: AdWidget(ad: ad),
              ),
            ),
          ),
        );
      case BannerAdStatus.hidden:
        return const SizedBox.shrink();
      case BannerAdStatus.waiting:
      case BannerAdStatus.loading:
        return const SizedBox(height: _placeholderHeight);
    }
  }
}

/// Production [BannerAdSource] backed by the google_mobile_ads SDK. Kept
/// out of [BannerAdController] so the state machine stays pure Dart.
class _SdkBannerAdSource implements BannerAdSource {
  _SdkBannerAdSource({required this.placement, required this.onAdChanged});

  final BannerAdPlacement placement;
  final void Function(BannerAd?) onAdChanged;

  BannerAd? _ad;

  @override
  Future<bool> canRequestAds() async {
    if (!AdConfig.adsEnabled) return false;
    if (AdConfig.bannerAdUnitId(placement) == null) return false;
    return AdService.canRequestAds();
  }

  @override
  Future<void> waitForSdkReady() => AdService.ready;

  @override
  void load(BannerAdCallbacks callbacks) {
    final unitId = AdConfig.bannerAdUnitId(placement);
    if (unitId == null) return;
    final ad = BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loaded) {
          callbacks.onLoaded();
        },
        onAdFailedToLoad: (failed, error) {
          failed.dispose();
          _ad = null;
          onAdChanged(null);
          callbacks.onFailed(error.code, error.message);
        },
      ),
    );
    _ad = ad;
    onAdChanged(ad);
    unawaited(ad.load());
  }

  @override
  void disposeCurrent() {
    if (_ad == null) return;
    _ad?.dispose();
    _ad = null;
    onAdChanged(null);
  }
}
