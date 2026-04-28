// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillDto _$BillDtoFromJson(Map<String, dynamic> json) => _BillDto(
  id: json['id'] as String,
  title: json['title'] as String,
  totalAmount: (json['total_amount'] as num).toDouble(),
  tax: (json['tax_amount'] as num?)?.toDouble() ?? 0,
  service: (json['service_charge'] as num?)?.toDouble() ?? 0,
  isSettled: json['is_settled'] as bool? ?? false,
  receiptDate: json['receipt_date'] == null
      ? null
      : DateTime.parse(json['receipt_date'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BillDtoToJson(_BillDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'total_amount': instance.totalAmount,
  'tax_amount': instance.tax,
  'service_charge': instance.service,
  'is_settled': instance.isSettled,
  'receipt_date': ?instance.receiptDate?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};
