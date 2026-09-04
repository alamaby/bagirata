import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'core/config/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/router/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'data/providers.dart';
import 'domain/entities/auth_snapshot.dart';
import 'l10n/generated/app_l10n.dart';
import 'presentation/auth/providers/auth_providers.dart';
import 'presentation/ocr/providers/scan_draft_notifier.dart';
import 'presentation/ocr/providers/shared_auto_scan_provider.dart';
import 'presentation/settings/providers/preferences_providers.dart';

class BagiStrukApp extends ConsumerStatefulWidget {
  const BagiStrukApp({super.key});

  @override
  ConsumerState<BagiStrukApp> createState() => _BagiStrukAppState();
}

class _BagiStrukAppState extends ConsumerState<BagiStrukApp>
    with WidgetsBindingObserver {
  DateTime? _lastActiveTouch;
  String? _lastActiveTouchUserId;
  StreamSubscription<List<XFile>>? _sharedMediaSub;
  bool _sharedMediaListening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _touchLastActive();
      _consumeInitialSharedMedia();
      _listenSharedMedia();
    });
  }

  @override
  void dispose() {
    _sharedMediaSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _touchLastActive();
    }
  }

  Future<void> _touchLastActive() async {
    final userId = ref.read(authRepositoryProvider).currentUserId;
    if (userId == null) return;

    final now = DateTime.now();
    final previous = _lastActiveTouch;
    if (_lastActiveTouchUserId == userId &&
        previous != null &&
        now.difference(previous) < AppConstants.lastActiveTouchInterval) {
      return;
    }
    _lastActiveTouch = now;
    _lastActiveTouchUserId = userId;
    await ref.read(profileRepositoryProvider).touchLastActive();
  }

  /// Consumes the share intent that cold-started the app (if any): images
  /// go into the scan draft, the router lands on /scan, and the scan
  /// screen auto-runs the OCR pipeline once visible (after any legal /
  /// onboarding gates).
  ///
  /// If reading fails, the initial intent is deliberately NOT acknowledged
  /// so the next launch retries instead of silently dropping the share.
  Future<void> _consumeInitialSharedMedia() async {
    try {
      final service = ref.read(sharedMediaServiceProvider);
      final images = await service.getInitialSharedImages();
      service.acknowledgeInitial();
      _handleSharedImages(images);
    } catch (e) {
      AppLogger.warn('Share-to-scan: failed to read initial shared media', e);
    }
  }

  /// Listens for share intents arriving while the app is already running
  /// (MainActivity is singleTop, so no new activity is created).
  void _listenSharedMedia() {
    if (_sharedMediaListening) return;
    _sharedMediaListening = true;
    final service = ref.read(sharedMediaServiceProvider);
    _sharedMediaSub = service.sharedImagesStream.listen(
      _handleSharedImages,
      onError: (Object e) =>
          AppLogger.warn('Share-to-scan: shared media stream error', e),
    );
  }

  void _handleSharedImages(List<XFile> images) {
    if (images.isEmpty || !mounted) return;
    final added = ref.read(scanDraftProvider.notifier).addSharedFiles(images);
    if (added <= 0) return;
    ref.read(sharedAutoScanProvider.notifier).request(added);
    final router = ref.read(appRouterProvider);
    // The share is an explicit "scan this" action, so navigating away from
    // wherever the user was (e.g. /review) is intended. Skip only the
    // redundant hop when already on the scan tab.
    if (router.state.matchedLocation != Routes.scan) {
      router.go(Routes.scan);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (_, next) {
      final snap = switch (next) {
        AsyncData<AuthSnapshot>(:final value) => value,
        _ => null,
      };
      if (snap?.userId != null) {
        _touchLastActive();
      }
    });

    return ScreenUtilInit(
      designSize: AppConstants.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        final router = ref.watch(appRouterProvider);
        final locale = ref.watch(localePrefProvider);
        final themeMode = ref.watch(themeModePrefProvider);
        return MaterialApp.router(
          title: 'BagiStruk',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: router,
          locale: locale,
          supportedLocales: AppL10n.supportedLocales,
          localizationsDelegates: AppL10n.localizationsDelegates,
        );
      },
    );
  }
}
