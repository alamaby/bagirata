import 'package:freezed_annotation/freezed_annotation.dart';

import 'bill_payment_status.dart';

part 'history_bill.freezed.dart';

@freezed
abstract class HistoryBill with _$HistoryBill {
  const factory HistoryBill({
    required String id,
    required String title,
    required double totalAmount,
    @Default('IDR') String currencyCode,
    @Default(0) double tax,
    @Default(0) double service,
    @Default(false) bool isSettled,
    DateTime? receiptDate,
    required DateTime createdAt,
    @Default('lain') String category,
    @Default([]) List<String> tags,
    required int participantCount,
    required int paidParticipantCount,
    required BillPaymentStatus paymentStatus,
  }) = _HistoryBill;
}
