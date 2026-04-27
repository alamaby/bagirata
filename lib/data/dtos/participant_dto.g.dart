// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParticipantDto _$ParticipantDtoFromJson(Map<String, dynamic> json) =>
    _ParticipantDto(
      id: json['id'] as String,
      billId: json['bill_id'] as String,
      name: json['name'] as String,
      isPaid: json['is_paid'] as bool? ?? false,
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
    );

Map<String, dynamic> _$ParticipantDtoToJson(_ParticipantDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bill_id': instance.billId,
      'name': instance.name,
      'is_paid': instance.isPaid,
      'paid_at': ?instance.paidAt?.toIso8601String(),
    };
