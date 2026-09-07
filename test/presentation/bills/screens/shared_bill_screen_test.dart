import 'package:bagistruk/domain/entities/assignment.dart';
import 'package:bagistruk/domain/entities/bill.dart';
import 'package:bagistruk/domain/entities/item.dart';
import 'package:bagistruk/domain/entities/participant.dart';
import 'package:bagistruk/domain/entities/shared_bill.dart';
import 'package:bagistruk/presentation/bills/providers/shared_bill_provider.dart';
import 'package:bagistruk/presentation/bills/screens/shared_bill_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_test_harness.dart';

SharedBill _shared() => SharedBill(
  bill: Bill(
    id: 'bill-1',
    title: 'Bukber',
    totalAmount: 110000,
    currencyCode: 'IDR',
    tax: 10000,
    service: 0,
    createdAt: DateTime.utc(2026, 9, 2),
  ),
  items: const [
    Item(id: 'i1', billId: 'bill-1', name: 'Nasi goreng', price: 50000, qty: 2),
  ],
  participants: const [
    Participant(id: 'p1', billId: 'bill-1', name: 'Ani', isPaid: true),
    Participant(id: 'p2', billId: 'bill-1', name: 'Budi'),
  ],
  assignments: const [
    Assignment(id: 'a1', itemId: 'i1', participantId: 'p1'),
    Assignment(id: 'a2', itemId: 'i1', participantId: 'p2'),
  ],
  expiresAt: DateTime.utc(2026, 9, 9),
);

Future<void> _pump(
  WidgetTester tester,
  AsyncValue<SharedBill?> override,
) async {
  setTestViewport(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedBillProvider('tok').overrideWithValue(override)],
      child: buildTestApp(child: const SharedBillScreen(token: 'tok')),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('SharedBillScreen', () {
    testWidgets('renders read-only bill with totals and join CTA', (
      tester,
    ) async {
      await _pump(tester, AsyncData(_shared()));

      expect(find.text('Bukber'), findsOneWidget);
      expect(find.text('Ani'), findsOneWidget);
      expect(find.text('Budi'), findsOneWidget);
      // Per-person total Ani = 50000 + half of 10000 tax.
      expect(find.textContaining('55.000'), findsWidgets);
      // No settlement toggles anywhere on the public screen.
      expect(find.byType(Switch), findsNothing);
      // Join CTA present on success (plan Notes requirement).
      expect(
        find.text('Sign up to create your own bills'),
        findsOneWidget,
      );
    });

    testWidgets('null snapshot renders expired view with CTA', (
      tester,
    ) async {
      await _pump(tester, const AsyncData<SharedBill?>(null));

      expect(
        find.text('This link is expired or invalid.'),
        findsOneWidget,
      );
      expect(
        find.text('Sign up to create your own bills'),
        findsOneWidget,
      );
    });

    testWidgets('genuine error renders retry, not expired view', (
      tester,
    ) async {
      await _pump(tester, AsyncError<SharedBill?>(Exception('offline'), StackTrace.empty));

      // Error view: message + retry, and NOT the expired copy.
      expect(find.textContaining('offline'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('This link is expired or invalid.'), findsNothing);
    });
  });
}
