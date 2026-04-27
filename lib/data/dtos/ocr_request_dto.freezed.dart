// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OcrRequestDto {

 List<String> get images; String? get hint;
/// Create a copy of OcrRequestDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrRequestDtoCopyWith<OcrRequestDto> get copyWith => _$OcrRequestDtoCopyWithImpl<OcrRequestDto>(this as OcrRequestDto, _$identity);

  /// Serializes this OcrRequestDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrRequestDto&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.hint, hint) || other.hint == hint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(images),hint);

@override
String toString() {
  return 'OcrRequestDto(images: $images, hint: $hint)';
}


}

/// @nodoc
abstract mixin class $OcrRequestDtoCopyWith<$Res>  {
  factory $OcrRequestDtoCopyWith(OcrRequestDto value, $Res Function(OcrRequestDto) _then) = _$OcrRequestDtoCopyWithImpl;
@useResult
$Res call({
 List<String> images, String? hint
});




}
/// @nodoc
class _$OcrRequestDtoCopyWithImpl<$Res>
    implements $OcrRequestDtoCopyWith<$Res> {
  _$OcrRequestDtoCopyWithImpl(this._self, this._then);

  final OcrRequestDto _self;
  final $Res Function(OcrRequestDto) _then;

/// Create a copy of OcrRequestDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? images = null,Object? hint = freezed,}) {
  return _then(_self.copyWith(
images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OcrRequestDto].
extension OcrRequestDtoPatterns on OcrRequestDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OcrRequestDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OcrRequestDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OcrRequestDto value)  $default,){
final _that = this;
switch (_that) {
case _OcrRequestDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OcrRequestDto value)?  $default,){
final _that = this;
switch (_that) {
case _OcrRequestDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> images,  String? hint)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OcrRequestDto() when $default != null:
return $default(_that.images,_that.hint);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> images,  String? hint)  $default,) {final _that = this;
switch (_that) {
case _OcrRequestDto():
return $default(_that.images,_that.hint);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> images,  String? hint)?  $default,) {final _that = this;
switch (_that) {
case _OcrRequestDto() when $default != null:
return $default(_that.images,_that.hint);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OcrRequestDto implements OcrRequestDto {
  const _OcrRequestDto({required final  List<String> images, this.hint}): _images = images;
  factory _OcrRequestDto.fromJson(Map<String, dynamic> json) => _$OcrRequestDtoFromJson(json);

 final  List<String> _images;
@override List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  String? hint;

/// Create a copy of OcrRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OcrRequestDtoCopyWith<_OcrRequestDto> get copyWith => __$OcrRequestDtoCopyWithImpl<_OcrRequestDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OcrRequestDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OcrRequestDto&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.hint, hint) || other.hint == hint));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_images),hint);

@override
String toString() {
  return 'OcrRequestDto(images: $images, hint: $hint)';
}


}

/// @nodoc
abstract mixin class _$OcrRequestDtoCopyWith<$Res> implements $OcrRequestDtoCopyWith<$Res> {
  factory _$OcrRequestDtoCopyWith(_OcrRequestDto value, $Res Function(_OcrRequestDto) _then) = __$OcrRequestDtoCopyWithImpl;
@override @useResult
$Res call({
 List<String> images, String? hint
});




}
/// @nodoc
class __$OcrRequestDtoCopyWithImpl<$Res>
    implements _$OcrRequestDtoCopyWith<$Res> {
  __$OcrRequestDtoCopyWithImpl(this._self, this._then);

  final _OcrRequestDto _self;
  final $Res Function(_OcrRequestDto) _then;

/// Create a copy of OcrRequestDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? images = null,Object? hint = freezed,}) {
  return _then(_OcrRequestDto(
images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
