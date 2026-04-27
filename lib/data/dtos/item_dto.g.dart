// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ItemDto _$ItemDtoFromJson(Map<String, dynamic> json) => _ItemDto(
  id: json['id'] as String,
  billId: json['bill_id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  qty: (json['qty'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$ItemDtoToJson(_ItemDto instance) => <String, dynamic>{
  'id': instance.id,
  'bill_id': instance.billId,
  'name': instance.name,
  'price': instance.price,
  'qty': instance.qty,
};
