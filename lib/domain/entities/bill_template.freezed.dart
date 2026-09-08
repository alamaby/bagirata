// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BillTemplate {

 String get id; String get name;@JsonKey(name: 'use_count') int get useCount;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of BillTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillTemplateCopyWith<BillTemplate> get copyWith => _$BillTemplateCopyWithImpl<BillTemplate>(this as BillTemplate, _$identity);

  /// Serializes this BillTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.useCount, useCount) || other.useCount == useCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,useCount,createdAt);

@override
String toString() {
  return 'BillTemplate(id: $id, name: $name, useCount: $useCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BillTemplateCopyWith<$Res>  {
  factory $BillTemplateCopyWith(BillTemplate value, $Res Function(BillTemplate) _then) = _$BillTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'use_count') int useCount,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$BillTemplateCopyWithImpl<$Res>
    implements $BillTemplateCopyWith<$Res> {
  _$BillTemplateCopyWithImpl(this._self, this._then);

  final BillTemplate _self;
  final $Res Function(BillTemplate) _then;

/// Create a copy of BillTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? useCount = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,useCount: null == useCount ? _self.useCount : useCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BillTemplate].
extension BillTemplatePatterns on BillTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillTemplate value)  $default,){
final _that = this;
switch (_that) {
case _BillTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _BillTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'use_count')  int useCount, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillTemplate() when $default != null:
return $default(_that.id,_that.name,_that.useCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'use_count')  int useCount, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BillTemplate():
return $default(_that.id,_that.name,_that.useCount,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'use_count')  int useCount, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BillTemplate() when $default != null:
return $default(_that.id,_that.name,_that.useCount,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillTemplate implements BillTemplate {
  const _BillTemplate({required this.id, required this.name, @JsonKey(name: 'use_count') this.useCount = 0, @JsonKey(name: 'created_at') required this.createdAt});
  factory _BillTemplate.fromJson(Map<String, dynamic> json) => _$BillTemplateFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'use_count') final  int useCount;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of BillTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillTemplateCopyWith<_BillTemplate> get copyWith => __$BillTemplateCopyWithImpl<_BillTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.useCount, useCount) || other.useCount == useCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,useCount,createdAt);

@override
String toString() {
  return 'BillTemplate(id: $id, name: $name, useCount: $useCount, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BillTemplateCopyWith<$Res> implements $BillTemplateCopyWith<$Res> {
  factory _$BillTemplateCopyWith(_BillTemplate value, $Res Function(_BillTemplate) _then) = __$BillTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'use_count') int useCount,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$BillTemplateCopyWithImpl<$Res>
    implements _$BillTemplateCopyWith<$Res> {
  __$BillTemplateCopyWithImpl(this._self, this._then);

  final _BillTemplate _self;
  final $Res Function(_BillTemplate) _then;

/// Create a copy of BillTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? useCount = null,Object? createdAt = null,}) {
  return _then(_BillTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,useCount: null == useCount ? _self.useCount : useCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
