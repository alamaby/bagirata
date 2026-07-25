import 'package:bagistruk/core/config/app_constants.dart';
import 'package:bagistruk/core/theme/app_theme.dart';
import 'package:bagistruk/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] in a minimal app scaffold matching the production ScreenUtil,
/// theme, and localization setup. Callers should wrap with ProviderScope and
/// provider overrides externally.
Widget buildTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
  ThemeMode themeMode = ThemeMode.light,
  bool useScaffold = true,
}) {
  return ScreenUtilInit(
    designSize: AppConstants.designSize,
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppL10n.supportedLocales,
      localizationsDelegates: AppL10n.localizationsDelegates,
      home: useScaffold ? Scaffold(body: child) : child,
    ),
  );
}

Future<void> setTestViewport(
  WidgetTester tester, {
  Size size = AppConstants.designSize,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}
