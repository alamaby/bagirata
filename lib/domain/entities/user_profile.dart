import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    String? displayName,
    String? email,
    @Default('IDR') String defaultCurrency,
    @Default('id') String languagePref,
    @Default('system') String themePref,
    @Default(false) bool isAnonymous,
  }) = _UserProfile;
}
