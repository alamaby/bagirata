import 'package:bagistruk/presentation/settings/widgets/currency_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_test_harness.dart';

void main() {
  group('CurrencyPickerSheet', () {
    testWidgets('shows search and currency options', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showCurrencyPickerSheet(context, 'IDR'),
            child: const Text('Open Sheet'),
          ),
        ),
      ));

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Default Currency'), findsOneWidget);
      expect(find.text('Indonesian Rupiah (IDR)'), findsWidgets);
    });

    testWidgets('selecting a currency returns its code', (tester) async {
      String? result;
      await tester.pumpWidget(buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showCurrencyPickerSheet(context, 'IDR');
            },
            child: const Text('Open Sheet'),
          ),
        ),
      ));

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Scroll to find USD and tap it
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('US Dollar (USD)').first);
      await tester.pumpAndSettle();

      expect(result, 'USD');
    });

    testWidgets('search filters currency list', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showCurrencyPickerSheet(context, 'IDR'),
            child: const Text('Open Sheet'),
          ),
        ),
      ));

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'yen');
      await tester.pumpAndSettle();

      expect(find.text('Japanese Yen (JPY)'), findsWidgets);
      expect(find.text('Indonesian Rupiah (IDR)'), findsNothing);
    });

    testWidgets('search empty shows no results message', (tester) async {
      await tester.pumpWidget(buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showCurrencyPickerSheet(context, 'IDR'),
            child: const Text('Open Sheet'),
          ),
        ),
      ));

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzzzz');
      await tester.pumpAndSettle();

      expect(find.text('No currency found.'), findsOneWidget);
    });
  });
}