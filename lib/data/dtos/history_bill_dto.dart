import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/bill_payment_status.dart';
import '../../domain/entities/history_bill.dart';

part 'history_bill_dto.freezed.dart';
part 'history_bill_dto.g.dart';

@freezed
abstract class HistoryBillDto with _$HistoryBillDto {
  const factory HistoryBillDto({
    required String id,
    required String title,
    @JsonKey(name: 'total_amount') required double totalAmount,
    @JsonKey(name: 'currency_code') @Default('IDR') String currencyCode,
    @JsonKey(name: 'tax_amount') @Default(0) double tax,
    @JsonKey(name: 'service_charge') @Default(0) double service,
    @JsonKey(name: 'is_settled') @Default(false) bool isSettled,
    @JsonKey(name: 'receipt_date') DateTime? receiptDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default('lain') String category,
    @JsonKey(name: 'bill_tags') @Default([]) List<String> tags,
    @JsonKey(name: 'participant_count') required int participantCount,
    @JsonKey(name: 'paid_participant_count')
    required int paidParticipantCount,
    @JsonKey(name: 'payment_status') required String paymentStatus,
  }) = _HistoryBillDto;

  factory HistoryBillDto.fromJson(Map<String, dynamic> json) =>
      _$HistoryBillDtoFromJson(json);

  static BillPaymentStatus _parsePaymentStatus(String s) => switch (s) {
    'unassigned' => BillPaymentStatus.unassigned,
    'unpaid' => BillPaymentStatus.unpaid,
    'partial' => BillPaymentStatus.partial,
    'settled' => BillPaymentStatus.settled,
    _ => BillPaymentStatus.unassigned,
  };
}

extension HistoryBillDtoX on HistoryBillDto {
  HistoryBill toEntity() => HistoryBill(
    id: id,
    title: title,
    totalAmount: totalAmount,
    currencyCode: currencyCode,
    tax: tax,
    service: service,
    isSettled: isSettled,
    receiptDate: receiptDate,
    createdAt: createdAt,
    category: category,
    tags: tags,
    participantCount: participantCount,
    paidParticipantCount: paidParticipantCount,
    paymentStatus: HistoryBillDto._parsePaymentStatus(paymentStatus),
  );
}
