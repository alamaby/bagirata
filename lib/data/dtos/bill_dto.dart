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
    @JsonKey(name: 'tax_amount') @Default(0) double tax,
    @JsonKey(name: 'service_charge') @Default(0) double service,
    @JsonKey(name: 'is_settled') @Default(false) bool isSettled,
    @JsonKey(name: 'receipt_date') DateTime? receiptDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _BillDto;

  factory BillDto.fromJson(Map<String, dynamic> json) => _$BillDtoFromJson(json);

  factory BillDto.fromEntity(Bill b) => BillDto(
        id: b.id,
        title: b.title,
        totalAmount: b.totalAmount,
        tax: b.tax,
        service: b.service,
        isSettled: b.isSettled,
        receiptDate: b.receiptDate,
        createdAt: b.createdAt,
      );

  Bill toEntity() => Bill(
        id: id,
        title: title,
        totalAmount: totalAmount,
        tax: tax,
        service: service,
        isSettled: isSettled,
        receiptDate: receiptDate,
        createdAt: createdAt,
      );
}
