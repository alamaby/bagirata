import 'package:bagistruk/core/error/failure.dart';
import 'package:bagistruk/presentation/shared/widgets/failure_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_test_harness.dart';

void main() {
  group('FailureView', () {
    testWidgets('renders network failure message', (tester) async {
      const failure = Failure.network('no connection');
      await tester.pumpWidget(buildTestApp(
        child: FailureView(failure: failure),
      ));

      expect(find.textContaining('no connection'), findsOneWidget);
    });

    testWidgets('renders server failure with code', (tester) async {
      const failure = Failure.server(code: 42501, message: 'rls denied');
      await tester.pumpWidget(buildTestApp(
        child: FailureView(failure: failure),
      ));

      expect(find.textContaining('42501'), findsOneWidget);
      expect(find.textContaining('rls denied'), findsOneWidget);
    });

    testWidgets('renders auth failure message in ID locale', (tester) async {
      const failure = Failure.auth('session expired');
      await tester.pumpWidget(buildTestApp(
        child: FailureView(failure: failure),
        locale: const Locale('id'),
      ));

      expect(find.textContaining('session expired'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry provided', (tester) async {
      const failure = Failure.network('offline');
      await tester.pumpWidget(buildTestApp(
        child: FailureView(failure: failure, onRetry: () {}),
      ));

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      const failure = Failure.network('offline');
      await tester.pumpWidget(buildTestApp(
        child: FailureView(failure: failure),
      ));

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('tapping retry triggers callback', (tester) async {
      const failure = Failure.network('offline');
      var tapped = false;
      await tester.pumpWidget(buildTestApp(
        child: FailureView(
          failure: failure,
          onRetry: () => tapped = true,
        ),
      ));

      await tester.tap(find.text('Retry'));
      expect(tapped, isTrue);
    });
  });
}