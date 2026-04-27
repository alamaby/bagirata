import 'package:freezed_annotation/freezed_annotation.dart';

import 'failure.dart';

part 'result.freezed.dart';

/// A discriminated union for fallible operations. Chosen over throwing because
/// repository boundaries should make failure modes part of the type signature
/// — callers cannot forget to handle them.
@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = ResultFailure<T>;
}

extension ResultX<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        ResultFailure() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success() => null,
        ResultFailure(:final failure) => failure,
      };
}
