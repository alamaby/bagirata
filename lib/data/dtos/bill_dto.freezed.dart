// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BillDto {

 String get id; String get title;@JsonKey(name: 'total_amount') double get totalAmount;@JsonKey(name: 'tax_amount') double get tax;@JsonKey(name: 'service_charge') double get service;@JsonKey(name: 'is_settled') bool get isSettled;@JsonKey(name: 'receipt_date') DateTime? get receiptDate;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of BillDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillDtoCopyWith<BillDto> get copyWith => _$BillDtoCopyWithImpl<BillDto>(this as BillDto, _$identity);

  /// Serializes this BillDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.service, service) || other.service == service)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,totalAmount,tax,service,isSettled,receiptDate,createdAt);

@override
String toString() {
  return 'BillDto(id: $id, title: $title, totalAmount: $totalAmount, tax: $tax, service: $service, isSettled: $isSettled, receiptDate: $receiptDate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BillDtoCopyWith<$Res>  {
  factory $BillDtoCopyWith(BillDto value, $Res Function(BillDto) _then) = _$BillDtoCopyWithImpl;
@useResult
$Res call({
 String id, String title,@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'tax_amount') double tax,@JsonKey(name: 'service_charge') double service,@JsonKey(name: 'is_settled') bool isSettled,@JsonKey(name: 'receipt_date') DateTime? receiptDate,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$BillDtoCopyWithImpl<$Res>
    implements $BillDtoCopyWith<$Res> {
  _$BillDtoCopyWithImpl(this._self, this._then);

  final BillDto _self;
  final $Res Function(BillDto) _then;

/// Create a copy of BillDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? totalAmount = null,Object? tax = null,Object? service = null,Object? isSettled = null,Object? receiptDate = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as double,isSettled: null == isSettled ? _self.isSettled : isSettled // ignore: cast_nullable_to_non_nullable
as bool,receiptDate: freezed == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BillDto].
extension BillDtoPatterns on BillDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillDto value)  $default,){
final _that = this;
switch (_that) {
case _BillDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillDto value)?  $default,){
final _that = this;
switch (_that) {
case _BillDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'tax_amount')  double tax, @JsonKey(name: 'service_charge')  double service, @JsonKey(name: 'is_settled')  bool isSettled, @JsonKey(name: 'receipt_date')  DateTime? receiptDate, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillDto() when $default != null:
return $default(_that.id,_that.title,_that.totalAmount,_that.tax,_that.service,_that.isSettled,_that.receiptDate,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'tax_amount')  double tax, @JsonKey(name: 'service_charge')  double service, @JsonKey(name: 'is_settled')  bool isSettled, @JsonKey(name: 'receipt_date')  DateTime? receiptDate, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BillDto():
return $default(_that.id,_that.title,_that.totalAmount,_that.tax,_that.service,_that.isSettled,_that.receiptDate,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @JsonKey(name: 'total_amount')  double totalAmount, @JsonKey(name: 'tax_amount')  double tax, @JsonKey(name: 'service_charge')  double service, @JsonKey(name: 'is_settled')  bool isSettled, @JsonKey(name: 'receipt_date')  DateTime? receiptDate, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BillDto() when $default != null:
return $default(_that.id,_that.title,_that.totalAmount,_that.tax,_that.service,_that.isSettled,_that.receiptDate,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BillDto extends BillDto {
  const _BillDto({required this.id, required this.title, @JsonKey(name: 'total_amount') required this.totalAmount, @JsonKey(name: 'tax_amount') this.tax = 0, @JsonKey(name: 'service_charge') this.service = 0, @JsonKey(name: 'is_settled') this.isSettled = false, @JsonKey(name: 'receipt_date') this.receiptDate, @JsonKey(name: 'created_at') required this.createdAt}): super._();
  factory _BillDto.fromJson(Map<String, dynamic> json) => _$BillDtoFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey(name: 'total_amount') final  double totalAmount;
@override@JsonKey(name: 'tax_amount') final  double tax;
@override@JsonKey(name: 'service_charge') final  double service;
@override@JsonKey(name: 'is_settled') final  bool isSettled;
@override@JsonKey(name: 'receipt_date') final  DateTime? receiptDate;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of BillDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillDtoCopyWith<_BillDto> get copyWith => __$BillDtoCopyWithImpl<_BillDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.service, service) || other.service == service)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,totalAmount,tax,service,isSettled,receiptDate,createdAt);

@override
String toString() {
  return 'BillDto(id: $id, title: $title, totalAmount: $totalAmount, tax: $tax, service: $service, isSettled: $isSettled, receiptDate: $receiptDate, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BillDtoCopyWith<$Res> implements $BillDtoCopyWith<$Res> {
  factory _$BillDtoCopyWith(_BillDto value, $Res Function(_BillDto) _then) = __$BillDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@JsonKey(name: 'total_amount') double totalAmount,@JsonKey(name: 'tax_amount') double tax,@JsonKey(name: 'service_charge') double service,@JsonKey(name: 'is_settled') bool isSettled,@JsonKey(name: 'receipt_date') DateTime? receiptDate,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$BillDtoCopyWithImpl<$Res>
    implements _$BillDtoCopyWith<$Res> {
  __$BillDtoCopyWithImpl(this._self, this._then);

  final _BillDto _self;
  final $Res Function(_BillDto) _then;

/// Create a copy of BillDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? totalAmount = null,Object? tax = null,Object? service = null,Object? isSettled = null,Object? receiptDate = freezed,Object? createdAt = null,}) {
  return _then(_BillDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as double,isSettled: null == isSettled ? _self.isSettled : isSettled // ignore: cast_nullable_to_non_nullable
as bool,receiptDate: freezed == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
