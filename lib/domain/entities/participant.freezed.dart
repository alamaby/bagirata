// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'participant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Participant {

 String get id; String get billId; String get name; bool get isPaid; DateTime? get paidAt;
/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParticipantCopyWith<Participant> get copyWith => _$ParticipantCopyWithImpl<Participant>(this as Participant, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Participant&&(identical(other.id, id) || other.id == id)&&(identical(other.billId, billId) || other.billId == billId)&&(identical(other.name, name) || other.name == name)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,billId,name,isPaid,paidAt);

@override
String toString() {
  return 'Participant(id: $id, billId: $billId, name: $name, isPaid: $isPaid, paidAt: $paidAt)';
}


}

/// @nodoc
abstract mixin class $ParticipantCopyWith<$Res>  {
  factory $ParticipantCopyWith(Participant value, $Res Function(Participant) _then) = _$ParticipantCopyWithImpl;
@useResult
$Res call({
 String id, String billId, String name, bool isPaid, DateTime? paidAt
});




}
/// @nodoc
class _$ParticipantCopyWithImpl<$Res>
    implements $ParticipantCopyWith<$Res> {
  _$ParticipantCopyWithImpl(this._self, this._then);

  final Participant _self;
  final $Res Function(Participant) _then;

/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? billId = null,Object? name = null,Object? isPaid = null,Object? paidAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,billId: null == billId ? _self.billId : billId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Participant].
extension ParticipantPatterns on Participant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Participant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Participant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Participant value)  $default,){
final _that = this;
switch (_that) {
case _Participant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Participant value)?  $default,){
final _that = this;
switch (_that) {
case _Participant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String billId,  String name,  bool isPaid,  DateTime? paidAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that.id,_that.billId,_that.name,_that.isPaid,_that.paidAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String billId,  String name,  bool isPaid,  DateTime? paidAt)  $default,) {final _that = this;
switch (_that) {
case _Participant():
return $default(_that.id,_that.billId,_that.name,_that.isPaid,_that.paidAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String billId,  String name,  bool isPaid,  DateTime? paidAt)?  $default,) {final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that.id,_that.billId,_that.name,_that.isPaid,_that.paidAt);case _:
  return null;

}
}

}

/// @nodoc


class _Participant implements Participant {
  const _Participant({required this.id, required this.billId, required this.name, this.isPaid = false, this.paidAt});
  

@override final  String id;
@override final  String billId;
@override final  String name;
@override@JsonKey() final  bool isPaid;
@override final  DateTime? paidAt;

/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParticipantCopyWith<_Participant> get copyWith => __$ParticipantCopyWithImpl<_Participant>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Participant&&(identical(other.id, id) || other.id == id)&&(identical(other.billId, billId) || other.billId == billId)&&(identical(other.name, name) || other.name == name)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,billId,name,isPaid,paidAt);

@override
String toString() {
  return 'Participant(id: $id, billId: $billId, name: $name, isPaid: $isPaid, paidAt: $paidAt)';
}


}

/// @nodoc
abstract mixin class _$ParticipantCopyWith<$Res> implements $ParticipantCopyWith<$Res> {
  factory _$ParticipantCopyWith(_Participant value, $Res Function(_Participant) _then) = __$ParticipantCopyWithImpl;
@override @useResult
$Res call({
 String id, String billId, String name, bool isPaid, DateTime? paidAt
});




}
/// @nodoc
class __$ParticipantCopyWithImpl<$Res>
    implements _$ParticipantCopyWith<$Res> {
  __$ParticipantCopyWithImpl(this._self, this._then);

  final _Participant _self;
  final $Res Function(_Participant) _then;

/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? billId = null,Object? name = null,Object? isPaid = null,Object? paidAt = freezed,}) {
  return _then(_Participant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,billId: null == billId ? _self.billId : billId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
