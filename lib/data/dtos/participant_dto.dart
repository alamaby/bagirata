import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/participant.dart';

part 'participant_dto.freezed.dart';
part 'participant_dto.g.dart';

@freezed
abstract class ParticipantDto with _$ParticipantDto {
  const ParticipantDto._();

  const factory ParticipantDto({
    required String id,
    @JsonKey(name: 'bill_id') required String billId,
    required String name,
    @JsonKey(name: 'is_paid') @Default(false) bool isPaid,
    @JsonKey(name: 'paid_at') DateTime? paidAt,
  }) = _ParticipantDto;

  factory ParticipantDto.fromJson(Map<String, dynamic> json) =>
      _$ParticipantDtoFromJson(json);

  factory ParticipantDto.fromEntity(Participant p) => ParticipantDto(
        id: p.id,
        billId: p.billId,
        name: p.name,
        isPaid: p.isPaid,
        paidAt: p.paidAt,
      );

  Participant toEntity() => Participant(
        id: id,
        billId: billId,
        name: name,
        isPaid: isPaid,
        paidAt: paidAt,
      );
}
