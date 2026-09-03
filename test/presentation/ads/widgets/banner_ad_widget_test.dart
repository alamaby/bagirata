import 'package:bagistruk/core/ads/ad_config.dart';
import 'package:bagistruk/domain/entities/ocr_credit_status.dart';
import 'package:bagistruk/l10n/generated/app_l10n.dart';
import 'package:bagistruk/presentation/ads/widgets/banner_ad_widget.dart';
import 'package:bagistruk/presentation/credits/providers/ocr_credit_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _freeStatus = OcrCreditStatus(
  planCode: 'free',
  balance: 5,
  monthlyAllowance: 10,
  adsEnabled: true,
  plusFeaturesEnabled: false,
);

const _plusStatus = OcrCreditStatus(
  planCode: 'plus',
  balance: 10,
  monthlyAllowance: 50,
  adsEnabled: false,
  plusFeaturesEnabled: true,
);

Finder _placeholder() => find.byWidgetPredicate(
      (widget) => widget is SizedBox && widget.height == 58.0,
    );

Widget buildApp(OcrCreditStatus? status) {
  return ProviderScope(
    overrides: [
      ocrCreditStatusProvider.overrideWithValue(AsyncValue.data(status)),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: Scaffold(
        body: BannerAdWidget(placement: BannerAdPlacement.scan),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // ADS_ENABLED=false keeps the test off the real AdMob SDK: the
    // controller's consent gate simply never passes, which is exactly the
    // path these widget tests exercise.
    dotenv.testLoad(
      mergeWith: {
        'ADS_ENABLED': 'false',
        'SUPABASE_URL': 'http://test',
        'SUPABASE_ANON_KEY': 'test',
        'GOOGLE_WEB_CLIENT_ID': 'test',
      },
    );
  });

  testWidgets('free user: placeholder shown while the ad is pending', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(_freeStatus));
    await tester.pump();
    expect(_placeholder(), findsOneWidget);
  });

  testWidgets('plus user: no banner space (plan gate closed)', (tester) async {
    await tester.pumpWidget(buildApp(_plusStatus));
    await tester.pump();
    expect(_placeholder(), findsNothing);
  });

  testWidgets('banner gives up for the session after the retry cap', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(_freeStatus));
    await tester.pump();
    expect(_placeholder(), findsOneWidget);

    // With the consent gate never passing, the controller burns the fast
    // backoff (2/8/30/60/120s) and the slow retries (60s x 10), then hides
    // the banner for the rest of the session instead of retrying forever.
    const fast = <Duration>[
      Duration(seconds: 2),
      Duration(seconds: 8),
      Duration(seconds: 30),
      Duration(seconds: 60),
      Duration(seconds: 120),
    ];
    for (final delay in fast) {
      await tester.pump(delay);
    }
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 60));
    }
    await tester.pump();
    expect(_placeholder(), findsNothing);
  });
}
