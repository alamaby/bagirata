import 'package:bagistruk/domain/entities/assignment.dart';
import 'package:bagistruk/domain/entities/bill.dart';
import 'package:bagistruk/domain/entities/item.dart';
import 'package:bagistruk/domain/entities/participant.dart';
import 'package:bagistruk/domain/entities/transfer_bank_info.dart';
import 'package:bagistruk/l10n/generated/app_l10n_en.dart';
import 'package:bagistruk/presentation/bills/export/bill_csv_exporter.dart';
import 'package:bagistruk/presentation/bills/export/bill_xlsx_exporter.dart';
import 'package:bagistruk/presentation/bills/providers/bill_detail_notifier.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

BillDetailState _state({
  String title = 'Bukber 12 orang 🍜',
  String currency = 'IDR',
  List<Item>? items,
  List<Participant>? participants,
  List<Assignment>? assignments,
}) {
  const billId = 'bill-abc12345';
  final its =
      items ??
      const [
        Item(id: 'i1', billId: billId, name: 'Nasi goreng', price: 50000, qty: 2),
        Item(id: 'i2', billId: billId, name: 'Es teh', price: 10000, qty: 5),
      ];
  final parts =
      participants ??
      const [
        Participant(id: 'p1', billId: billId, name: 'Ani', isPaid: true),
        Participant(id: 'p2', billId: billId, name: 'Budi'),
      ];
  final assigns =
      assignments ??
      const [
        Assignment(id: 'a1', itemId: 'i1', participantId: 'p1'),
        Assignment(id: 'a2', itemId: 'i1', participantId: 'p2'),
        Assignment(id: 'a3', itemId: 'i2', participantId: 'p2'),
      ];
  return BillDetailState(
    bill: Bill(
      id: billId,
      title: title,
      totalAmount: 165000,
      currencyCode: currency,
      tax: 10000,
      service: 5000,
      createdAt: DateTime.utc(2026, 9, 2),
    ),
    items: its,
    participants: parts,
    assignments: assigns,
  );
}

dynamic _cellValue(Sheet sheet, String ref) =>
    // ignore: avoid_dynamic_calls
    sheet.cell(CellIndex.indexByString(ref)).value;

// ignore: avoid_dynamic_calls
Object? _unwrapped(dynamic cellValue) {
  final v = cellValue;
  if (v == null) return null;
  try {
    return (v as dynamic).value;
  } catch (_) {
    return v.toString();
  }
}

