import 'package:freezed_annotation/freezed_annotation.dart';

part 'assignment.freezed.dart';

/// Links a [Participant] to an [Item] with a [shareWeight] (default 1.0).
///
/// Why a weight rather than a boolean: real receipts include items consumed
/// unevenly (e.g. one person ate 2/3 of a shared dish). Weights generalize
/// the equal-split case (everyone weight=1) without a separate code path.
@freezed
abstract class Assignment with _$Assignment {
  const factory Assignment({
    required String id,
    required String itemId,
    required String participantId,
    @Default(1.0) double shareWeight,
  }) = _Assignment;
}
