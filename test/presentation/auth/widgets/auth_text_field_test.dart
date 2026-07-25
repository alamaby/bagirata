import 'package:bagistruk/presentation/auth/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_test_harness.dart';

void main() {
  group('AuthTextField', () {
    testWidgets('email field renders TextFormField', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(buildTestApp(
        child: AuthTextField(
          controller: controller,
          label: 'Email',
          icon: Icons.email,
        ),
      ));

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('password field renders TextFormField', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(buildTestApp(
        child: AuthTextField(
          controller: controller,
          label: 'Password',
          icon: Icons.lock,
          obscure: true,
        ),
      ));

      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}