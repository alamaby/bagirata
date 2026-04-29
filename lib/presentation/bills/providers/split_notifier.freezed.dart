// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'split_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParticipantTotal {

 String get participantId; double get subtotal; double get tax; double get service; double get total;
/// Create a copy of ParticipantTotal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParticipantTotalCopyWith<ParticipantTotal> get copyWith => _$ParticipantTotalCopyWithImpl<ParticipantTotal>(this as ParticipantTotal, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParticipantTotal&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.service, service) || other.service == service)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,participantId,subtotal,tax,service,total);

@override
String toString() {
  return 'ParticipantTotal(participantId: $participantId, subtotal: $subtotal, tax: $tax, service: $service, total: $total)';
}


}

/// @nodoc
abstract mixin class $ParticipantTotalCopyWith<$Res>  {
  factory $ParticipantTotalCopyWith(ParticipantTotal value, $Res Function(ParticipantTotal) _then) = _$ParticipantTotalCopyWithImpl;
@useResult
$Res call({
 String participantId, double subtotal, double tax, double service, double total
});




}
/// @nodoc
class _$ParticipantTotalCopyWithImpl<$Res>
    implements $ParticipantTotalCopyWith<$Res> {
  _$ParticipantTotalCopyWithImpl(this._self, this._then);

  final ParticipantTotal _self;
  final $Res Function(ParticipantTotal) _then;

/// Create a copy of ParticipantTotal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? participantId = null,Object? subtotal = null,Object? tax = null,Object? service = null,Object? total = null,}) {
  return _then(_self.copyWith(
participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as String,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ParticipantTotal].
extension ParticipantTotalPatterns on ParticipantTotal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParticipantTotal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParticipantTotal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParticipantTotal value)  $default,){
final _that = this;
switch (_that) {
case _ParticipantTotal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParticipantTotal value)?  $default,){
final _that = this;
switch (_that) {
case _ParticipantTotal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String participantId,  double subtotal,  double tax,  double service,  double total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParticipantTotal() when $default != null:
return $default(_that.participantId,_that.subtotal,_that.tax,_that.service,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String participantId,  double subtotal,  double tax,  double service,  double total)  $default,) {final _that = this;
switch (_that) {
case _ParticipantTotal():
return $default(_that.participantId,_that.subtotal,_that.tax,_that.service,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String participantId,  double subtotal,  double tax,  double service,  double total)?  $default,) {final _that = this;
switch (_that) {
case _ParticipantTotal() when $default != null:
return $default(_that.participantId,_that.subtotal,_that.tax,_that.service,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _ParticipantTotal implements ParticipantTotal {
  const _ParticipantTotal({required this.participantId, required this.subtotal, required this.tax, required this.service, required this.total});
  

@override final  String participantId;
@override final  double subtotal;
@override final  double tax;
@override final  double service;
@override final  double total;

/// Create a copy of ParticipantTotal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParticipantTotalCopyWith<_ParticipantTotal> get copyWith => __$ParticipantTotalCopyWithImpl<_ParticipantTotal>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParticipantTotal&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.service, service) || other.service == service)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,participantId,subtotal,tax,service,total);

@override
String toString() {
  return 'ParticipantTotal(participantId: $participantId, subtotal: $subtotal, tax: $tax, service: $service, total: $total)';
}


}

/// @nodoc
abstract mixin class _$ParticipantTotalCopyWith<$Res> implements $ParticipantTotalCopyWith<$Res> {
  factory _$ParticipantTotalCopyWith(_ParticipantTotal value, $Res Function(_ParticipantTotal) _then) = __$ParticipantTotalCopyWithImpl;
@override @useResult
$Res call({
 String participantId, double subtotal, double tax, double service, double total
});




}
/// @nodoc
class __$ParticipantTotalCopyWithImpl<$Res>
    implements _$ParticipantTotalCopyWith<$Res> {
  __$ParticipantTotalCopyWithImpl(this._self, this._then);

  final _ParticipantTotal _self;
  final $Res Function(_ParticipantTotal) _then;

/// Create a copy of ParticipantTotal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? participantId = null,Object? subtotal = null,Object? tax = null,Object? service = null,Object? total = null,}) {
  return _then(_ParticipantTotal(
participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as String,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$SplitState {

 Bill get bill; List<Item> get items; List<Participant> get participants; List<Assignment> get assignments; String? get selectedParticipantId;
/// Create a copy of SplitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SplitStateCopyWith<SplitState> get copyWith => _$SplitStateCopyWithImpl<SplitState>(this as SplitState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SplitState&&(identical(other.bill, bill) || other.bill == bill)&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.participants, participants)&&const DeepCollectionEquality().equals(other.assignments, assignments)&&(identical(other.selectedParticipantId, selectedParticipantId) || other.selectedParticipantId == selectedParticipantId));
}


@override
int get hashCode => Object.hash(runtimeType,bill,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(participants),const DeepCollectionEquality().hash(assignments),selectedParticipantId);

@override
String toString() {
  return 'SplitState(bill: $bill, items: $items, participants: $participants, assignments: $assignments, selectedParticipantId: $selectedParticipantId)';
}


}

/// @nodoc
abstract mixin class $SplitStateCopyWith<$Res>  {
  factory $SplitStateCopyWith(SplitState value, $Res Function(SplitState) _then) = _$SplitStateCopyWithImpl;
@useResult
$Res call({
 Bill bill, List<Item> items, List<Participant> participants, List<Assignment> assignments, String? selectedParticipantId
});


$BillCopyWith<$Res> get bill;

}
/// @nodoc
class _$SplitStateCopyWithImpl<$Res>
    implements $SplitStateCopyWith<$Res> {
  _$SplitStateCopyWithImpl(this._self, this._then);

  final SplitState _self;
  final $Res Function(SplitState) _then;

/// Create a copy of SplitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bill = null,Object? items = null,Object? participants = null,Object? assignments = null,Object? selectedParticipantId = freezed,}) {
  return _then(_self.copyWith(
bill: null == bill ? _self.bill : bill // ignore: cast_nullable_to_non_nullable
as Bill,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Item>,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<Participant>,assignments: null == assignments ? _self.assignments : assignments // ignore: cast_nullable_to_non_nullable
as List<Assignment>,selectedParticipantId: freezed == selectedParticipantId ? _self.selectedParticipantId : selectedParticipantId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of SplitState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BillCopyWith<$Res> get bill {
  
  return $BillCopyWith<$Res>(_self.bill, (value) {
    return _then(_self.copyWith(bill: value));
  });
}
}


/// Adds pattern-matching-related methods to [SplitState].
extension SplitStatePatterns on SplitState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SplitState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SplitState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SplitState value)  $default,){
final _that = this;
switch (_that) {
case _SplitState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SplitState value)?  $default,){
final _that = this;
switch (_that) {
case _SplitState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Bill bill,  List<Item> items,  List<Participant> participants,  List<Assignment> assignments,  String? selectedParticipantId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SplitState() when $default != null:
return $default(_that.bill,_that.items,_that.participants,_that.assignments,_that.selectedParticipantId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Bill bill,  List<Item> items,  List<Participant> participants,  List<Assignment> assignments,  String? selectedParticipantId)  $default,) {final _that = this;
switch (_that) {
case _SplitState():
return $default(_that.bill,_that.items,_that.participants,_that.assignments,_that.selectedParticipantId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Bill bill,  List<Item> items,  List<Participant> participants,  List<Assignment> assignments,  String? selectedParticipantId)?  $default,) {final _that = this;
switch (_that) {
case _SplitState() when $default != null:
return $default(_that.bill,_that.items,_that.participants,_that.assignments,_that.selectedParticipantId);case _:
  return null;

}
}

}

/// @nodoc


class _SplitState extends SplitState {
  const _SplitState({required this.bill, required final  List<Item> items, required final  List<Participant> participants, required final  List<Assignment> assignments, this.selectedParticipantId}): _items = items,_participants = participants,_assignments = assignments,super._();
  

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

@override final  String? selectedParticipantId;

/// Create a copy of SplitState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SplitStateCopyWith<_SplitState> get copyWith => __$SplitStateCopyWithImpl<_SplitState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SplitState&&(identical(other.bill, bill) || other.bill == bill)&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._participants, _participants)&&const DeepCollectionEquality().equals(other._assignments, _assignments)&&(identical(other.selectedParticipantId, selectedParticipantId) || other.selectedParticipantId == selectedParticipantId));
}


@override
int get hashCode => Object.hash(runtimeType,bill,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_participants),const DeepCollectionEquality().hash(_assignments),selectedParticipantId);

@override
String toString() {
  return 'SplitState(bill: $bill, items: $items, participants: $participants, assignments: $assignments, selectedParticipantId: $selectedParticipantId)';
}


}

/// @nodoc
abstract mixin class _$SplitStateCopyWith<$Res> implements $SplitStateCopyWith<$Res> {
  factory _$SplitStateCopyWith(_SplitState value, $Res Function(_SplitState) _then) = __$SplitStateCopyWithImpl;
@override @useResult
$Res call({
 Bill bill, List<Item> items, List<Participant> participants, List<Assignment> assignments, String? selectedParticipantId
});


@override $BillCopyWith<$Res> get bill;

}
/// @nodoc
class __$SplitStateCopyWithImpl<$Res>
    implements _$SplitStateCopyWith<$Res> {
  __$SplitStateCopyWithImpl(this._self, this._then);

  final _SplitState _self;
  final $Res Function(_SplitState) _then;

/// Create a copy of SplitState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bill = null,Object? items = null,Object? participants = null,Object? assignments = null,Object? selectedParticipantId = freezed,}) {
  return _then(_SplitState(
bill: null == bill ? _self.bill : bill // ignore: cast_nullable_to_non_nullable
as Bill,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Item>,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<Participant>,assignments: null == assignments ? _self._assignments : assignments // ignore: cast_nullable_to_non_nullable
as List<Assignment>,selectedParticipantId: freezed == selectedParticipantId ? _self.selectedParticipantId : selectedParticipantId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of SplitState
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
