import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_snapshot.freezed.dart';

@freezed
sealed class AuthSnapshot with _$AuthSnapshot {
  const factory AuthSnapshot({
    required String? userId,
    required bool isAnonymous,
  }) = _AuthSnapshot;

  const AuthSnapshot._();

  bool get isSignedIn => userId != null && !isAnonymous;
}
