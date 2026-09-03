import 'package:bagistruk/core/ads/ad_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ready completes immediately when ads are disabled', () async {
    dotenv.testLoad(
      mergeWith: {
        'ADS_ENABLED': 'false',
        'SUPABASE_URL': 'http://test',
        'SUPABASE_ANON_KEY': 'test',
        'GOOGLE_WEB_CLIENT_ID': 'test',
      },
    );
    expect(AdService.isReady, isFalse,
        reason: 'fresh process: initialize() has not run yet');
    await AdService.initialize();
    expect(AdService.isReady, isTrue);
    await AdService.ready;
    // Idempotent: a second call must not hang or throw.
    await AdService.initialize();
    await AdService.ready;
  });
}
