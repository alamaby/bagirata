// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_filter_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HistoryFilterState {

 HistorySort get sort; BillPaymentStatus? get paymentStatus; String? get currencyCode; String? get category; String? get query;
/// Create a copy of HistoryFilterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryFilterStateCopyWith<HistoryFilterState> get copyWith => _$HistoryFilterStateCopyWithImpl<HistoryFilterState>(this as HistoryFilterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryFilterState&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.category, category) || other.category == category)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,sort,paymentStatus,currencyCode,category,query);

@override
String toString() {
  return 'HistoryFilterState(sort: $sort, paymentStatus: $paymentStatus, currencyCode: $currencyCode, category: $category, query: $query)';
}


}

/// @nodoc
abstract mixin class $HistoryFilterStateCopyWith<$Res>  {
  factory $HistoryFilterStateCopyWith(HistoryFilterState value, $Res Function(HistoryFilterState) _then) = _$HistoryFilterStateCopyWithImpl;
@useResult
$Res call({
 HistorySort sort, BillPaymentStatus? paymentStatus, String? currencyCode, String? category, String? query
});




}
/// @nodoc
class _$HistoryFilterStateCopyWithImpl<$Res>
    implements $HistoryFilterStateCopyWith<$Res> {
  _$HistoryFilterStateCopyWithImpl(this._self, this._then);

  final HistoryFilterState _self;
  final $Res Function(HistoryFilterState) _then;

/// Create a copy of HistoryFilterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sort = null,Object? paymentStatus = freezed,Object? currencyCode = freezed,Object? category = freezed,Object? query = freezed,}) {
  return _then(_self.copyWith(
sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as HistorySort,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as BillPaymentStatus?,currencyCode: freezed == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoryFilterState].
extension HistoryFilterStatePatterns on HistoryFilterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryFilterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryFilterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryFilterState value)  $default,){
final _that = this;
switch (_that) {
case _HistoryFilterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryFilterState value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryFilterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HistorySort sort,  BillPaymentStatus? paymentStatus,  String? currencyCode,  String? category,  String? query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryFilterState() when $default != null:
return $default(_that.sort,_that.paymentStatus,_that.currencyCode,_that.category,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HistorySort sort,  BillPaymentStatus? paymentStatus,  String? currencyCode,  String? category,  String? query)  $default,) {final _that = this;
switch (_that) {
case _HistoryFilterState():
return $default(_that.sort,_that.paymentStatus,_that.currencyCode,_that.category,_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HistorySort sort,  BillPaymentStatus? paymentStatus,  String? currencyCode,  String? category,  String? query)?  $default,) {final _that = this;
switch (_that) {
case _HistoryFilterState() when $default != null:
return $default(_that.sort,_that.paymentStatus,_that.currencyCode,_that.category,_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _HistoryFilterState extends HistoryFilterState {
  const _HistoryFilterState({this.sort = HistorySort.newest, this.paymentStatus, this.currencyCode, this.category, this.query}): super._();
  

@override@JsonKey() final  HistorySort sort;
@override final  BillPaymentStatus? paymentStatus;
@override final  String? currencyCode;
@override final  String? category;
@override final  String? query;

/// Create a copy of HistoryFilterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryFilterStateCopyWith<_HistoryFilterState> get copyWith => __$HistoryFilterStateCopyWithImpl<_HistoryFilterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryFilterState&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.category, category) || other.category == category)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,sort,paymentStatus,currencyCode,category,query);

@override
String toString() {
  return 'HistoryFilterState(sort: $sort, paymentStatus: $paymentStatus, currencyCode: $currencyCode, category: $category, query: $query)';
}


}

/// @nodoc
abstract mixin class _$HistoryFilterStateCopyWith<$Res> implements $HistoryFilterStateCopyWith<$Res> {
  factory _$HistoryFilterStateCopyWith(_HistoryFilterState value, $Res Function(_HistoryFilterState) _then) = __$HistoryFilterStateCopyWithImpl;
@override @useResult
$Res call({
 HistorySort sort, BillPaymentStatus? paymentStatus, String? currencyCode, String? category, String? query
});




}
/// @nodoc
class __$HistoryFilterStateCopyWithImpl<$Res>
    implements _$HistoryFilterStateCopyWith<$Res> {
  __$HistoryFilterStateCopyWithImpl(this._self, this._then);

  final _HistoryFilterState _self;
  final $Res Function(_HistoryFilterState) _then;

/// Create a copy of HistoryFilterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sort = null,Object? paymentStatus = freezed,Object? currencyCode = freezed,Object? category = freezed,Object? query = freezed,}) {
  return _then(_HistoryFilterState(
sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as HistorySort,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as BillPaymentStatus?,currencyCode: freezed == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
