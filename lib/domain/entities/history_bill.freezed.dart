// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HistoryBill {

 String get id; String get title; double get totalAmount; String get currencyCode; double get tax; double get service; bool get isSettled; DateTime? get receiptDate; DateTime get createdAt; String get category; List<String> get tags; int get participantCount; int get paidParticipantCount; BillPaymentStatus get paymentStatus;
/// Create a copy of HistoryBill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryBillCopyWith<HistoryBill> get copyWith => _$HistoryBillCopyWithImpl<HistoryBill>(this as HistoryBill, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryBill&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.service, service) || other.service == service)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.paidParticipantCount, paidParticipantCount) || other.paidParticipantCount == paidParticipantCount)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,totalAmount,currencyCode,tax,service,isSettled,receiptDate,createdAt,category,const DeepCollectionEquality().hash(tags),participantCount,paidParticipantCount,paymentStatus);

@override
String toString() {
  return 'HistoryBill(id: $id, title: $title, totalAmount: $totalAmount, currencyCode: $currencyCode, tax: $tax, service: $service, isSettled: $isSettled, receiptDate: $receiptDate, createdAt: $createdAt, category: $category, tags: $tags, participantCount: $participantCount, paidParticipantCount: $paidParticipantCount, paymentStatus: $paymentStatus)';
}


}

