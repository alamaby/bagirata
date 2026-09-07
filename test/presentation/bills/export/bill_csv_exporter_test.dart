import 'package:bagistruk/domain/entities/assignment.dart';
import 'package:bagistruk/domain/entities/bill.dart';
import 'package:bagistruk/domain/entities/item.dart';
import 'package:bagistruk/domain/entities/participant.dart';
import 'package:bagistruk/domain/entities/transfer_bank_info.dart';
import 'package:bagistruk/l10n/generated/app_l10n_en.dart';
import 'package:bagistruk/presentation/bills/export/bill_csv_exporter.dart';
import 'package:bagistruk/presentation/bills/export/export_filenames.dart';
import 'package:bagistruk/presentation/bills/providers/bill_detail_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

BillDetailState _state() => BillDetailState(
  bill: Bill(
    id: 'bill-abc12345',
    title: 'Bukber',
    totalAmount: 110000,
    currencyCode: 'IDR',
    tax: 10000,
    service: 0,
    createdAt: DateTime.utc(2026, 9, 2),
  ),
  items: const [
    Item(id: 'i1', billId: 'bill-abc12345', name: 'Nasi', price: 50000, qty: 2),
  ],
  participants: const [
    Participant(id: 'p1', billId: 'bill-abc12345', name: 'Ani', isPaid: true),
  ],
  assignments: const [
    Assignment(id: 'a1', itemId: 'i1', participantId: 'p1'),
  ],
);

void main() {
  final l10n = AppL10nEn();

  group('BillCsvExporter bank block', () {
    test('includes bank block when complete info is passed (Plus)', () {
      const bank = TransferBankInfo(
        bankName: 'BCA',
        accountName: 'Ani',
        accountNumber: '123456',
      );
      final csv = BillCsvExporter(_state(), l10n: l10n, bankInfo: bank).build();

      expect(csv, contains('BCA'));
      expect(csv, contains('123456'));
    });

    test('omits bank block when null (Free parity)', () {
      final csv = BillCsvExporter(_state(), l10n: l10n).build();

      expect(csv, isNot(contains('BCA')));
      expect(csv, contains('Ani'));
    });

    test('omits bank block when incomplete', () {
      const bank = TransferBankInfo(
        bankName: '',
        accountName: '',
        accountNumber: '',
      );
      final csv = BillCsvExporter(_state(), l10n: l10n, bankInfo: bank).build();

      expect(csv, isNot(contains('Transfer ke')));
    });
  });

  group('ExportFilenames', () {
    test('unique across formats for the same bill', () {
      final csv = ExportFilenames.unique('Bukber', 'bill-abc12345', 'csv');
      final pdf = ExportFilenames.unique('Bukber', 'bill-abc12345', 'pdf');
      final xlsx = ExportFilenames.unique('Bukber', 'bill-abc12345', 'xlsx');
      expect(csv, 'bagistruk-bukber-bill-abc.csv');
      expect(pdf, 'bagistruk-bukber-bill-abc.pdf');
      expect(xlsx, 'bagistruk-bukber-bill-abc.xlsx');
      expect({csv, pdf, xlsx}, hasLength(3));
    });

    test('slug collisions resolved by bill-id suffix', () {
      final a = ExportFilenames.unique('Bukber!!!', 'bill-11111111', 'csv');
      final b = ExportFilenames.unique('Bukber', 'bill-22222222', 'csv');
      expect(a, isNot(equals(b)));
    });

    test('empty and emoji-only titles fall back safely', () {
      expect(
        ExportFilenames.unique('', 'bill-11111111', 'pdf'),
        'bagistruk-bill-bill-111.pdf',
      );
      expect(
        ExportFilenames.unique('🍜🎉', 'bill-11111111', 'pdf'),
        startsWith('bagistruk-bill-'),
      );
    });
  });
}
