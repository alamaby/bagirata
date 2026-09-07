import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/bill.dart';

part 'bill_dto.freezed.dart';
part 'bill_dto.g.dart';

@freezed
abstract class BillDto with _$BillDto {
  const BillDto._();

  const factory BillDto({
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
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default([])
    List<bool> participantPaymentStatuses,
  }) = _BillDto;

  factory BillDto.fromJson(Map<String, dynamic> json) =>
      _$BillDtoFromJson(json);

  factory BillDto.fromJsonWithParticipants(
    Map<String, dynamic> json,
  ) {
    final dto = BillDto.fromJson(json);
    final participants = json['participants'];
    final statuses = (participants as List?)
            ?.map((e) => (e is Map ? e['is_paid'] : false) == true)
            .toList() ??
        [];
    return dto.copyWith(participantPaymentStatuses: statuses);
  }

  factory BillDto.fromEntity(Bill b) => BillDto(
    id: b.id,
    title: b.title,
    totalAmount: b.totalAmount,
    currencyCode: b.currencyCode,
    tax: b.tax,
    service: b.service,
    isSettled: b.isSettled,
    receiptDate: b.receiptDate,
    createdAt: b.createdAt,
    category: b.category,
    tags: b.tags,
    participantPaymentStatuses: b.participantPaymentStatuses,
  );

  Bill toEntity() => Bill(
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
    participantPaymentStatuses: participantPaymentStatuses,
  );
}
