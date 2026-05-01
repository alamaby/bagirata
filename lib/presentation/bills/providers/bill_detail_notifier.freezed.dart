// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_detail_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BillDetailState {

 Bill get bill; List<Item> get items; List<Participant> get participants; List<Assignment> get assignments;
/// Create a copy of BillDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillDetailStateCopyWith<BillDetailState> get copyWith => _$BillDetailStateCopyWithImpl<BillDetailState>(this as BillDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillDetailState&&(identical(other.bill, bill) || other.bill == bill)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.participants, participants)&&const DeepCollectionEquality().equals(other.assignments, assignments));
}


@override
int get hashCode => Object.hash(runtimeType,bill,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(participants),const DeepCollectionEquality().hash(assignments));

@override
String toString() {
  return 'BillDetailState(bill: $bill, items: $items, participants: $participants, assignments: $assignments)';
}


}

/// @nodoc
abstract mixin class $BillDetailStateCopyWith<$Res>  {
  factory $BillDetailStateCopyWith(BillDetailState value, $Res Function(BillDetailState) _then) = _$BillDetailStateCopyWithImpl;
@useResult
$Res call({
 Bill bill, List<Item> items, List<Participant> participants, List<Assignment> assignments
});


$BillCopyWith<$Res> get bill;

}
/// @nodoc
class _$BillDetailStateCopyWithImpl<$Res>
    implements $BillDetailStateCopyWith<$Res> {
  _$BillDetailStateCopyWithImpl(this._self, this._then);

  final BillDetailState _self;
  final $Res Function(BillDetailState) _then;

/// Create a copy of BillDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bill = null,Object? items = null,Object? participants = null,Object? assignments = null,}) {
  return _then(_self.copyWith(
bill: null == bill ? _self.bill : bill // ignore: cast_nullable_to_non_nullable
as Bill,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Item>,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<Participant>,assignments: null == assignments ? _self.assignments : assignments // ignore: cast_nullable_to_non_nullable
as List<Assignment>,
  ));
}
/// Create a copy of BillDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillCopyWith<$Res> get bill {
  
  return $BillCopyWith<$Res>(_self.bill, (value) {
    return _then(_self.copyWith(bill: value));
  });
}
}


/// Adds pattern-matching-related methods to [BillDetailState].
extension BillDetailStatePatterns on BillDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillDetailState value)  $default,){
final _that = this;
switch (_that) {
case _BillDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _BillDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Bill bill,  List<Item> items,  List<Participant> participants,  List<Assignment> assignments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillDetailState() when $default != null:
return $default(_that.bill,_that.items,_that.participants,_that.assignments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Bill bill,  List<Item> items,  List<Participant> participants,  List<Assignment> assignments)  $default,) {final _that = this;
switch (_that) {
case _BillDetailState():
return $default(_that.bill,_that.items,_that.participants,_that.assignments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Bill bill,  List<Item> items,  List<Participant> participants,  List<Assignment> assignments)?  $default,) {final _that = this;
switch (_that) {
case _BillDetailState() when $default != null:
return $default(_that.bill,_that.items,_that.participants,_that.assignments);case _:
  return null;

}
}

}

/// @nodoc


class _BillDetailState extends BillDetailState {
  const _BillDetailState({required this.bill, required final  List<Item> items, required final  List<Participant> participants, required final  List<Assignment> assignments}): _items = items,_participants = participants,_assignments = assignments,super._();
  

@override final  Bill bill;
 final  List<Item> _items;
@override List<Item> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<Participant> _participants;
@override List<Participant> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}

 final  List<Assignment> _assignments;
@override List<Assignment> get assignments {
  if (_assignments is EqualUnmodifiableListView) return _assignments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignments);
}


/// Create a copy of BillDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillDetailStateCopyWith<_BillDetailState> get copyWith => __$BillDetailStateCopyWithImpl<_BillDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillDetailState&&(identical(other.bill, bill) || other.bill == bill)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._participants, _participants)&&const DeepCollectionEquality().equals(other._assignments, _assignments));
}


@override
int get hashCode => Object.hash(runtimeType,bill,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_participants),const DeepCollectionEquality().hash(_assignments));

@override
String toString() {
  return 'BillDetailState(bill: $bill, items: $items, participants: $participants, assignments: $assignments)';
}


}

/// @nodoc
abstract mixin class _$BillDetailStateCopyWith<$Res> implements $BillDetailStateCopyWith<$Res> {
  factory _$BillDetailStateCopyWith(_BillDetailState value, $Res Function(_BillDetailState) _then) = __$BillDetailStateCopyWithImpl;
@override @useResult
$Res call({
 Bill bill, List<Item> items, List<Participant> participants, List<Assignment> assignments
});


@override $BillCopyWith<$Res> get bill;

}
/// @nodoc
class __$BillDetailStateCopyWithImpl<$Res>
    implements _$BillDetailStateCopyWith<$Res> {
  __$BillDetailStateCopyWithImpl(this._self, this._then);

  final _BillDetailState _self;
  final $Res Function(_BillDetailState) _then;

/// Create a copy of BillDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bill = null,Object? items = null,Object? participants = null,Object? assignments = null,}) {
  return _then(_BillDetailState(
bill: null == bill ? _self.bill : bill // ignore: cast_nullable_to_non_nullable
as Bill,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Item>,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<Participant>,assignments: null == assignments ? _self._assignments : assignments // ignore: cast_nullable_to_non_nullable
as List<Assignment>,
  ));
}

/// Create a copy of BillDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillCopyWith<$Res> get bill {
  
  return $BillCopyWith<$Res>(_self.bill, (value) {
    return _then(_self.copyWith(bill: value));
  });
}
}

// dart format on
