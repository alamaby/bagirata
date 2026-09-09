import 'package:bagistruk/domain/entities/ocr_result.dart';
import 'package:bagistruk/presentation/bills/screens/bill_review_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_test_harness.dart';

void main() {
  Future<void> pumpReview(WidgetTester tester, OcrResult ocr) async {
    setTestViewport(tester);
    await tester.pumpWidget(
      ProviderScope(
        child: buildTestApp(child: BillReviewScreen(ocr: ocr)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('BillReviewScreen manual mode', () {
    testWidgets('shows manual hint and no confidence warning', (
      tester,
    ) async {
      await pumpReview(tester, OcrResult.manual());

      expect(
        find.text(
          'No receipt photo — add items manually, free with no credit.',
        ),
        findsOneWidget,
      );
      // confidence == 0 would trigger the warning for OCR bills — suppressed.
      expect(find.textContaining('confident'), findsNothing);
      // Untitled default + add-item affordance present.
      expect(find.text('Untitled bill'), findsOneWidget);
      expect(find.text('Add item'), findsOneWidget);
    });

    testWidgets('category presets and tags field are visible', (
      tester,
    ) async {
      await pumpReview(tester, OcrResult.manual());

      // All five presets render as chips.
      for (final label in ['Food', 'Transport', 'Groceries', 'Shopping', 'Other']) {
        expect(find.text(label), findsOneWidget);
      }
      // Tags field exists (locked for non-Plus in this harness).
      expect(find.text('Tags (Plus)'), findsOneWidget);
    });

    testWidgets('tags field is locked with Plus copy in this harness', (
      tester,
    ) async {
      await pumpReview(tester, OcrResult.manual());

      // Plus is off in this harness — label renders in EN test locale.
      expect(find.text('Tags (Plus)'), findsOneWidget);
      expect(find.textContaining('Max 5 tags'), findsNothing);
    });

    testWidgets('low-confidence OCR still shows the warning chip', (
      tester,
    ) async {
      const ocr = OcrResult(
        items: [OcrLineItem(name: 'Kopi', price: 15000, qty: 1)],
        confidence: 0.5,
        providerUsed: 'gemini',
      );
      await pumpReview(tester, ocr);

      expect(find.textContaining('confident'), findsOneWidget);
      expect(find.textContaining('No receipt photo'), findsNothing);
    });

    testWidgets('manual form has its own title, not Review bill', (
      tester,
    ) async {
      await pumpReview(tester, OcrResult.manual());

      expect(find.text('New manual bill'), findsOneWidget);
      expect(find.text('Review bill'), findsNothing);
    });

    testWidgets('ocr review keeps the Review bill title', (tester) async {
      const ocr = OcrResult(
        items: [OcrLineItem(name: 'Kopi', price: 15000, qty: 1)],
        confidence: 0.9,
        providerUsed: 'gemini',
      );
      await pumpReview(tester, ocr);

      expect(find.text('Review bill'), findsOneWidget);
      expect(find.text('New manual bill'), findsNothing);
    });

    testWidgets('adding an item focuses its name field and shows swipe hint', (
      tester,
    ) async {
      await pumpReview(tester, OcrResult.manual());
      expect(
        find.text('Swipe an item left to delete it.'),
        findsNothing,
      );

      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();

      // The fresh row's name field grabs focus for immediate typing.
      expect(FocusManager.instance.primaryFocus, isNotNull);
      // With items present, the manual form hints at swipe-to-delete.
      expect(
        find.text('Swipe an item left to delete it.'),
        findsOneWidget,
      );
    });
  });
}
