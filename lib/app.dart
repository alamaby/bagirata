import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/config/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_l10n.dart';
import 'presentation/settings/providers/preferences_providers.dart';

class BagiStrukApp extends ConsumerWidget {
  const BagiStrukApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
