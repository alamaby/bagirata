import 'dart:convert';

import 'package:crypto/crypto.dart';
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
/// - Scheduling bookkeeping (bill → notification IDs, due dates, localized
///   copy) lives in SharedPreferences so reminders survive restarts and can
///   be rehydrated + cancelled after a reboot. The OS plugin only fires.
/// - Notification IDs are a stable SHA-256 derivation (Dart `hashCode` is
///   NOT stable across VM runs, so it must never be used here).
/// - Everything is best-effort: denied permissions, missing plugin, or a
///   killed process (no FCM in M1) must never crash the app — failures are
///   logged and swallowed.
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
  bool _permissionDenied = false;

  /// Pure: due dates for a bill created at [createdAt] (UTC).
  static List<DateTime> dueDates({required DateTime createdAt}) => [
    for (final d in reminderOffsetsDays)
      createdAt.toUtc().add(Duration(days: d)),
  ];

  /// Stable notification IDs per (billId, slot).
  ///
  /// Why not `billId.hashCode`: Dart string hashes are only stable within a
  /// single VM execution, so cancel-after-restart would target wrong IDs and
  /// leave orphan notifications. SHA-256 is deterministic everywhere.
  static List<int> notificationIds(String billId) {
    final digest = sha256
        .convert(utf8.encode('settlement-reminder:$billId'))
        .bytes;
    final base =
        ((digest[0] << 24) |
            (digest[1] << 16) |
            (digest[2] << 8) |
            digest[3]) &
        0x3fffffff;
    return [base * 2, base * 2 + 1];
  }

  /// Pure permission policy: only an explicit Android `false` counts as
  /// denied (`null` = older OS / auto-granted, iOS handled best-effort).
  static bool permissionDenied(bool? androidResult) => androidResult == false;

  /// One-time plugin + timezone init. Returns false when scheduling is
  /// impossible (tz/plugin init threw) so callers can bail before touching
  /// `tz.local` or the plugin. Also rehydrates pending entries so a reboot
  /// (which wipes OS alarms but not prefs) does not silently drop reminders.
  Future<bool> init() async {
    if (_initialized) return true;
    try {
      tzdata.initializeTimeZones();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: darwin),
      );
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await androidImpl?.requestNotificationsPermission();
      _permissionDenied = permissionDenied(granted);
      try {
        await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      } catch (e) {
        AppLogger.error('SettlementReminderService.iosPerm failed', e);
      }
      _initialized = true;
    } catch (e) {
      AppLogger.error('SettlementReminderService.init failed', e);
      return false;
    }
    await _rehydrate();
    return true;
  }

  /// Re-fires OS alarms for tracked, non-cancelled, still-future dues from
  /// prefs (same IDs → replace semantics, no duplicates).
  Future<void> _rehydrate() async {
    final now = _nowUtc().toUtc();
    final all = _readAll();
    for (final entry in all.entries) {
      final map = entry.value;
      if (map is! Map) continue;
      if (map['cancelled'] == true) continue;
      final ids = _idsOf(entry.key, map);
      final title = map['title'];
      final body = map['body'];
      if (title is! String || body is! String) continue;
      final scheduled = map['scheduled'];
      if (scheduled is! List) continue;
      for (var i = 0; i < scheduled.length && i < ids.length; i++) {
        final due = DateTime.tryParse(scheduled[i].toString())?.toUtc();
        if (due == null || !due.isAfter(now)) continue;
        try {
          await _scheduleOs(ids[i], entry.key, title, body, due);
        } catch (e) {
          AppLogger.error('SettlementReminderService.rehydrate failed', e);
        }
      }
    }
  }

  Future<void> _scheduleOs(
    int id,
    String billId,
    String title,
    String body,
    DateTime dueUtc,
  ) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dueUtc, tz.local),
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

  /// Stored IDs win (exact cancel); legacy entries without IDs fall back to
  /// the deterministic hash.
  List<int> _idsOf(String billId, Map<dynamic, dynamic> entry) {
    final ids = entry['ids'];
    if (ids is List &&
        ids.length == 2 &&
        ids.every((e) => e is int)) {
      return [ids[0] as int, ids[1] as int];
    }
    return notificationIds(billId);
  }

  /// Schedules T+3/T+7 reminders for a bill. Past dues are skipped; already
  /// settled bills and explicit permission denials are no-ops. Entries with
  /// zero schedulable slots are pruned (no phantom bookkeeping). Callers pass
  /// localized [notificationTitle]/[notificationBody] (ARB
  /// `reminderNotification*`) so the service stays locale-free.
  Future<void> scheduleForBill({
    required String billId,
    required String notificationTitle,
    required String notificationBody,
    required DateTime createdAt,
    bool isSettled = false,
  }) async {
    if (isSettled) return;
    try {
      final ok = await init();
      if (!ok || _permissionDenied) return;
      final now = _nowUtc().toUtc();
      final due = dueDates(createdAt: createdAt);
      final ids = notificationIds(billId);
      final scheduled = <String>[];
      for (var i = 0; i < due.length; i++) {
        if (!due[i].isAfter(now)) continue;
        // Per-slot best-effort, recorded only on success.
        try {
          await _scheduleOs(
            ids[i],
            billId,
            notificationTitle,
            notificationBody,
            due[i],
          );
          scheduled.add(due[i].toIso8601String());
        } catch (e) {
          AppLogger.error(
            'SettlementReminderService.schedule slot failed',
            e,
          );
        }
      }
      final all = _readAll();
      if (scheduled.isEmpty) {
        all.remove(billId);
      } else {
        all[billId] = {
          'ids': ids,
          'scheduled': scheduled,
          'title': notificationTitle,
          'body': notificationBody,
          'cancelled': false,
        };
      }
      await _writeAll(all);
    } catch (e) {
      AppLogger.error('SettlementReminderService.schedule failed', e);
    }
  }

  /// Cancels all pending reminders for [billId] (settled or deleted bills).
  /// Initializes the plugin first — settle-after-restart is the common case.
  Future<void> cancelForBill(String billId) async {
    try {
      await init();
      final all = _readAll();
      final entry = all[billId];
      final ids = entry is Map
          ? _idsOf(billId, entry)
          : notificationIds(billId);
      for (final id in ids) {
        try {
          await _plugin.cancel(id);
        } catch (e) {
          AppLogger.error(
            'SettlementReminderService.cancel slot failed',
            e,
          );
        }
      }
      if (all.containsKey(billId)) {
        final prev = all[billId];
        all[billId] = {
          'ids': ids,
          'scheduled': const <String>[],
          'title': prev is Map ? prev['title'] : null,
          'body': prev is Map ? prev['body'] : null,
          'cancelled': true,
        };
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
