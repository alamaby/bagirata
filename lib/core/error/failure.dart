import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Domain-level error type. Data sources MUST translate framework exceptions
/// (PostgrestException, AuthException, FunctionException, SocketException…)
/// into one of these variants before crossing the repository boundary, so the
/// presentation layer never has to know about Supabase or HTTP.
@freezed
sealed class Failure with _$Failure {
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.server({int? code, required String message}) =
      ServerFailure;
  const factory Failure.parsing(String message) = ParsingFailure;
  const factory Failure.auth(String message) = AuthFailure;
  const factory Failure.unknown(Object error, StackTrace? stack) =
      UnknownFailure;
}
