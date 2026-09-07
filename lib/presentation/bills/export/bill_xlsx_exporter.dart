import 'package:excel/excel.dart';

import '../../../domain/entities/transfer_bank_info.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../providers/bill_detail_notifier.dart';

/// XLSX export (M2/F7, Plus-only — gated by the caller like PDF/CSV).
/// Mirrors [BillCsvExporter] row-for-row so numbers stay identical across
/// formats: amounts are written as numeric cells with raw doubles (parity
/// with CSV), never locale-formatted strings.
///
/// Safety:
/// - Sheet names are sanitized (31 chars, no `[]:*?/\`).
/// - Text cells starting with `=`, `+`, `-`, `@` get a `'` prefix so Excel
///   never interprets user input as a formula (formula-injection guard).
/// - Empty participants produce a header-only sheet (no throw).
class BillXlsxExporter {
  const BillXlsxExporter(this.state, {required this.l10n, this.bankInfo});

  final BillDetailState state;
  final AppL10n l10n;
  final TransferBankInfo? bankInfo;

  /// `bagistruk-<slug>-<billId8>.xlsx`. The bill-id suffix keeps filenames
  /// unique when two bills share a slug (`Bukber!!!` vs `Bukber`, emoji-only
  /// titles, or empty titles → `bagistruk-bill`).
  static String fileName(String title, String billId) {
    final cleaned = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final slug = cleaned.isEmpty ? 'bagistruk-bill' : 'bagistruk-$cleaned';
    final shortId = billId.length >= 8 ? billId.substring(0, 8) : billId;
    return '$slug-$shortId.xlsx';
  }

  /// Excel sheet names: max 31 chars, none of `[]:*?/\`.
  static String sanitizeSheetName(String name) {
    var clean = name.replaceAll(RegExp(r'[\[\]:*?/\\]'), ' ').trim();
    if (clean.isEmpty) clean = 'Sheet';
    return clean.length > 31 ? clean.substring(0, 31) : clean;
  }

  /// Prefixes formula-trigger characters so Excel treats the value as text.
  static String safeText(String value) {
    if (value.startsWith(RegExp(r'[=+\-@]'))) return "'$value";
    return value;
  }

  List<int> build() {
    final excel = Excel.createExcel();
    _buildItemsSheet(excel);
    _buildParticipantsSheet(excel);
    excel.delete('Sheet1');
    final bytes = excel.encode();
    if (bytes == null) throw StateError('XLSX encode failed');
    return bytes;
  }

  void _buildItemsSheet(Excel excel) {
    final sheet = excel[sanitizeSheetName(l10n.exportLabelItems)];
    final paidStatus = state.bill.isSettled
        ? l10n.exportLabelSettledYes
        : l10n.exportLabelSettledNo;
    sheet.appendRow([TextCellValue(safeText(l10n.exportCsvTopTitle(state.bill.title)))]);
    sheet.appendRow([]);
    sheet.appendRow([
      TextCellValue(l10n.exportLabelBillTitle),
      TextCellValue(safeText(state.bill.title)),
    ]);
    sheet.appendRow([
      TextCellValue(l10n.exportLabelCurrency),
      TextCellValue(state.bill.currencyCode),
    ]);
    sheet.appendRow([
      TextCellValue(l10n.exportLabelReceiptDate),
      TextCellValue(state.bill.receiptDate?.toIso8601String() ?? ''),
    ]);
    sheet.appendRow([
      TextCellValue(l10n.exportLabelCreatedAt),
      TextCellValue(state.bill.createdAt.toIso8601String()),
    ]);
    sheet.appendRow([
      TextCellValue(l10n.exportLabelTotalAmount),
      DoubleCellValue(state.bill.totalAmount),
    ]);
    sheet.appendRow([
      TextCellValue(l10n.exportLabelTax),
      DoubleCellValue(state.bill.tax),
    ]);
    sheet.appendRow([
      TextCellValue(l10n.exportLabelService),
      DoubleCellValue(state.bill.service),
    ]);
    sheet.appendRow([
      TextCellValue(l10n.exportLabelStatus),
      TextCellValue(paidStatus),
    ]);
    sheet.appendRow([]);
    sheet.appendRow([TextCellValue(l10n.exportLabelItems)]);
    sheet.appendRow([
      TextCellValue(l10n.exportLabelName),
      TextCellValue(l10n.exportLabelQty),
      TextCellValue(l10n.exportLabelPrice),
      TextCellValue(l10n.exportLabelSubtotal),
      TextCellValue(l10n.exportLabelAssignedParticipants),
    ]);

    final participantById = {
      for (final participant in state.participants) participant.id: participant,
    };
    for (final item in state.items) {
      final assigneeNames = state.assignments
          .where((assignment) => assignment.itemId == item.id)
          .map((assignment) => participantById[assignment.participantId]?.name)
          .whereType<String>()
          .join(', ');
      sheet.appendRow([
        TextCellValue(safeText(item.name)),
        DoubleCellValue(item.qty),
        DoubleCellValue(item.price),
        DoubleCellValue(item.subtotal),
        TextCellValue(safeText(assigneeNames)),
      ]);
    }

    final bank = bankInfo;
    if (bank != null && bank.isComplete) {
      sheet.appendRow([]);
      sheet.appendRow([TextCellValue(l10n.transferBankShareTitle)]);
      sheet.appendRow([
        TextCellValue(l10n.transferBankNameLabel),
        TextCellValue(safeText(bank.bankName.trim())),
      ]);
      sheet.appendRow([
        TextCellValue(l10n.transferAccountNameLabel),
        TextCellValue(safeText(bank.accountName.trim())),
      ]);
      sheet.appendRow([
        TextCellValue(l10n.transferAccountNumberLabel),
        TextCellValue(safeText(bank.accountNumber.trim())),
      ]);
    }
  }

  void _buildParticipantsSheet(Excel excel) {
    final sheet = excel[sanitizeSheetName(l10n.exportLabelParticipants)];
    sheet.appendRow([
      TextCellValue(l10n.exportLabelName),
      TextCellValue(l10n.exportLabelSubtotal),
      TextCellValue(l10n.exportLabelTax),
      TextCellValue(l10n.exportLabelService),
      TextCellValue(l10n.exportLabelTotal),
      TextCellValue(l10n.exportLabelStatus),
    ]);
    final totalsByParticipant = {
      for (final total in state.calculateTotals()) total.participantId: total,
    };
    for (final participant in state.participants) {
      final total = totalsByParticipant[participant.id];
      sheet.appendRow([
        TextCellValue(safeText(participant.name)),
        DoubleCellValue(total?.subtotal ?? 0),
        DoubleCellValue(total?.tax ?? 0),
        DoubleCellValue(total?.service ?? 0),
        DoubleCellValue(total?.total ?? 0),
        TextCellValue(
          participant.isPaid
              ? l10n.exportLabelPaidStatus
              : l10n.exportLabelUnpaidStatus,
        ),
      ]);
    }
  }
}
