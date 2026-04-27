import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/assignment.dart';

part 'assignment_dto.freezed.dart';
part 'assignment_dto.g.dart';

@freezed
abstract class AssignmentDto with _$AssignmentDto {
  const AssignmentDto._();

  const factory AssignmentDto({
    required String id,
    @JsonKey(name: 'item_id') required String itemId,
    @JsonKey(name: 'participant_id') required String participantId,
    @JsonKey(name: 'share_weight') @Default(1.0) double shareWeight,
  }) = _AssignmentDto;

  factory AssignmentDto.fromJson(Map<String, dynamic> json) =>
      _$AssignmentDtoFromJson(json);

  factory AssignmentDto.fromEntity(Assignment a) => AssignmentDto(
        id: a.id,
        itemId: a.itemId,
        participantId: a.participantId,
        shareWeight: a.shareWeight,
      );

  Assignment toEntity() => Assignment(
        id: id,
        itemId: itemId,
        participantId: participantId,
        shareWeight: shareWeight,
      );
}
