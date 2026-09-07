import '../../../domain/entities/transfer_bank_info.dart';
import '../../../l10n/generated/app_l10n.dart';
import '../providers/bill_detail_notifier.dart';

class BillCsvExporter {
  const BillCsvExporter(this.state, {required this.l10n, this.bankInfo});

  final BillDetailState state;
  final AppL10n l10n;

  /// Included only when the caller passes a complete value (Plus-only,
  /// like PDF/XLSX) so Free CSVs never leak bank details.
  final TransferBankInfo? bankInfo;

  String build() {
    final rows = <List<Object?>>[
      [l10n.exportCsvTopTitle(state.bill.title)],
      [],
      [l10n.exportLabelBillTitle, state.bill.title],
      [l10n.exportLabelCurrency, state.bill.currencyCode],
      [l10n.exportLabelReceiptDate, state.bill.receiptDate?.toIso8601String() ?? ''],
      [l10n.exportLabelCreatedAt, state.bill.createdAt.toIso8601String()],
      [l10n.exportLabelTotalAmount, state.bill.totalAmount],
      [l10n.exportLabelTax, state.bill.tax],
      [l10n.exportLabelService, state.bill.service],
      [
        l10n.exportLabelStatus,
        state.bill.isSettled
            ? l10n.exportLabelSettledYes
            : l10n.exportLabelSettledNo,
      ],
      [],
      [
        l10n.exportLabelItems,
      ],
      [
        l10n.exportLabelName,
        l10n.exportLabelQty,
        l10n.exportLabelPrice,
        l10n.exportLabelSubtotal,
        l10n.exportLabelAssignedParticipants,
      ],
    ];

    final participantById = {
      for (final participant in state.participants) participant.id: participant,
    };
    for (final item in state.items) {
      final assigneeNames = state.assignments
          .where((assignment) => assignment.itemId == item.id)
          .map((assignment) => participantById[assignment.participantId]?.name)
          .whereType<String>()
          .join(', ');
      rows.add([item.name, item.qty, item.price, item.subtotal, assigneeNames]);
    }

    rows.addAll([
      [],
      [l10n.exportLabelParticipants],
      [
        l10n.exportLabelName,
        l10n.exportLabelSubtotal,
        l10n.exportLabelTax,
        l10n.exportLabelService,
        l10n.exportLabelTotal,
        l10n.exportLabelStatus,
      ],
    ]);
    final totalsByParticipant = {
      for (final total in state.calculateTotals()) total.participantId: total,
    };
    for (final participant in state.participants) {
      final total = totalsByParticipant[participant.id];
      rows.add([
        participant.name,
        total?.subtotal ?? 0,
        total?.tax ?? 0,
        total?.service ?? 0,
        total?.total ?? 0,
        participant.isPaid
            ? l10n.exportLabelPaidStatus
            : l10n.exportLabelUnpaidStatus,
      ]);
    }

    final bank = bankInfo;
    if (bank != null && bank.isComplete) {
      rows.addAll([
        [],
        [l10n.transferBankShareTitle],
        [l10n.transferBankNameLabel, bank.bankName.trim()],
        [l10n.transferAccountNameLabel, bank.accountName.trim()],
        [l10n.transferAccountNumberLabel, bank.accountNumber.trim()],
      ]);
    }

    return rows.map(_encodeRow).join('\r\n');
  }

  static String _encodeRow(List<Object?> row) =>
      row.map((value) => _encodeCell(value?.toString() ?? '')).join(',');

  static String _encodeCell(String value) {
    final needsQuote =
        value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    final escaped = value.replaceAll('"', '""');
    return needsQuote ? '"$escaped"' : escaped;
  }
}
