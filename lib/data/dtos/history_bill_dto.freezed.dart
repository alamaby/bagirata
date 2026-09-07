// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_bill_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HistoryBillDto {

 String get id; String get title;@JsonKey(name: 'total_amount') double get totalAmount;@JsonKey(name: 'currency_code') String get currencyCode;@JsonKey(name: 'tax_amount') double get tax;@JsonKey(name: 'service_charge') double get service;@JsonKey(name: 'is_settled') bool get isSettled;@JsonKey(name: 'receipt_date') DateTime? get receiptDate;@JsonKey(name: 'created_at') DateTime get createdAt; String get category;@JsonKey(name: 'bill_tags') List<String> get tags;@JsonKey(name: 'participant_count') int get participantCount;@JsonKey(name: 'paid_participant_count') int get paidParticipantCount;@JsonKey(name: 'payment_status') String get paymentStatus;
/// Create a copy of HistoryBillDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryBillDtoCopyWith<HistoryBillDto> get copyWith => _$HistoryBillDtoCopyWithImpl<HistoryBillDto>(this as HistoryBillDto, _$identity);

  /// Serializes this HistoryBillDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryBillDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.service, service) || other.service == service)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.paidParticipantCount, paidParticipantCount) || other.paidParticipantCount == paidParticipantCount)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,totalAmount,currencyCode,tax,service,isSettled,receiptDate,createdAt,category,const DeepCollectionEquality().hash(tags),participantCount,paidParticipantCount,paymentStatus);

@override
String toString() {
  return 'HistoryBillDto(id: $id, title: $title, totalAmount: $totalAmount, currencyCode: $currencyCode, tax: $tax, service: $service, isSettled: $isSettled, receiptDate: $receiptDate, createdAt: $createdAt, category: $category, tags: $tags, participantCount: $participantCount, paidParticipantCount: $paidParticipantCount, paymentStatus: $paymentStatus)';
}


}

