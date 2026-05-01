// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileDto _$ProfileDtoFromJson(Map<String, dynamic> json) => _ProfileDto(
  id: json['id'] as String,
  displayName: json['display_name'] as String?,
  defaultCurrency: json['default_currency'] as String? ?? 'IDR',
  languagePref: json['language_pref'] as String? ?? 'id',
  themePref: json['theme_pref'] as String? ?? 'system',
);

Map<String, dynamic> _$ProfileDtoToJson(_ProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'display_name': ?instance.displayName,
      'default_currency': instance.defaultCurrency,
      'language_pref': instance.languagePref,
      'theme_pref': instance.themePref,
    };
