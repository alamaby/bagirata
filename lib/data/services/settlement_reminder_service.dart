import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/utils/app_logger.dart';

/// Local settlement reminders (M1/F4) — opt-in nudges at T+3 and T+7 days for
/// bills that are still unsettled.
///
/// Design notes:
/// - Scheduling bookkeeping (which bills have reminders, which fired) lives
///   in SharedPreferences so it survives restarts; the OS plugin only fires.
/// - Everything is best-effort: denied permissions, missing plugin, or a
///   killed process (no FCM in M1) must never crash the app — failures are
///   logged and swallowed.
/// - Notification IDs are stable per (billId, slot) so rescheduling is
///   idempotent and cancelling is exact.
class SettlementReminderService {
  SettlementReminderService({
    required SharedPreferences prefs,
    FlutterLocalNotificationsPlugin? plugin,
    DateTime Function()? nowUtc,
  }) : _prefs = prefs,
       _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _nowUtc = nowUtc ?? DateTime.now;

  static const _prefsKey = 'settlement_reminders_v1';
  static const _channelId = 'settlement_reminders';
  static const _channelName = 'Settlement reminders';

  /// Days after bill creation when reminders fire. Max 2 per bill.
  static const List<int> reminderOffsetsDays = [3, 7];

  final SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _plugin;
  final DateTime Function() _nowUtc;
  bool _initialized = false;

  /// Pure: due dates for a bill created at [createdAt] (UTC).
  static List<DateTime> dueDates({required DateTime createdAt}) => [
    for (final d in reminderOffsetsDays)
      createdAt.toUtc().add(Duration(days: d)),
  ];

  /// Stable notification IDs per (billId, slot) — idempotent reschedule.
  static List<int> notificationIds(String billId) {
    final base = billId.hashCode & 0x3fffffff;
    return [base * 2, base * 2 + 1];
  }

  Future<void> init() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: darwin),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      _initialized = true;
    } catch (e) {
      AppLogger.error('SettlementReminderService.init failed', e);
    }
  }

  Map<String, dynamic> _readAll() {
    final raw = _prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeAll(Map<String, dynamic> all) =>
      _prefs.setString(_prefsKey, jsonEncode(all));

  /// Schedules T+3/T+7 reminders for a newly saved bill. Past due dates are
  /// skipped. No-op when [isSettled] is already true. Callers pass localized
  /// [notificationTitle]/[notificationBody] (ARB `reminderNotification*`) so
  /// the service stays locale-free and unit-testable.
  Future<void> scheduleForBill({
    required String billId,
    required String notificationTitle,
    required String notificationBody,
    required DateTime createdAt,
    bool isSettled = false,
  }) async {
    if (isSettled) return;
    try {
      await init();
      final now = _nowUtc().toUtc();
      final due = dueDates(createdAt: createdAt);
      final ids = notificationIds(billId);
      final all = _readAll();
      final scheduled = <String>[];
      for (var i = 0; i < due.length; i++) {
        if (!due[i].isAfter(now)) continue;
        // Per-slot best-effort: a failing OS schedule must not drop the
        // bookkeeping entry (cancel still needs to know about this bill).
        try {
          await _plugin.zonedSchedule(
            ids[i],
            notificationTitle,
            notificationBody,
            tz.TZDateTime.from(due[i], tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                _channelId,
                _channelName,
                importance: Importance.defaultImportance,
              ),
              iOS: DarwinNotificationDetails(),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: 'bill:$billId',
          );
        } catch (e) {
          AppLogger.error(
            'SettlementReminderService.schedule slot failed',
            e,
          );
        }
        scheduled.add(due[i].toIso8601String());
      }
      all[billId] = {'scheduled': scheduled, 'cancelled': false};
      await _writeAll(all);
    } catch (e) {
      AppLogger.error('SettlementReminderService.schedule failed', e);
    }
  }

  /// Cancels all pending reminders for [billId] (called when the bill flips
  /// to settled or is deleted).
  Future<void> cancelForBill(String billId) async {
    try {
      for (final id in notificationIds(billId)) {
        try {
          await _plugin.cancel(id);
        } catch (e) {
          AppLogger.error(
            'SettlementReminderService.cancel slot failed',
            e,
          );
        }
      }
      final all = _readAll();
      if (all.containsKey(billId)) {
        all[billId] = {'scheduled': const <String>[], 'cancelled': true};
        await _writeAll(all);
      }
    } catch (e) {
      AppLogger.error('SettlementReminderService.cancel failed', e);
    }
  }

  /// Bills with bookkeeping entries that are not cancelled (for diagnostics).
  List<String> trackedBills() => _readAll().keys.toList(growable: false);

  bool isCancelled(String billId) {
    final entry = _readAll()[billId];
    return entry is Map && entry['cancelled'] == true;
  }
}

/// Keep-alive provider so screens can schedule/cancel without blocking
/// startup (lazy: first read initializes the plugin off the critical path).
final settlementReminderServiceProvider =
    FutureProvider<SettlementReminderService>((ref) async {
      final prefs = await SharedPreferences.getInstance();
      final svc = SettlementReminderService(prefs: prefs);
      await svc.init();
      return svc;
    });
