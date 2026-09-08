// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillTemplate _$BillTemplateFromJson(Map<String, dynamic> json) =>
    _BillTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      useCount: (json['use_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$BillTemplateToJson(_BillTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'use_count': instance.useCount,
      'created_at': instance.createdAt.toIso8601String(),
    };
