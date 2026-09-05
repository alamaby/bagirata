import 'package:bagistruk/presentation/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_test_harness.dart';

/// Regression for the M1 audit finding: History + Scan AppBars grew a second
/// action button ("Buat manual"). At 320dp + 1.3x text scale a long title
/// could squeeze into a RenderFlex overflow. These tests fail on any
/// `overflowed` FlutterError under those conditions (ID locale = longest
/// production copy: "Pindai Struk" / "Riwayat").
void main() {
  List<FlutterErrorDetails> errors = [];

  setUp(() {
    errors = [];
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details);
      original?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = original;
    });
  });

  Future<void> pumpFrame(WidgetTester tester, Widget child) async {
    setTestViewport(tester, size: const Size(320, 568));
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(() {
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    await tester.pumpWidget(
      buildTestApp(child: child, locale: const Locale('id')),
    );
    await tester.pumpAndSettle();
  }

  List<String> overflows() => errors
      .where((e) => e.toString().contains('overflowed'))
      .map((e) => e.toString())
      .toList(growable: false);

  group('AppBar two-action overflow (320dp, 1.3x, ID)', () {
    testWidgets('scan-style AppBar holds title + 2 actions', (tester) async {
      await pumpFrame(
        tester,
        const AppScaffold(
          title: 'Pindai Struk',
          actions: [
            IconButton(
              tooltip: 'manual',
              icon: Icon(Icons.note_add_outlined),
              onPressed: null,
            ),
            IconButton(
              tooltip: 'mode',
              icon: Icon(Icons.grid_view),
              onPressed: null,
            ),
          ],
          body: SizedBox.shrink(),
        ),
      );
      expect(find.text('Pindai Struk'), findsOneWidget);
      expect(find.byIcon(Icons.note_add_outlined), findsOneWidget);
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(overflows(), isEmpty);
    });

    testWidgets('history-style SliverAppBar holds title + 2 actions', (
      tester,
    ) async {
      await pumpFrame(
        tester,
        Scaffold(
          body: CustomScrollView(
            slivers: const [
              SliverAppBar(
                title: Text('Riwayat'),
                pinned: true,
                actions: [
                  IconButton(
                    tooltip: 'manual',
                    icon: Icon(Icons.note_add_outlined),
                    onPressed: null,
                  ),
                  IconButton(
                    tooltip: 'filter',
                    icon: Badge(child: Icon(Icons.tune)),
                    onPressed: null,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      expect(find.text('Riwayat'), findsOneWidget);
      expect(find.byIcon(Icons.note_add_outlined), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
      expect(overflows(), isEmpty);
    });
  });
}
