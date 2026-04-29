// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthSnapshot {

 String? get userId; bool get isAnonymous;
/// Create a copy of AuthSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSnapshotCopyWith<AuthSnapshot> get copyWith => _$AuthSnapshotCopyWithImpl<AuthSnapshot>(this as AuthSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSnapshot&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous));
}


@override
int get hashCode => Object.hash(runtimeType,userId,isAnonymous);

@override
String toString() {
  return 'AuthSnapshot(userId: $userId, isAnonymous: $isAnonymous)';
}


}

/// @nodoc
abstract mixin class $AuthSnapshotCopyWith<$Res>  {
  factory $AuthSnapshotCopyWith(AuthSnapshot value, $Res Function(AuthSnapshot) _then) = _$AuthSnapshotCopyWithImpl;
@useResult
$Res call({
 String? userId, bool isAnonymous
});




}
/// @nodoc
class _$AuthSnapshotCopyWithImpl<$Res>
    implements $AuthSnapshotCopyWith<$Res> {
  _$AuthSnapshotCopyWithImpl(this._self, this._then);

  final AuthSnapshot _self;
  final $Res Function(AuthSnapshot) _then;

/// Create a copy of AuthSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = freezed,Object? isAnonymous = null,}) {
  return _then(_self.copyWith(
userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthSnapshot].
extension AuthSnapshotPatterns on AuthSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _AuthSnapshot():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _AuthSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? userId,  bool isAnonymous)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthSnapshot() when $default != null:
return $default(_that.userId,_that.isAnonymous);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? userId,  bool isAnonymous)  $default,) {final _that = this;
switch (_that) {
case _AuthSnapshot():
return $default(_that.userId,_that.isAnonymous);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? userId,  bool isAnonymous)?  $default,) {final _that = this;
switch (_that) {
case _AuthSnapshot() when $default != null:
return $default(_that.userId,_that.isAnonymous);case _:
  return null;

}
}

}

/// @nodoc


class _AuthSnapshot extends AuthSnapshot {
  const _AuthSnapshot({required this.userId, required this.isAnonymous}): super._();
  

@override final  String? userId;
@override final  bool isAnonymous;

/// Create a copy of AuthSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthSnapshotCopyWith<_AuthSnapshot> get copyWith => __$AuthSnapshotCopyWithImpl<_AuthSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthSnapshot&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous));
}


@override
int get hashCode => Object.hash(runtimeType,userId,isAnonymous);

@override
String toString() {
  return 'AuthSnapshot(userId: $userId, isAnonymous: $isAnonymous)';
}


}

/// @nodoc
abstract mixin class _$AuthSnapshotCopyWith<$Res> implements $AuthSnapshotCopyWith<$Res> {
  factory _$AuthSnapshotCopyWith(_AuthSnapshot value, $Res Function(_AuthSnapshot) _then) = __$AuthSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String? userId, bool isAnonymous
});




}
/// @nodoc
class __$AuthSnapshotCopyWithImpl<$Res>
    implements _$AuthSnapshotCopyWith<$Res> {
  __$AuthSnapshotCopyWithImpl(this._self, this._then);

  final _AuthSnapshot _self;
  final $Res Function(_AuthSnapshot) _then;

/// Create a copy of AuthSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = freezed,Object? isAnonymous = null,}) {
  return _then(_AuthSnapshot(
userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
