// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OcrLineItemDto {

 String get name; double get price; double get qty;
/// Create a copy of OcrLineItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrLineItemDtoCopyWith<OcrLineItemDto> get copyWith => _$OcrLineItemDtoCopyWithImpl<OcrLineItemDto>(this as OcrLineItemDto, _$identity);

  /// Serializes this OcrLineItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrLineItemDto&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.qty, qty) || other.qty == qty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,qty);

@override
String toString() {
  return 'OcrLineItemDto(name: $name, price: $price, qty: $qty)';
}


}

/// @nodoc
abstract mixin class $OcrLineItemDtoCopyWith<$Res>  {
  factory $OcrLineItemDtoCopyWith(OcrLineItemDto value, $Res Function(OcrLineItemDto) _then) = _$OcrLineItemDtoCopyWithImpl;
@useResult
$Res call({
 String name, double price, double qty
});




}
/// @nodoc
class _$OcrLineItemDtoCopyWithImpl<$Res>
    implements $OcrLineItemDtoCopyWith<$Res> {
  _$OcrLineItemDtoCopyWithImpl(this._self, this._then);

  final OcrLineItemDto _self;
  final $Res Function(OcrLineItemDto) _then;

/// Create a copy of OcrLineItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? price = null,Object? qty = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OcrLineItemDto].
extension OcrLineItemDtoPatterns on OcrLineItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OcrLineItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OcrLineItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OcrLineItemDto value)  $default,){
final _that = this;
switch (_that) {
case _OcrLineItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OcrLineItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _OcrLineItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double price,  double qty)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OcrLineItemDto() when $default != null:
return $default(_that.name,_that.price,_that.qty);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double price,  double qty)  $default,) {final _that = this;
switch (_that) {
case _OcrLineItemDto():
return $default(_that.name,_that.price,_that.qty);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double price,  double qty)?  $default,) {final _that = this;
switch (_that) {
case _OcrLineItemDto() when $default != null:
return $default(_that.name,_that.price,_that.qty);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OcrLineItemDto extends OcrLineItemDto {
  const _OcrLineItemDto({required this.name, required this.price, this.qty = 1.0}): super._();
  factory _OcrLineItemDto.fromJson(Map<String, dynamic> json) => _$OcrLineItemDtoFromJson(json);

@override final  String name;
@override final  double price;
@override@JsonKey() final  double qty;

/// Create a copy of OcrLineItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OcrLineItemDtoCopyWith<_OcrLineItemDto> get copyWith => __$OcrLineItemDtoCopyWithImpl<_OcrLineItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OcrLineItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OcrLineItemDto&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.qty, qty) || other.qty == qty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,price,qty);

@override
String toString() {
  return 'OcrLineItemDto(name: $name, price: $price, qty: $qty)';
}


}

/// @nodoc
abstract mixin class _$OcrLineItemDtoCopyWith<$Res> implements $OcrLineItemDtoCopyWith<$Res> {
  factory _$OcrLineItemDtoCopyWith(_OcrLineItemDto value, $Res Function(_OcrLineItemDto) _then) = __$OcrLineItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String name, double price, double qty
});




}
/// @nodoc
class __$OcrLineItemDtoCopyWithImpl<$Res>
    implements _$OcrLineItemDtoCopyWith<$Res> {
  __$OcrLineItemDtoCopyWithImpl(this._self, this._then);

  final _OcrLineItemDto _self;
  final $Res Function(_OcrLineItemDto) _then;

/// Create a copy of OcrLineItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? price = null,Object? qty = null,}) {
  return _then(_OcrLineItemDto(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$OcrResponseDto {

 List<OcrLineItemDto> get items; double? get detectedTotal; double? get detectedTax; double? get detectedService; String? get merchant; DateTime? get receiptDate; double get confidence; String get providerUsed;
/// Create a copy of OcrResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrResponseDtoCopyWith<OcrResponseDto> get copyWith => _$OcrResponseDtoCopyWithImpl<OcrResponseDto>(this as OcrResponseDto, _$identity);

  /// Serializes this OcrResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrResponseDto&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.detectedTotal, detectedTotal) || other.detectedTotal == detectedTotal)&&(identical(other.detectedTax, detectedTax) || other.detectedTax == detectedTax)&&(identical(other.detectedService, detectedService) || other.detectedService == detectedService)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.providerUsed, providerUsed) || other.providerUsed == providerUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),detectedTotal,detectedTax,detectedService,merchant,receiptDate,confidence,providerUsed);

@override
String toString() {
  return 'OcrResponseDto(items: $items, detectedTotal: $detectedTotal, detectedTax: $detectedTax, detectedService: $detectedService, merchant: $merchant, receiptDate: $receiptDate, confidence: $confidence, providerUsed: $providerUsed)';
}


}

/// @nodoc
abstract mixin class $OcrResponseDtoCopyWith<$Res>  {
  factory $OcrResponseDtoCopyWith(OcrResponseDto value, $Res Function(OcrResponseDto) _then) = _$OcrResponseDtoCopyWithImpl;
@useResult
$Res call({
 List<OcrLineItemDto> items, double? detectedTotal, double? detectedTax, double? detectedService, String? merchant, DateTime? receiptDate, double confidence, String providerUsed
});




}
/// @nodoc
class _$OcrResponseDtoCopyWithImpl<$Res>
    implements $OcrResponseDtoCopyWith<$Res> {
  _$OcrResponseDtoCopyWithImpl(this._self, this._then);

  final OcrResponseDto _self;
  final $Res Function(OcrResponseDto) _then;

/// Create a copy of OcrResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? detectedTotal = freezed,Object? detectedTax = freezed,Object? detectedService = freezed,Object? merchant = freezed,Object? receiptDate = freezed,Object? confidence = null,Object? providerUsed = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OcrLineItemDto>,detectedTotal: freezed == detectedTotal ? _self.detectedTotal : detectedTotal // ignore: cast_nullable_to_non_nullable
as double?,detectedTax: freezed == detectedTax ? _self.detectedTax : detectedTax // ignore: cast_nullable_to_non_nullable
as double?,detectedService: freezed == detectedService ? _self.detectedService : detectedService // ignore: cast_nullable_to_non_nullable
as double?,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,receiptDate: freezed == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,providerUsed: null == providerUsed ? _self.providerUsed : providerUsed // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OcrResponseDto].
extension OcrResponseDtoPatterns on OcrResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OcrResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OcrResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OcrResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _OcrResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OcrResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _OcrResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OcrLineItemDto> items,  double? detectedTotal,  double? detectedTax,  double? detectedService,  String? merchant,  DateTime? receiptDate,  double confidence,  String providerUsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OcrResponseDto() when $default != null:
return $default(_that.items,_that.detectedTotal,_that.detectedTax,_that.detectedService,_that.merchant,_that.receiptDate,_that.confidence,_that.providerUsed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OcrLineItemDto> items,  double? detectedTotal,  double? detectedTax,  double? detectedService,  String? merchant,  DateTime? receiptDate,  double confidence,  String providerUsed)  $default,) {final _that = this;
switch (_that) {
case _OcrResponseDto():
return $default(_that.items,_that.detectedTotal,_that.detectedTax,_that.detectedService,_that.merchant,_that.receiptDate,_that.confidence,_that.providerUsed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OcrLineItemDto> items,  double? detectedTotal,  double? detectedTax,  double? detectedService,  String? merchant,  DateTime? receiptDate,  double confidence,  String providerUsed)?  $default,) {final _that = this;
switch (_that) {
case _OcrResponseDto() when $default != null:
return $default(_that.items,_that.detectedTotal,_that.detectedTax,_that.detectedService,_that.merchant,_that.receiptDate,_that.confidence,_that.providerUsed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OcrResponseDto extends OcrResponseDto {
  const _OcrResponseDto({required final  List<OcrLineItemDto> items, this.detectedTotal, this.detectedTax, this.detectedService, this.merchant, this.receiptDate, this.confidence = 0.0, required this.providerUsed}): _items = items,super._();
  factory _OcrResponseDto.fromJson(Map<String, dynamic> json) => _$OcrResponseDtoFromJson(json);

 final  List<OcrLineItemDto> _items;
@override List<OcrLineItemDto> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  double? detectedTotal;
@override final  double? detectedTax;
@override final  double? detectedService;
@override final  String? merchant;
@override final  DateTime? receiptDate;
@override@JsonKey() final  double confidence;
@override final  String providerUsed;

/// Create a copy of OcrResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OcrResponseDtoCopyWith<_OcrResponseDto> get copyWith => __$OcrResponseDtoCopyWithImpl<_OcrResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OcrResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OcrResponseDto&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.detectedTotal, detectedTotal) || other.detectedTotal == detectedTotal)&&(identical(other.detectedTax, detectedTax) || other.detectedTax == detectedTax)&&(identical(other.detectedService, detectedService) || other.detectedService == detectedService)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.providerUsed, providerUsed) || other.providerUsed == providerUsed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),detectedTotal,detectedTax,detectedService,merchant,receiptDate,confidence,providerUsed);

@override
String toString() {
  return 'OcrResponseDto(items: $items, detectedTotal: $detectedTotal, detectedTax: $detectedTax, detectedService: $detectedService, merchant: $merchant, receiptDate: $receiptDate, confidence: $confidence, providerUsed: $providerUsed)';
}


}

/// @nodoc
abstract mixin class _$OcrResponseDtoCopyWith<$Res> implements $OcrResponseDtoCopyWith<$Res> {
  factory _$OcrResponseDtoCopyWith(_OcrResponseDto value, $Res Function(_OcrResponseDto) _then) = __$OcrResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 List<OcrLineItemDto> items, double? detectedTotal, double? detectedTax, double? detectedService, String? merchant, DateTime? receiptDate, double confidence, String providerUsed
});




}
/// @nodoc
class __$OcrResponseDtoCopyWithImpl<$Res>
    implements _$OcrResponseDtoCopyWith<$Res> {
  __$OcrResponseDtoCopyWithImpl(this._self, this._then);

  final _OcrResponseDto _self;
  final $Res Function(_OcrResponseDto) _then;

/// Create a copy of OcrResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? detectedTotal = freezed,Object? detectedTax = freezed,Object? detectedService = freezed,Object? merchant = freezed,Object? receiptDate = freezed,Object? confidence = null,Object? providerUsed = null,}) {
  return _then(_OcrResponseDto(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OcrLineItemDto>,detectedTotal: freezed == detectedTotal ? _self.detectedTotal : detectedTotal // ignore: cast_nullable_to_non_nullable
as double?,detectedTax: freezed == detectedTax ? _self.detectedTax : detectedTax // ignore: cast_nullable_to_non_nullable
as double?,detectedService: freezed == detectedService ? _self.detectedService : detectedService // ignore: cast_nullable_to_non_nullable
as double?,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,receiptDate: freezed == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,providerUsed: null == providerUsed ? _self.providerUsed : providerUsed // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
