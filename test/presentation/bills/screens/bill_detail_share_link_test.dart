import 'package:bagistruk/domain/entities/bill.dart';
import 'package:bagistruk/domain/entities/ocr_credit_status.dart';
import 'package:bagistruk/presentation/bills/providers/bill_detail_notifier.dart'
    show BillDetailNotifier, BillDetailState, billDetailFamily;
import 'package:bagistruk/presentation/bills/providers/bill_share_link_notifier.dart'
    show BillShareLink, BillShareState, billShareLinkFamily;
import 'package:bagistruk/presentation/bills/screens/bill_detail_screen.dart';
import 'package:bagistruk/presentation/credits/providers/ocr_credit_status_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_test_harness.dart';

const _freeStatus = OcrCreditStatus(
  planCode: 'free',
  balance: 5,
  monthlyAllowance: 10,
  adsEnabled: true,
  plusFeaturesEnabled: false,
);

BillDetailState _detailState() => BillDetailState(
  bill: Bill(
    id: 'bill-1',
    title: 'Bukber',
    totalAmount: 110000,
    createdAt: DateTime.utc(2026, 9, 2),
  ),
  items: const [],
  participants: const [],
  assignments: const [],
);

class _FakeBillDetail extends BillDetailNotifier {
  _FakeBillDetail(this._state);

  final BillDetailState _state;

  @override
  Future<BillDetailState> build(String billId) async => _state;
}

class _FakeBillShareLink extends BillShareLink {
  _FakeBillShareLink(this._link);

  final BillShareState? _link;

  @override
  Future<BillShareState?> build(String billId) async => _link;

  @override
  Future<void> load(String billId) async {
    // No-op: screen initState calls load(); the Supabase client backing
    // the real implementation is unavailable in widget tests.
  }
}

Future<void> _pumpSection(
  WidgetTester tester, {
  BillShareState? link,
}) async {
  setTestViewport(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        billDetailFamily.overrideWith(() => _FakeBillDetail(_detailState())),
        ocrCreditStatusProvider.overrideWithValue(
          const AsyncData(_freeStatus),
        ),
        billShareLinkFamily.overrideWith(() => _FakeBillShareLink(link)),
      ],
      child: buildTestApp(child: const BillDetailScreen(billId: 'bill-1')),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('_ShareLinkSection countdown', () {
    testWidgets('active link shows countdown plus absolute date', (
      tester,
    ) async {
      final expiresAt = DateTime.now().add(const Duration(days: 3, hours: 2));
      await _pumpSection(
        tester,
        link: BillShareState(tokenId: 't', expiresAt: expiresAt),
      );

      expect(find.text('Expires in 3 days'), findsOneWidget);
      expect(find.textContaining('Valid until'), findsOneWidget);
      // Revoke still offered while live — now icon-only at the row's end.
      expect(find.byTooltip('Disable link'), findsOneWidget);
      expect(find.text('Disable link'), findsNothing);
    });

    testWidgets('hours bucket under 24h', (tester) async {
      final expiresAt = DateTime.now().add(const Duration(hours: 5));
      await _pumpSection(
        tester,
        link: BillShareState(tokenId: 't', expiresAt: expiresAt),
      );

      expect(find.textContaining('Expires in'), findsOneWidget);
      expect(find.textContaining('days'), findsNothing);
    });

    testWidgets('expired link shows expired state with create, no revoke', (
      tester,
    ) async {
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 5));
      await _pumpSection(
        tester,
        link: BillShareState(tokenId: 't', expiresAt: expiresAt),
      );

      expect(
        find.text('This link is expired or invalid.'),
        findsOneWidget,
      );
      expect(find.text('Copy link'), findsOneWidget);
      expect(find.text('Disable link'), findsNothing);
    });

    testWidgets('no link shows create button', (tester) async {
      await _pumpSection(tester, link: null);

      expect(find.text('Copy link'), findsOneWidget);
    });
  });
}