/// @nodoc
abstract mixin class $HistoryBillDtoCopyWith<$Res>  {
  factory $HistoryBillDtoCopyWith(HistoryBillDto value, $Res Function(HistoryBillDto) _then) = _$HistoryBillDtoCopyWithImpl;
@useResult
$Res call({
 String id, String title,@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'currency_code') String currencyCode,@JsonKey(name: 'tax_amount') double tax,@JsonKey(name: 'service_charge') double service,@JsonKey(name: 'is_settled') bool isSettled,@JsonKey(name: 'receipt_date') DateTime? receiptDate,@JsonKey(name: 'created_at') DateTime createdAt, String category,@JsonKey(name: 'bill_tags') List<String> tags,@JsonKey(name: 'participant_count') int participantCount,@JsonKey(name: 'paid_participant_count') int paidParticipantCount,@JsonKey(name: 'payment_status') String paymentStatus
});




}
/// @nodoc
class _$HistoryBillDtoCopyWithImpl<$Res>
    implements $HistoryBillDtoCopyWith<$Res> {
  _$HistoryBillDtoCopyWithImpl(this._self, this._then);

  final HistoryBillDto _self;
  final $Res Function(HistoryBillDto) _then;

/// Create a copy of HistoryBillDto
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
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoryBillDto].
extension HistoryBillDtoPatterns on HistoryBillDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoryBillDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoryBillDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoryBillDto value)  $default,){
final _that = this;
switch (_that) {
case _HistoryBillDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoryBillDto value)?  $default,){
final _that = this;
switch (_that) {
case _HistoryBillDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'currency_code')  String currencyCode, @JsonKey(name: 'tax_amount')  double tax, @JsonKey(name: 'service_charge')  double service, @JsonKey(name: 'is_settled')  bool isSettled, @JsonKey(name: 'receipt_date')  DateTime? receiptDate, @JsonKey(name: 'created_at')  DateTime createdAt,  String category, @JsonKey(name: 'bill_tags')  List<String> tags, @JsonKey(name: 'participant_count')  int participantCount, @JsonKey(name: 'paid_participant_count')  int paidParticipantCount, @JsonKey(name: 'payment_status')  String paymentStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoryBillDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'currency_code')  String currencyCode, @JsonKey(name: 'tax_amount')  double tax, @JsonKey(name: 'service_charge')  double service, @JsonKey(name: 'is_settled')  bool isSettled, @JsonKey(name: 'receipt_date')  DateTime? receiptDate, @JsonKey(name: 'created_at')  DateTime createdAt,  String category, @JsonKey(name: 'bill_tags')  List<String> tags, @JsonKey(name: 'participant_count')  int participantCount, @JsonKey(name: 'paid_participant_count')  int paidParticipantCount, @JsonKey(name: 'payment_status')  String paymentStatus)  $default,) {final _that = this;
switch (_that) {
case _HistoryBillDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'currency_code')  String currencyCode, @JsonKey(name: 'tax_amount')  double tax, @JsonKey(name: 'service_charge')  double service, @JsonKey(name: 'is_settled')  bool isSettled, @JsonKey(name: 'receipt_date')  DateTime? receiptDate, @JsonKey(name: 'created_at')  DateTime createdAt,  String category, @JsonKey(name: 'bill_tags')  List<String> tags, @JsonKey(name: 'participant_count')  int participantCount, @JsonKey(name: 'paid_participant_count')  int paidParticipantCount, @JsonKey(name: 'payment_status')  String paymentStatus)?  $default,) {final _that = this;
switch (_that) {
case _HistoryBillDto() when $default != null:
return $default(_that.id,_that.title,_that.totalAmount,_that.currencyCode,_that.tax,_that.service,_that.isSettled,_that.receiptDate,_that.createdAt,_that.category,_that.tags,_that.participantCount,_that.paidParticipantCount,_that.paymentStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HistoryBillDto implements HistoryBillDto {
  const _HistoryBillDto({required this.id, required this.title, @JsonKey(name: 'total_amount') required this.totalAmount, @JsonKey(name: 'currency_code') this.currencyCode = 'IDR', @JsonKey(name: 'tax_amount') this.tax = 0, @JsonKey(name: 'service_charge') this.service = 0, @JsonKey(name: 'is_settled') this.isSettled = false, @JsonKey(name: 'receipt_date') this.receiptDate, @JsonKey(name: 'created_at') required this.createdAt, this.category = 'lain', @JsonKey(name: 'bill_tags') final  List<String> tags = const [], @JsonKey(name: 'participant_count') required this.participantCount, @JsonKey(name: 'paid_participant_count') required this.paidParticipantCount, @JsonKey(name: 'payment_status') required this.paymentStatus}): _tags = tags;
  factory _HistoryBillDto.fromJson(Map<String, dynamic> json) => _$HistoryBillDtoFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey(name: 'total_amount') final  double totalAmount;
@override@JsonKey(name: 'currency_code') final  String currencyCode;
@override@JsonKey(name: 'tax_amount') final  double tax;
@override@JsonKey(name: 'service_charge') final  double service;
@override@JsonKey(name: 'is_settled') final  bool isSettled;
@override@JsonKey(name: 'receipt_date') final  DateTime? receiptDate;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey() final  String category;
 final  List<String> _tags;
@override@JsonKey(name: 'bill_tags') List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(name: 'participant_count') final  int participantCount;
@override@JsonKey(name: 'paid_participant_count') final  int paidParticipantCount;
@override@JsonKey(name: 'payment_status') final  String paymentStatus;

/// Create a copy of HistoryBillDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryBillDtoCopyWith<_HistoryBillDto> get copyWith => __$HistoryBillDtoCopyWithImpl<_HistoryBillDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoryBillDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryBillDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.service, service) || other.service == service)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.paidParticipantCount, paidParticipantCount) || other.paidParticipantCount == paidParticipantCount)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,totalAmount,currencyCode,tax,service,isSettled,receiptDate,createdAt,category,const DeepCollectionEquality().hash(_tags),participantCount,paidParticipantCount,paymentStatus);

@override
String toString() {
  return 'HistoryBillDto(id: $id, title: $title, totalAmount: $totalAmount, currencyCode: $currencyCode, tax: $tax, service: $service, isSettled: $isSettled, receiptDate: $receiptDate, createdAt: $createdAt, category: $category, tags: $tags, participantCount: $participantCount, paidParticipantCount: $paidParticipantCount, paymentStatus: $paymentStatus)';
}


}

/// @nodoc
abstract mixin class _$HistoryBillDtoCopyWith<$Res> implements $HistoryBillDtoCopyWith<$Res> {
  factory _$HistoryBillDtoCopyWith(_HistoryBillDto value, $Res Function(_HistoryBillDto) _then) = __$HistoryBillDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'currency_code') String currencyCode,@JsonKey(name: 'tax_amount') double tax,@JsonKey(name: 'service_charge') double service,@JsonKey(name: 'is_settled') bool isSettled,@JsonKey(name: 'receipt_date') DateTime? receiptDate,@JsonKey(name: 'created_at') DateTime createdAt, String category,@JsonKey(name: 'bill_tags') List<String> tags,@JsonKey(name: 'participant_count') int participantCount,@JsonKey(name: 'paid_participant_count') int paidParticipantCount,@JsonKey(name: 'payment_status') String paymentStatus
});




}
/// @nodoc
class __$HistoryBillDtoCopyWithImpl<$Res>
    implements _$HistoryBillDtoCopyWith<$Res> {
  __$HistoryBillDtoCopyWithImpl(this._self, this._then);

  final _HistoryBillDto _self;
  final $Res Function(_HistoryBillDto) _then;

/// Create a copy of HistoryBillDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? totalAmount = null,Object? currencyCode = null,Object? tax = null,Object? service = null,Object? isSettled = null,Object? receiptDate = freezed,Object? createdAt = null,Object? category = null,Object? tags = null,Object? participantCount = null,Object? paidParticipantCount = null,Object? paymentStatus = null,}) {
  return _then(_HistoryBillDto(
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
as String,
  ));
}


}

// dart format on
