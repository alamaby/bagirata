import 'package:bagistruk/presentation/settings/widgets/language_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_test_harness.dart';

void main() {
  group('LanguagePickerDialog', () {
    testWidgets('tapping Indonesian option returns id', (tester) async {
      String? result;
      await tester.pumpWidget(buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showLanguagePickerDialog(context, 'en');
            },
            child: const Text('Open Dialog'),
          ),
        ),
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Bahasa Indonesia'), findsOneWidget);

      await tester.tap(find.text('Bahasa Indonesia'));
      await tester.pumpAndSettle();

      expect(result, 'id');
    });

    testWidgets('tapping English option returns en', (tester) async {
      String? result;
      await tester.pumpWidget(buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showLanguagePickerDialog(context, 'id');
            },
            child: const Text('Open Dialog'),
          ),
        ),
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(result, 'en');
    });

    testWidgets('tapping Indonesian option works with ID locale', (tester) async {
      String? result;
      await tester.pumpWidget(buildTestApp(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showLanguagePickerDialog(context, 'en');
            },
            child: const Text('Open Dialog'),
          ),
        ),
        locale: const Locale('id'),
      ));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Bahasa Indonesia'), findsOneWidget);
      await tester.tap(find.text('Bahasa Indonesia'));
      await tester.pumpAndSettle();

      expect(result, 'id');
    });
  });
}