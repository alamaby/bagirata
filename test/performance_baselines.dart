// Performance baseline tests — Phase A (print only).
//
// Run: flutter test --tags perf
//
// After running, record the output and set budget = baseline × 5.
// Then update each test's expect(lessThan(Duration(...))).

// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:bagistruk/core/error/exception_mapper.dart';
import 'package:bagistruk/core/format/currency_formatter.dart';
import 'package:bagistruk/core/format/device_locale_defaults.dart';
import 'package:bagistruk/core/format/phone_formatter.dart';
import 'package:bagistruk/domain/entities/transfer_bank_info.dart';
import 'package:bagistruk/l10n/generated/app_l10n_en.dart';
import 'package:bagistruk/presentation/auth/widgets/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppL10nEn();
  group('Performance baselines', () {
    test('PhoneFormatter.normalize throughput', () {
      final sw = Stopwatch()..start();
      for (var i = 0; i < 10000; i++) {
        PhoneFormatter.normalize('+62 812-3456-789$i');
      }
      sw.stop();
      print('normalize_x_10k: ${sw.elapsedMilliseconds} ms');
      // TODO(perf): add expect(sw.elapsed, lessThan(Duration(...)))
    }, tags: ['perf']);

    test('CurrencyFormatter.matchesQuery throughput', () {
      final defs = CurrencyFormatter.definitions;
      final sw = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        for (final def in defs) {
          CurrencyFormatter.matchesQuery(def, 'Dollar');
        }
      }
      sw.stop();
      print('matchesQuery_x_22k: ${sw.elapsedMilliseconds} ms');
      // TODO(perf): add expect(sw.elapsed, lessThan(Duration(...)))
    }, tags: ['perf']);

    test('CurrencyFormatter.definitionOf throughput', () {
      final sw = Stopwatch()..start();
      for (var i = 0; i < 10000; i++) {
        CurrencyFormatter.definitionOf('XYZ');
      }
      sw.stop();
      print('definitionOf_x_10k: ${sw.elapsedMilliseconds} ms');
      // TODO(perf): add expect(sw.elapsed, lessThan(Duration(...)))
    }, tags: ['perf']);

    test('DeviceLocaleDefaults.resolveLanguage + resolveCurrency throughput', () {
      final locales = [
        const Locale('id', 'ID'),
        const Locale('en', 'US'),
        const Locale('en', 'FR'),
      ];
      final sw = Stopwatch()..start();
      for (var i = 0; i < 100000; i++) {
        DeviceLocaleDefaults.resolveLanguage(locales);
        DeviceLocaleDefaults.resolveCurrency(locales);
      }
      sw.stop();
      print('resolveLocale_x_100k: ${sw.elapsedMilliseconds} ms');
      // TODO(perf): add expect(sw.elapsed, lessThan(Duration(...)))
    }, tags: ['perf']);

    test('validateEmail + validatePassword throughput', () {
      final sw = Stopwatch()..start();
      for (var i = 0; i < 10000; i++) {
        validateEmail('user$i@example.com', l10n);
        validatePassword('password$i', l10n);
      }
      sw.stop();
      print('validators_x_10k: ${sw.elapsedMilliseconds} ms');
      // TODO(perf): add expect(sw.elapsed, lessThan(Duration(...)))
    }, tags: ['perf']);

    test('guardAsync success path throughput', () async {
      final sw = Stopwatch()..start();
      for (var i = 0; i < 100000; i++) {
        await guardAsync(() async => i);
      }
      sw.stop();
      print('guardAsync_x_100k: ${sw.elapsedMilliseconds} ms');
      // TODO(perf): add expect(sw.elapsed, lessThan(Duration(...)))
    }, tags: ['perf']);

    test('TransferBankInfo.fromProfileRow throughput', () {
      final row = {
        'transfer_bank_name': 'BCA',
        'transfer_account_name': 'Andi',
        'transfer_account_number': '123456',
      };
      final sw = Stopwatch()..start();
      for (var i = 0; i < 100000; i++) {
        TransferBankInfo.fromProfileRow(row);
      }
      sw.stop();
      print('fromProfileRow_x_100k: ${sw.elapsedMilliseconds} ms');
      // TODO(perf): add expect(sw.elapsed, lessThan(Duration(...)))
    }, tags: ['perf']);
  });
}
