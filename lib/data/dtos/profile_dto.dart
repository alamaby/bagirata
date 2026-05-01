import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_dto.freezed.dart';
part 'profile_dto.g.dart';

@freezed
abstract class ProfileDto with _$ProfileDto {
  const ProfileDto._();

  const factory ProfileDto({
    required String id,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'default_currency') @Default('IDR') String defaultCurrency,
    @JsonKey(name: 'language_pref') @Default('id') String languagePref,
    @JsonKey(name: 'theme_pref') @Default('system') String themePref,
  }) = _ProfileDto;

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);
}
