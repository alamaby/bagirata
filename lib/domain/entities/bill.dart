import 'package:freezed_annotation/freezed_annotation.dart';

import 'bill_payment_status.dart';

part 'bill.freezed.dart';

@freezed
abstract class Bill with _$Bill {
  const Bill._();

  const factory Bill({
    required String id,
    required String title,
    required double totalAmount,
    @Default('IDR') String currencyCode,
    @Default(0) double tax,
    @Default(0) double service,
    @Default(false) bool isSettled,
    DateTime? receiptDate,
    required DateTime createdAt,
    /// Bill category preset (`makan`, `transport`, `groceries`, `belanja`,
    /// `lain`). Server CHECK-enforced; unknown values never persist.
    @Default('lain') String category,
    /// Plus-only custom tags (max 5, normalized client-side). Excluded from
    /// the public share-link snapshot.
    @Default([]) List<String> tags,
    /// Summary of participant payment statuses from the History list query.
    /// Populated only via [BillDto.fromJsonWithParticipants]; `getBill()`
    /// and `upsertBill()` always return an empty list.
    /// A non-empty list means **all** participants are accounted for here.
    /// Empty does NOT imply zero participants — use `paymentStatus` getter
    /// (which returns [BillPaymentStatus.unassigned] for empty) only when
    /// this list is known to be complete (i.e. the History list route).
    @Default([]) List<bool> participantPaymentStatuses,
  }) = _Bill;

  BillPaymentStatus get paymentStatus {
    if (participantPaymentStatuses.isEmpty) return BillPaymentStatus.unassigned;
    if (participantPaymentStatuses.every((p) => p)) return BillPaymentStatus.settled;
    if (participantPaymentStatuses.any((p) => p)) return BillPaymentStatus.partial;
    return BillPaymentStatus.unpaid;
  }
}
