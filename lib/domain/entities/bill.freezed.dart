// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Bill {

 String get id; String get title; double get totalAmount; String get currencyCode; double get tax; double get service; bool get isSettled; DateTime? get receiptDate; DateTime get createdAt;/// Bill category preset (`makan`, `transport`, `groceries`, `belanja`,
/// `lain`). Server CHECK-enforced; unknown values never persist.
 String get category;/// Plus-only custom tags (max 5, normalized client-side). Excluded from
/// the public share-link snapshot.
 List<String> get tags;/// Summary of participant payment statuses from the History list query.
/// Populated only via [BillDto.fromJsonWithParticipants]; `getBill()`
/// and `upsertBill()` always return an empty list.
/// A non-empty list means **all** participants are accounted for here.
/// Empty does NOT imply zero participants — use `paymentStatus` getter
/// (which returns [BillPaymentStatus.unassigned] for empty) only when
/// this list is known to be complete (i.e. the History list route).
 List<bool> get participantPaymentStatuses;
/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillCopyWith<Bill> get copyWith => _$BillCopyWithImpl<Bill>(this as Bill, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bill&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.service, service) || other.service == service)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.participantPaymentStatuses, participantPaymentStatuses));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,totalAmount,currencyCode,tax,service,isSettled,receiptDate,createdAt,category,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(participantPaymentStatuses));

@override
String toString() {
  return 'Bill(id: $id, title: $title, totalAmount: $totalAmount, currencyCode: $currencyCode, tax: $tax, service: $service, isSettled: $isSettled, receiptDate: $receiptDate, createdAt: $createdAt, category: $category, tags: $tags, participantPaymentStatuses: $participantPaymentStatuses)';
}


}

/// @nodoc
abstract mixin class $BillCopyWith<$Res>  {
  factory $BillCopyWith(Bill value, $Res Function(Bill) _then) = _$BillCopyWithImpl;
@useResult
$Res call({
 String id, String title, double totalAmount, String currencyCode, double tax, double service, bool isSettled, DateTime? receiptDate, DateTime createdAt, String category, List<String> tags, List<bool> participantPaymentStatuses
});




}
/// @nodoc
class _$BillCopyWithImpl<$Res>
    implements $BillCopyWith<$Res> {
  _$BillCopyWithImpl(this._self, this._then);

  final Bill _self;
  final $Res Function(Bill) _then;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? totalAmount = null,Object? currencyCode = null,Object? tax = null,Object? service = null,Object? isSettled = null,Object? receiptDate = freezed,Object? createdAt = null,Object? category = null,Object? tags = null,Object? participantPaymentStatuses = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as double,isSettled: null == isSettled ? _self.isSettled : isSettled // ignore: cast_nullable_to_non_nullable
as bool,receiptDate: freezed == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,participantPaymentStatuses: null == participantPaymentStatuses ? _self.participantPaymentStatuses : participantPaymentStatuses // ignore: cast_nullable_to_non_nullable
as List<bool>,
  ));
}

}


/// Adds pattern-matching-related methods to [Bill].
extension BillPatterns on Bill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bill value)  $default,){
final _that = this;
switch (_that) {
case _Bill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bill value)?  $default,){
final _that = this;
switch (_that) {
case _Bill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  double totalAmount,  String currencyCode,  double tax,  double service,  bool isSettled,  DateTime? receiptDate,  DateTime createdAt,  String category,  List<String> tags,  List<bool> participantPaymentStatuses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that.id,_that.title,_that.totalAmount,_that.currencyCode,_that.tax,_that.service,_that.isSettled,_that.receiptDate,_that.createdAt,_that.category,_that.tags,_that.participantPaymentStatuses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  double totalAmount,  String currencyCode,  double tax,  double service,  bool isSettled,  DateTime? receiptDate,  DateTime createdAt,  String category,  List<String> tags,  List<bool> participantPaymentStatuses)  $default,) {final _that = this;
switch (_that) {
case _Bill():
return $default(_that.id,_that.title,_that.totalAmount,_that.currencyCode,_that.tax,_that.service,_that.isSettled,_that.receiptDate,_that.createdAt,_that.category,_that.tags,_that.participantPaymentStatuses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  double totalAmount,  String currencyCode,  double tax,  double service,  bool isSettled,  DateTime? receiptDate,  DateTime createdAt,  String category,  List<String> tags,  List<bool> participantPaymentStatuses)?  $default,) {final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that.id,_that.title,_that.totalAmount,_that.currencyCode,_that.tax,_that.service,_that.isSettled,_that.receiptDate,_that.createdAt,_that.category,_that.tags,_that.participantPaymentStatuses);case _:
  return null;

}
}

}

