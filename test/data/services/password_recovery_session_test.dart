import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bagistruk/data/services/password_recovery_session.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PasswordRecoverySession', () {
    test('isActive returns false when no flag is set', () async {
      final session = await PasswordRecoverySession.create();
      expect(session.isActive, isFalse);
    });

    test('markActive then isActive returns true', () async {
      final session = await PasswordRecoverySession.create();
      await session.markActive();
      expect(session.isActive, isTrue);
    });

    test('clear resets isActive to false', () async {
      final session = await PasswordRecoverySession.create();
      await session.markActive();
      expect(session.isActive, isTrue);

      await session.clear();
      expect(session.isActive, isFalse);
    });

    test('expired timestamp makes isActive return false', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('password_recovery_active_v1', true);
      await prefs.setInt(
        'password_recovery_started_at_v1',
        DateTime.now().toUtc().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
      );

      final session = await PasswordRecoverySession.create();
      expect(session.isActive, isFalse);
    });

    test('fresh timestamp within TTL keeps isActive true', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('password_recovery_active_v1', true);
      await prefs.setInt(
        'password_recovery_started_at_v1',
        DateTime.now().toUtc().subtract(const Duration(minutes: 30)).millisecondsSinceEpoch,
      );

      final session = await PasswordRecoverySession.create();
      expect(session.isActive, isTrue);
    });

    test('missing timestamp with active flag returns false (inconsistent state)', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('password_recovery_active_v1', true);
      // No timestamp key

      final session = await PasswordRecoverySession.create();
      expect(session.isActive, isFalse);
    });

    test('clear removes both keys', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('password_recovery_active_v1', true);
      await prefs.setInt(
        'password_recovery_started_at_v1',
        DateTime.now().toUtc().millisecondsSinceEpoch,
      );

      final session = await PasswordRecoverySession.create();
      await session.clear();

      expect(prefs.getBool('password_recovery_active_v1'), isNull);
      expect(prefs.getInt('password_recovery_started_at_v1'), isNull);
    });

    test('multiple markActive calls are idempotent', () async {
      final session = await PasswordRecoverySession.create();
      await session.markActive();
      await session.markActive();
      expect(session.isActive, isTrue);
    });

    test('markActive after clear works', () async {
      final session = await PasswordRecoverySession.create();
      await session.markActive();
      await session.clear();
      await session.markActive();
      expect(session.isActive, isTrue);
    });
  });
}