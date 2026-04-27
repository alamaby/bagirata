import 'package:freezed_annotation/freezed_annotation.dart';

part 'participant.freezed.dart';

@freezed
abstract class Participant with _$Participant {
  const factory Participant({
    required String id,
    required String billId,
    required String name,
    @Default(false) bool isPaid,
    DateTime? paidAt,
  }) = _Participant;
}
