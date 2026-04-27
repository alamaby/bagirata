// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assignment_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssignmentDto {

 String get id;@JsonKey(name: 'item_id') String get itemId;@JsonKey(name: 'participant_id') String get participantId;@JsonKey(name: 'share_weight') double get shareWeight;
/// Create a copy of AssignmentDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignmentDtoCopyWith<AssignmentDto> get copyWith => _$AssignmentDtoCopyWithImpl<AssignmentDto>(this as AssignmentDto, _$identity);

  /// Serializes this AssignmentDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssignmentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.shareWeight, shareWeight) || other.shareWeight == shareWeight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,participantId,shareWeight);

@override
String toString() {
  return 'AssignmentDto(id: $id, itemId: $itemId, participantId: $participantId, shareWeight: $shareWeight)';
}


}

/// @nodoc
abstract mixin class $AssignmentDtoCopyWith<$Res>  {
  factory $AssignmentDtoCopyWith(AssignmentDto value, $Res Function(AssignmentDto) _then) = _$AssignmentDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'participant_id') String participantId,@JsonKey(name: 'share_weight') double shareWeight
});




}
/// @nodoc
class _$AssignmentDtoCopyWithImpl<$Res>
    implements $AssignmentDtoCopyWith<$Res> {
  _$AssignmentDtoCopyWithImpl(this._self, this._then);

  final AssignmentDto _self;
  final $Res Function(AssignmentDto) _then;

/// Create a copy of AssignmentDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? itemId = null,Object? participantId = null,Object? shareWeight = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as String,shareWeight: null == shareWeight ? _self.shareWeight : shareWeight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AssignmentDto].
extension AssignmentDtoPatterns on AssignmentDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssignmentDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssignmentDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssignmentDto value)  $default,){
final _that = this;
switch (_that) {
case _AssignmentDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssignmentDto value)?  $default,){
final _that = this;
switch (_that) {
case _AssignmentDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'participant_id')  String participantId, @JsonKey(name: 'share_weight')  double shareWeight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssignmentDto() when $default != null:
return $default(_that.id,_that.itemId,_that.participantId,_that.shareWeight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'participant_id')  String participantId, @JsonKey(name: 'share_weight')  double shareWeight)  $default,) {final _that = this;
switch (_that) {
case _AssignmentDto():
return $default(_that.id,_that.itemId,_that.participantId,_that.shareWeight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'item_id')  String itemId, @JsonKey(name: 'participant_id')  String participantId, @JsonKey(name: 'share_weight')  double shareWeight)?  $default,) {final _that = this;
switch (_that) {
case _AssignmentDto() when $default != null:
return $default(_that.id,_that.itemId,_that.participantId,_that.shareWeight);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssignmentDto extends AssignmentDto {
  const _AssignmentDto({required this.id, @JsonKey(name: 'item_id') required this.itemId, @JsonKey(name: 'participant_id') required this.participantId, @JsonKey(name: 'share_weight') this.shareWeight = 1.0}): super._();
  factory _AssignmentDto.fromJson(Map<String, dynamic> json) => _$AssignmentDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'item_id') final  String itemId;
@override@JsonKey(name: 'participant_id') final  String participantId;
@override@JsonKey(name: 'share_weight') final  double shareWeight;

/// Create a copy of AssignmentDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignmentDtoCopyWith<_AssignmentDto> get copyWith => __$AssignmentDtoCopyWithImpl<_AssignmentDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignmentDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssignmentDto&&(identical(other.id, id) || other.id == id)&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.shareWeight, shareWeight) || other.shareWeight == shareWeight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,itemId,participantId,shareWeight);

@override
String toString() {
  return 'AssignmentDto(id: $id, itemId: $itemId, participantId: $participantId, shareWeight: $shareWeight)';
}


}

/// @nodoc
abstract mixin class _$AssignmentDtoCopyWith<$Res> implements $AssignmentDtoCopyWith<$Res> {
  factory _$AssignmentDtoCopyWith(_AssignmentDto value, $Res Function(_AssignmentDto) _then) = __$AssignmentDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'item_id') String itemId,@JsonKey(name: 'participant_id') String participantId,@JsonKey(name: 'share_weight') double shareWeight
});




}
/// @nodoc
class __$AssignmentDtoCopyWithImpl<$Res>
    implements _$AssignmentDtoCopyWith<$Res> {
  __$AssignmentDtoCopyWithImpl(this._self, this._then);

  final _AssignmentDto _self;
  final $Res Function(_AssignmentDto) _then;

/// Create a copy of AssignmentDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? itemId = null,Object? participantId = null,Object? shareWeight = null,}) {
  return _then(_AssignmentDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as String,shareWeight: null == shareWeight ? _self.shareWeight : shareWeight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
