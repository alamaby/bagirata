// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssignmentDto _$AssignmentDtoFromJson(Map<String, dynamic> json) =>
    _AssignmentDto(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      participantId: json['participant_id'] as String,
      shareWeight: (json['share_weight'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$AssignmentDtoToJson(_AssignmentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item_id': instance.itemId,
      'participant_id': instance.participantId,
      'share_weight': instance.shareWeight,
    };
