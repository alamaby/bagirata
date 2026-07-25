import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

import '../../../core/ads/ad_config.dart';
import '../../../core/ads/ad_service.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../presentation/settings/providers/profile_notifier.dart';
import '../../credits/providers/ocr_credit_status_provider.dart';

final _logger = Logger();

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key, required this.placement});

  final BannerAdPlacement placement;

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  static const _retryDelays = <Duration>[
    Duration(seconds: 2),
    Duration(seconds: 8),
    Duration(seconds: 30),
  ];

  BannerAd? _ad;
  bool _loaded = false;
  bool _failedPermanently = false;
  int _retryAttempt = 0;
  Timer? _retryTimer;

  static const double _placeholderHeight = 58;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creditStatusAsync = ref.watch(ocrCreditStatusProvider);
    final isGateLoading = creditStatusAsync.isLoading;
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
        if (wasMinor != isMinor && _loaded) {
          _retryTimer?.cancel();
          _ad?.dispose();
          _ad = null;
          _loaded = false;
          _failedPermanently = false;
          _retryAttempt = 0;
          _load();
        }
      },
    );

    final ad = _ad;
    final hasAd = _loaded && ad != null;

    if (hasAd) {
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
    }

    if (isGateLoading || !_failedPermanently) {
      return SizedBox(height: _placeholderHeight);
    }

    return const SizedBox.shrink();
  }

  void _load() {
    unawaited(_loadAd());
  }

  Future<void> _loadAd() async {
    final unitId = AdConfig.bannerAdUnitId(widget.placement);
    if (!AdConfig.adsEnabled || unitId == null) return;

    final canRequestAds = await AdService.canRequestAds();
    if (!mounted) return;

    if (!canRequestAds) {
      _logger.i(
        'BannerAd waiting for consent/ad readiness '
        'placement=${widget.placement.name} attempt=$_retryAttempt',
      );
      _scheduleRetry();
      return;
    }

    final ad = BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          _retryTimer?.cancel();
          setState(() {
            _loaded = true;
            _failedPermanently = false;
            _retryAttempt = 0;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          _logger.w(
            'BannerAd load failed placement=${widget.placement.name} '
            'attempt=$_retryAttempt code=${error.code} message=${error.message}',
          );
          _scheduleRetry();
        },
      ),
    );

    _ad = ad;
    unawaited(ad.load());
  }

  void _scheduleRetry() {
    if (_retryAttempt >= _retryDelays.length) {
      if (!mounted) return;
      setState(() {
        _ad = null;
        _loaded = false;
        _failedPermanently = true;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _failedPermanently = false;
    });
    final delay = _retryDelays[_retryAttempt];
    _retryAttempt += 1;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (!mounted) return;
      _load();
    });
  }
}