/// @nodoc


class _Bill extends Bill {
  const _Bill({required this.id, required this.title, required this.totalAmount, this.currencyCode = 'IDR', this.tax = 0, this.service = 0, this.isSettled = false, this.receiptDate, required this.createdAt, this.category = 'lain', final  List<String> tags = const [], final  List<bool> participantPaymentStatuses = const []}): _tags = tags,_participantPaymentStatuses = participantPaymentStatuses,super._();
  

@override final  String id;
@override final  String title;
@override final  double totalAmount;
@override@JsonKey() final  String currencyCode;
@override@JsonKey() final  double tax;
@override@JsonKey() final  double service;
@override@JsonKey() final  bool isSettled;
@override final  DateTime? receiptDate;
@override final  DateTime createdAt;
/// Bill category preset (`makan`, `transport`, `groceries`, `belanja`,
/// `lain`). Server CHECK-enforced; unknown values never persist.
@override@JsonKey() final  String category;
/// Plus-only custom tags (max 5, normalized client-side). Excluded from
/// the public share-link snapshot.
 final  List<String> _tags;
/// Plus-only custom tags (max 5, normalized client-side). Excluded from
/// the public share-link snapshot.
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

/// Summary of participant payment statuses from the History list query.
/// Populated only via [BillDto.fromJsonWithParticipants]; `getBill()`
/// and `upsertBill()` always return an empty list.
/// A non-empty list means **all** participants are accounted for here.
/// Empty does NOT imply zero participants — use `paymentStatus` getter
/// (which returns [BillPaymentStatus.unassigned] for empty) only when
/// this list is known to be complete (i.e. the History list route).
 final  List<bool> _participantPaymentStatuses;
/// Summary of participant payment statuses from the History list query.
/// Populated only via [BillDto.fromJsonWithParticipants]; `getBill()`
/// and `upsertBill()` always return an empty list.
/// A non-empty list means **all** participants are accounted for here.
/// Empty does NOT imply zero participants — use `paymentStatus` getter
/// (which returns [BillPaymentStatus.unassigned] for empty) only when
/// this list is known to be complete (i.e. the History list route).
@override@JsonKey() List<bool> get participantPaymentStatuses {
  if (_participantPaymentStatuses is EqualUnmodifiableListView) return _participantPaymentStatuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantPaymentStatuses);
}


/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillCopyWith<_Bill> get copyWith => __$BillCopyWithImpl<_Bill>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bill&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.service, service) || other.service == service)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._participantPaymentStatuses, _participantPaymentStatuses));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,totalAmount,currencyCode,tax,service,isSettled,receiptDate,createdAt,category,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_participantPaymentStatuses));

@override
String toString() {
  return 'Bill(id: $id, title: $title, totalAmount: $totalAmount, currencyCode: $currencyCode, tax: $tax, service: $service, isSettled: $isSettled, receiptDate: $receiptDate, createdAt: $createdAt, category: $category, tags: $tags, participantPaymentStatuses: $participantPaymentStatuses)';
}


}

/// @nodoc
abstract mixin class _$BillCopyWith<$Res> implements $BillCopyWith<$Res> {
  factory _$BillCopyWith(_Bill value, $Res Function(_Bill) _then) = __$BillCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, double totalAmount, String currencyCode, double tax, double service, bool isSettled, DateTime? receiptDate, DateTime createdAt, String category, List<String> tags, List<bool> participantPaymentStatuses
});




}
/// @nodoc
class __$BillCopyWithImpl<$Res>
    implements _$BillCopyWith<$Res> {
  __$BillCopyWithImpl(this._self, this._then);

  final _Bill _self;
  final $Res Function(_Bill) _then;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? totalAmount = null,Object? currencyCode = null,Object? tax = null,Object? service = null,Object? isSettled = null,Object? receiptDate = freezed,Object? createdAt = null,Object? category = null,Object? tags = null,Object? participantPaymentStatuses = null,}) {
  return _then(_Bill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as double,isSettled: null == isSettled ? _self.isSettled : isSettled // ignore: cast_nullable_to_non_nullable
as bool,receiptDate: freezed == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,participantPaymentStatuses: null == participantPaymentStatuses ? _self._participantPaymentStatuses : participantPaymentStatuses // ignore: cast_nullable_to_non_nullable
as List<bool>,
  ));
}


}

// dart format on
