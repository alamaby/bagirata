import 'package:bagistruk/data/services/settlement_reminder_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettlementReminderService pure logic', () {
    test('dueDates are T+3 and T+7 UTC', () {
      final created = DateTime.utc(2026, 9, 1, 10);
      final due = SettlementReminderService.dueDates(createdAt: created);
      expect(due, [
        DateTime.utc(2026, 9, 4, 10),
        DateTime.utc(2026, 9, 8, 10),
      ]);
      expect(SettlementReminderService.reminderOffsetsDays, [3, 7]);
    });

    test('notificationIds are stable and unique per slot', () {
      final a = SettlementReminderService.notificationIds('bill-1');
      final b = SettlementReminderService.notificationIds('bill-1');
      expect(a, b);
      expect(a.toSet().length, 2);
      expect(
        SettlementReminderService.notificationIds('bill-2'),
        isNot(equals(a)),
      );
    });
  });

  group('SettlementReminderService bookkeeping', () {
    test('settled bill is a no-op', () async {
      final prefs = await SharedPreferences.getInstance();
      final svc = SettlementReminderService(
        prefs: prefs,
        nowUtc: () => DateTime.utc(2026, 9, 1),
      );
      await svc.scheduleForBill(
        billId: 'bill-1',
        notificationTitle: 't',
        notificationBody: 'b',
        createdAt: DateTime.utc(2026, 9, 1),
        isSettled: true,
      );
      expect(svc.trackedBills(), isEmpty);
    });

    test('past dues are skipped, future kept', () async {
      final prefs = await SharedPreferences.getInstance();
      final svc = SettlementReminderService(
        prefs: prefs,
        // After T+3, before T+7.
        nowUtc: () => DateTime.utc(2026, 9, 5),
      );
      await svc.scheduleForBill(
        billId: 'bill-1',
        notificationTitle: 't',
        notificationBody: 'b',
        createdAt: DateTime.utc(2026, 9, 1, 10),
      );
      expect(svc.trackedBills(), ['bill-1']);
      expect(svc.isCancelled('bill-1'), isFalse);
    });

    test('cancel marks the bill cancelled', () async {
      final prefs = await SharedPreferences.getInstance();
      final svc = SettlementReminderService(
        prefs: prefs,
        nowUtc: () => DateTime.utc(2026, 9, 1),
      );
      await svc.scheduleForBill(
        billId: 'bill-1',
        notificationTitle: 't',
        notificationBody: 'b',
        createdAt: DateTime.utc(2026, 9, 1),
      );
      await svc.cancelForBill('bill-1');
      expect(svc.isCancelled('bill-1'), isTrue);
    });

    test('cancel of unknown bill does not throw', () async {
      final prefs = await SharedPreferences.getInstance();
      final svc = SettlementReminderService(prefs: prefs);
      await svc.cancelForBill('nope');
      expect(svc.trackedBills(), isEmpty);
    });

    test('corrupt prefs JSON tolerated', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('settlement_reminders_v1', '{oops');
      final svc = SettlementReminderService(prefs: prefs);
      expect(svc.trackedBills(), isEmpty);
      expect(svc.isCancelled('bill-1'), isFalse);
    });
  });
}