void main() {
  final l10n = AppL10nEn();

  group('BillXlsxExporter', () {
    test('builds two sheets and encodes to bytes', () {
      final bytes = BillXlsxExporter(_state(), l10n: l10n).build();
      expect(bytes, isNotEmpty);
      final excel = Excel.decodeBytes(bytes);
      expect(excel.tables.keys, hasLength(2));
    });

    test('numeric parity with CSV totals (raw doubles)', () {
      final state = _state();
      final bytes = BillXlsxExporter(state, l10n: l10n).build();
      final excel = Excel.decodeBytes(bytes);

      final totals = {
        for (final t in state.calculateTotals()) t.participantId: t,
      };
      Sheet pesertaSheet(Excel x) => x.tables[BillXlsxExporter.sanitizeSheetName(
        l10n.exportLabelParticipants,
      )]!;
      Sheet itemsSheet(Excel x) => x.tables[BillXlsxExporter.sanitizeSheetName(
        l10n.exportLabelItems,
      )]!;
      final peserta = pesertaSheet(excel);
      final names = <String, int>{};
      // Scan rows until an empty name cell.
      String? nameAt(int row) {
        // ignore: avoid_dynamic_calls
        final v = _unwrapped(
          peserta.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row - 1)).value,
        );
        return v?.toString().isEmpty == true ? null : v?.toString();
      }
      for (var row = 2; nameAt(row) != null; row++) {
        names[nameAt(row)!] = row;
      }
      expect(names.keys, containsAll(['Ani', 'Budi']));
      for (final entry in names.entries) {
        // ignore: avoid_dynamic_calls
        final totalCell = _unwrapped(
          peserta
              .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: entry.value - 1))
              .value,
        );
        final expected = totals.values
            .firstWhere(
              (t) =>
                  state.participants
                      .firstWhere((p) => p.id == t.participantId)
                      .name ==
                  entry.key,
            )
            .total;
        expect((totalCell as num).toDouble(), expected);
      }

      // Items sheet carries the same raw item numbers as CSV.
      final csv = BillCsvExporter(state, l10n: l10n).build();
      expect(csv, contains('50000'));
      final items = itemsSheet(excel);
      var foundPrice = false;
      for (var r = 1; r <= items.maxRows; r++) {
        for (var c = 0; c < 5; c++) {
          // ignore: avoid_dynamic_calls
          final v = _unwrapped(
            items.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r - 1)).value,
          );
          if (v is num && v.toDouble() == 50000) foundPrice = true;
        }
      }
      expect(foundPrice, isTrue);
    });

    test('empty participants produce a header-only sheet without throwing', () {
      final bytes = BillXlsxExporter(
        _state(participants: const [], assignments: const []),
        l10n: l10n,
      ).build();
      final excel = Excel.decodeBytes(bytes);
      expect(excel.tables.keys, hasLength(2));
      final peserta =
          excel.tables[BillXlsxExporter.sanitizeSheetName(
            l10n.exportLabelParticipants,
          )]!;
      expect(peserta.maxRows, 1);
    });

    test('formula-trigger text is neutralized, unicode survives', () {
      final bytes = BillXlsxExporter(
        _state(
          items: const [
            Item(
              id: 'i1',
              billId: 'bill-abc12345',
              name: '=1+1',
              price: 1000,
              qty: 1,
            ),
            Item(
              id: 'i2',
              billId: 'bill-abc12345',
              name: 'Mie ayam 🍜',
              price: 2000,
              qty: 1,
            ),
          ],
          participants: const [
            Participant(id: 'p1', billId: 'bill-abc12345', name: 'Ani'),
          ],
          assignments: const [
            Assignment(id: 'a1', itemId: 'i1', participantId: 'p1'),
            Assignment(id: 'a2', itemId: 'i2', participantId: 'p1'),
          ],
        ),
        l10n: l10n,
      ).build();
      final excel = Excel.decodeBytes(bytes);
      final items = excel.tables[BillXlsxExporter.sanitizeSheetName(
        l10n.exportLabelItems,
      )]!;
      // Deterministic layout after round-trip (`appendRow([])` blanks are
      // not stored by the encoder): row 0 title, rows 1-8 meta, row 9
      // section title, row 10 header, rows 11+ items.
      String textAt(int row, int col) =>
          _unwrapped(
                items
                    .cell(
                      CellIndex.indexByColumnRow(
                        columnIndex: col,
                        rowIndex: row,
                      ),
                    )
                    .value,
              )?.toString() ??
          '';
      expect(textAt(11, 0), "'=1+1");
      expect(textAt(12, 0), 'Mie ayam 🍜');
    });

    test('bank block appears only when complete', () {
      const bank = TransferBankInfo(
        bankName: 'BCA',
        accountName: 'Ani',
        accountNumber: '123',
      );
      final withBank =
          Excel.decodeBytes(
            BillXlsxExporter(_state(), l10n: l10n, bankInfo: bank).build(),
          ).tables.values.expand((s) sync* {
            for (var r = 0; r < s.maxRows; r++) {
              for (var c = 0; c < s.maxColumns; c++) {
                // ignore: avoid_dynamic_calls
                yield _unwrapped(
                  s
                      .cell(
                        CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
                      )
                      .value,
                )?.toString();
              }
            }
          }).toList();
      expect(withBank, contains('BCA'));

      final withoutBank = Excel.decodeBytes(
        BillXlsxExporter(_state(), l10n: l10n).build(),
      ).tables.values.expand((s) sync* {
        for (var r = 0; r < s.maxRows; r++) {
          for (var c = 0; c < s.maxColumns; c++) {
            // ignore: avoid_dynamic_calls
            yield _unwrapped(
              s
                  .cell(
                    CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
                  )
                  .value,
            )?.toString();
          }
        }
      }).toList();
      expect(withoutBank, isNot(contains('BCA')));
    });
  });

  group('BillXlsxExporter.fileName', () {
    test('slug + bill-id suffix keeps names unique', () {
      final a = BillXlsxExporter.fileName('Bukber!!!', 'bill-11111111');
      final b = BillXlsxExporter.fileName('Bukber', 'bill-22222222');
      expect(a, isNot(equals(b)));
      expect(a.endsWith('.xlsx'), isTrue);
    });

    test('empty and emoji-only titles fall back safely', () {
      expect(
        BillXlsxExporter.fileName('', 'bill-11111111'),
        startsWith('bagistruk-bill-'),
      );
      expect(
        BillXlsxExporter.fileName('🍜🎉', 'bill-11111111'),
        startsWith('bagistruk-bill-'),
      );
    });
  });

  group('BillXlsxExporter.sanitizeSheetName', () {
    test('strips illegal chars and caps at 31', () {
      expect(
        BillXlsxExporter.sanitizeSheetName('A:B/C[D]E*F?G' * 5),
        hasLength(31),
      );
      expect(BillXlsxExporter.sanitizeSheetName(''), 'Sheet');
    });
  });
}