/// @nodoc
abstract mixin class $HistoryBillCopyWith<$Res>  {
  factory $HistoryBillCopyWith(HistoryBill value, $Res Function(HistoryBill) _then) = _$HistoryBillCopyWithImpl;
@useResult
$Res call({
 String id, String title, double totalAmount, String currencyCode, double tax, double service, bool isSettled, DateTime? receiptDate, DateTime createdAt, String category, List<String> tags, int participantCount, int paidParticipantCount, BillPaymentStatus paymentStatus
});




}
/// @nodoc
class _$HistoryBillCopyWithImpl<$Res>
    implements $HistoryBillCopyWith<$Res> {
  _$HistoryBillCopyWithImpl(this._self, this._then);

  final HistoryBill _self;
  final $Res Function(HistoryBill) _then;

/// Create a copy of HistoryBill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? totalAmount = null,Object? currencyCode = null,Object? tax = null,Object? service = null,Object? isSettled = null,Object? receiptDate = freezed,Object? createdAt = null,Object? category = null,Object? tags = null,Object? participantCount = null,Object? paidParticipantCount = null,Object? paymentStatus = null,}) {
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
as List<String>,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,paidParticipantCount: null == paidParticipantCount ? _self.paidParticipantCount : paidParticipantCount // ignore: cast_nullable_to_non_nullable
as int,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as BillPaymentStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoryBill].
extension HistoryBillPatterns on HistoryBill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryBill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryBill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryBill value)  $default,){
final _that = this;
switch (_that) {
case _HistoryBill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryBill value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryBill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  double totalAmount,  String currencyCode,  double tax,  double service,  bool isSettled,  DateTime? receiptDate,  DateTime createdAt,  String category,  List<String> tags,  int participantCount,  int paidParticipantCount,  BillPaymentStatus paymentStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryBill() when $default != null:
return $default(_that.id,_that.title,_that.totalAmount,_that.currencyCode,_that.tax,_that.service,_that.isSettled,_that.receiptDate,_that.createdAt,_that.category,_that.tags,_that.participantCount,_that.paidParticipantCount,_that.paymentStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  double totalAmount,  String currencyCode,  double tax,  double service,  bool isSettled,  DateTime? receiptDate,  DateTime createdAt,  String category,  List<String> tags,  int participantCount,  int paidParticipantCount,  BillPaymentStatus paymentStatus)  $default,) {final _that = this;
switch (_that) {
case _HistoryBill():
return $default(_that.id,_that.title,_that.totalAmount,_that.currencyCode,_that.tax,_that.service,_that.isSettled,_that.receiptDate,_that.createdAt,_that.category,_that.tags,_that.participantCount,_that.paidParticipantCount,_that.paymentStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  double totalAmount,  String currencyCode,  double tax,  double service,  bool isSettled,  DateTime? receiptDate,  DateTime createdAt,  String category,  List<String> tags,  int participantCount,  int paidParticipantCount,  BillPaymentStatus paymentStatus)?  $default,) {final _that = this;
switch (_that) {
case _HistoryBill() when $default != null:
return $default(_that.id,_that.title,_that.totalAmount,_that.currencyCode,_that.tax,_that.service,_that.isSettled,_that.receiptDate,_that.createdAt,_that.category,_that.tags,_that.participantCount,_that.paidParticipantCount,_that.paymentStatus);case _:
  return null;

}
}

}

/// @nodoc


class _HistoryBill implements HistoryBill {
  const _HistoryBill({required this.id, required this.title, required this.totalAmount, this.currencyCode = 'IDR', this.tax = 0, this.service = 0, this.isSettled = false, this.receiptDate, required this.createdAt, this.category = 'lain', final  List<String> tags = const [], required this.participantCount, required this.paidParticipantCount, required this.paymentStatus}): _tags = tags;
  

@override final  String id;
@override final  String title;
@override final  double totalAmount;
@override@JsonKey() final  String currencyCode;
@override@JsonKey() final  double tax;
@override@JsonKey() final  double service;
@override@JsonKey() final  bool isSettled;
@override final  DateTime? receiptDate;
@override final  DateTime createdAt;
@override@JsonKey() final  String category;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  int participantCount;
@override final  int paidParticipantCount;
@override final  BillPaymentStatus paymentStatus;

/// Create a copy of HistoryBill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryBillCopyWith<_HistoryBill> get copyWith => __$HistoryBillCopyWithImpl<_HistoryBill>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryBill&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.service, service) || other.service == service)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.paidParticipantCount, paidParticipantCount) || other.paidParticipantCount == paidParticipantCount)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,totalAmount,currencyCode,tax,service,isSettled,receiptDate,createdAt,category,const DeepCollectionEquality().hash(_tags),participantCount,paidParticipantCount,paymentStatus);

@override
String toString() {
  return 'HistoryBill(id: $id, title: $title, totalAmount: $totalAmount, currencyCode: $currencyCode, tax: $tax, service: $service, isSettled: $isSettled, receiptDate: $receiptDate, createdAt: $createdAt, category: $category, tags: $tags, participantCount: $participantCount, paidParticipantCount: $paidParticipantCount, paymentStatus: $paymentStatus)';
}


}

/// @nodoc
abstract mixin class _$HistoryBillCopyWith<$Res> implements $HistoryBillCopyWith<$Res> {
  factory _$HistoryBillCopyWith(_HistoryBill value, $Res Function(_HistoryBill) _then) = __$HistoryBillCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, double totalAmount, String currencyCode, double tax, double service, bool isSettled, DateTime? receiptDate, DateTime createdAt, String category, List<String> tags, int participantCount, int paidParticipantCount, BillPaymentStatus paymentStatus
});




}
/// @nodoc
class __$HistoryBillCopyWithImpl<$Res>
    implements _$HistoryBillCopyWith<$Res> {
  __$HistoryBillCopyWithImpl(this._self, this._then);

  final _HistoryBill _self;
  final $Res Function(_HistoryBill) _then;

/// Create a copy of HistoryBill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? totalAmount = null,Object? currencyCode = null,Object? tax = null,Object? service = null,Object? isSettled = null,Object? receiptDate = freezed,Object? createdAt = null,Object? category = null,Object? tags = null,Object? participantCount = null,Object? paidParticipantCount = null,Object? paymentStatus = null,}) {
  return _then(_HistoryBill(
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
as List<String>,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,paidParticipantCount: null == paidParticipantCount ? _self.paidParticipantCount : paidParticipantCount // ignore: cast_nullable_to_non_nullable
as int,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as BillPaymentStatus,
  ));
}


}

// dart format on
