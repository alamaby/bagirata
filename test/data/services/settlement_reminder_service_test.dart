import 'package:bagistruk/data/services/settlement_reminder_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settlement_reminder_service_test.mocks.dart';

@GenerateMocks([
  FlutterLocalNotificationsPlugin,
  AndroidFlutterLocalNotificationsPlugin,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    when(mockPlugin.initialize(any)).thenAnswer((_) async => true);
    when(mockPlugin.cancel(any)).thenAnswer((_) async {});
    // Unstubbed generic resolves throw under strict mocks — default to null
    // (older OS / auto-granted) unless a test overrides.
    when(
      mockPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >(),
    ).thenReturn(null);
    when(
      mockPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >(),
    ).thenReturn(null);
    when(
      mockPlugin.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation: anyNamed(
          'uiLocalNotificationDateInterpretation',
        ),
        payload: anyNamed('payload'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<SettlementReminderService> liveService({
    FlutterLocalNotificationsPlugin? plugin,
    DateTime Function()? nowUtc,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return SettlementReminderService(
      prefs: prefs,
      plugin: plugin ?? mockPlugin,
      nowUtc: nowUtc,
    );
  }

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

    test('notificationIds are stable golden values (SHA-256, not hashCode)', () {
      // Golden: python hashlib.sha256('settlement-reminder:bill-1').
      // Guards against regressing to Dart hashCode (unstable across restarts).
      expect(SettlementReminderService.notificationIds('bill-1'), [
        1440641228,
        1440641229,
      ]);
      expect(SettlementReminderService.notificationIds('bill-2'), [
        1341813124,
        1341813125,
      ]);
    });

    test('notificationIds unique across 1000 bills and fit int32', () {
      final seen = <int>{};
      for (var i = 0; i < 1000; i++) {
        for (final id in SettlementReminderService.notificationIds('b$i')) {
          expect(id, lessThan(1 << 31));
          expect(seen.add(id), isTrue, reason: 'collision at b$i');
        }
      }
    });

    test('permissionDenied only on explicit false', () {
      expect(SettlementReminderService.permissionDenied(false), isTrue);
      expect(SettlementReminderService.permissionDenied(null), isFalse);
      expect(SettlementReminderService.permissionDenied(true), isFalse);
    });
  });

  group('SettlementReminderService bookkeeping', () {
    test('schedule records entry and fires both slots', () async {
      final svc = await liveService(
        nowUtc: () => DateTime.utc(2026, 9, 1),
      );
      await svc.scheduleForBill(
        billId: 'bill-1',
        notificationTitle: 't',
        notificationBody: 'b',
        createdAt: DateTime.utc(2026, 9, 1),
      );
      expect(svc.trackedBills(), ['bill-1']);
      expect(svc.isCancelled('bill-1'), isFalse);
      verify(
        mockPlugin.zonedSchedule(
          1440641228,
          any,
          any,
          any,
          any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed(
            'uiLocalNotificationDateInterpretation',
          ),
          payload: anyNamed('payload'),
        ),
      ).called(1);
      verify(
        mockPlugin.zonedSchedule(
          1440641229,
          any,
          any,
          any,
          any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed(
            'uiLocalNotificationDateInterpretation',
          ),
          payload: anyNamed('payload'),
        ),
      ).called(1);
    });

    test('settled bill is a no-op', () async {
      final svc = await liveService(
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
      verifyNever(
        mockPlugin.zonedSchedule(
          any,
          any,
          any,
          any,
          any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed(
            'uiLocalNotificationDateInterpretation',
          ),
          payload: anyNamed('payload'),
        ),
      );
    });

    test('all-past dues leave no phantom entry', () async {
      final svc = await liveService(
        nowUtc: () => DateTime.utc(2026, 10, 1),
      );
      await svc.scheduleForBill(
        billId: 'bill-1',
        notificationTitle: 't',
        notificationBody: 'b',
        createdAt: DateTime.utc(2026, 9, 1),
      );
      expect(svc.trackedBills(), isEmpty);
    });

    test('denied permission records nothing', () async {
      final androidMock = MockAndroidFlutterLocalNotificationsPlugin();
      when(
        mockPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >(),
      ).thenReturn(androidMock);
      when(
        androidMock.requestNotificationsPermission(),
      ).thenAnswer((_) async => false);
      final svc = await liveService(
        nowUtc: () => DateTime.utc(2026, 9, 1),
      );
      await svc.scheduleForBill(
        billId: 'bill-1',
        notificationTitle: 't',
        notificationBody: 'b',
        createdAt: DateTime.utc(2026, 9, 1),
      );
      expect(svc.trackedBills(), isEmpty);
      verifyNever(
        mockPlugin.zonedSchedule(
          any,
          any,
          any,
          any,
          any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed(
            'uiLocalNotificationDateInterpretation',
          ),
          payload: anyNamed('payload'),
        ),
      );
    });

    test('cancel uses stored IDs (survives restart semantics)', () async {
      final prefs = await SharedPreferences.getInstance();
      final due = DateTime.now().toUtc().add(const Duration(days: 1));
      await prefs.setString(
        'settlement_reminders_v1',
        '{"bill-9":{"ids":[111,222],"scheduled":["${due.toIso8601String()}"],"title":"t","body":"b","cancelled":false}}',
      );
      final svc = SettlementReminderService(
        prefs: prefs,
        plugin: mockPlugin,
        nowUtc: () => DateTime.now().toUtc(),
      );
      await svc.cancelForBill('bill-9');
      verify(mockPlugin.cancel(111)).called(1);
      verify(mockPlugin.cancel(222)).called(1);
      expect(svc.isCancelled('bill-9'), isTrue);
    });

    test('cancel of unknown bill does not throw', () async {
      final svc = await liveService();
      await svc.cancelForBill('nope');
      expect(svc.trackedBills(), isEmpty);
    });

    test('init rehydrates pending entries (reboot recovery)', () async {
      final prefs = await SharedPreferences.getInstance();
      final due = DateTime.now().toUtc().add(const Duration(days: 2));
      await prefs.setString(
        'settlement_reminders_v1',
        '{"bill-7":{"ids":[777,778],"scheduled":["${due.toIso8601String()}"],"title":"t","body":"b","cancelled":false}}',
      );
      final svc = SettlementReminderService(
        prefs: prefs,
        plugin: mockPlugin,
        nowUtc: () => DateTime.now().toUtc(),
      );
      await svc.init();
      verify(
        mockPlugin.zonedSchedule(
          777,
          any,
          any,
          any,
          any,
          androidScheduleMode: anyNamed('androidScheduleMode'),
          uiLocalNotificationDateInterpretation: anyNamed(
            'uiLocalNotificationDateInterpretation',
          ),
          payload: anyNamed('payload'),
        ),
      ).called(1);
    });

    test('corrupt prefs JSON tolerated', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('settlement_reminders_v1', '{oops');
      final svc = SettlementReminderService(prefs: prefs, plugin: mockPlugin);
      expect(svc.trackedBills(), isEmpty);
      expect(svc.isCancelled('bill-1'), isFalse);
    });
  });
}
