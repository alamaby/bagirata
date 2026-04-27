// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillDto _$BillDtoFromJson(Map<String, dynamic> json) => _BillDto(
  id: json['id'] as String,
  title: json['title'] as String,
  totalAmount: (json['total_amount'] as num).toDouble(),
  tax: (json['tax'] as num?)?.toDouble() ?? 0,
  service: (json['service'] as num?)?.toDouble() ?? 0,
  isSettled: json['is_settled'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$BillDtoToJson(_BillDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'total_amount': instance.totalAmount,
  'tax': instance.tax,
  'service': instance.service,
  'is_settled': instance.isSettled,
  'created_at': instance.createdAt.toIso8601String(),
};
