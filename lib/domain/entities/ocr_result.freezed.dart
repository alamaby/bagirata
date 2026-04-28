// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OcrLineItem {

 String get name; double get price; double get qty;
/// Create a copy of OcrLineItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrLineItemCopyWith<OcrLineItem> get copyWith => _$OcrLineItemCopyWithImpl<OcrLineItem>(this as OcrLineItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrLineItem&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.qty, qty) || other.qty == qty));
}


@override
int get hashCode => Object.hash(runtimeType,name,price,qty);

@override
String toString() {
  return 'OcrLineItem(name: $name, price: $price, qty: $qty)';
}


}

/// @nodoc
abstract mixin class $OcrLineItemCopyWith<$Res>  {
  factory $OcrLineItemCopyWith(OcrLineItem value, $Res Function(OcrLineItem) _then) = _$OcrLineItemCopyWithImpl;
@useResult
$Res call({
 String name, double price, double qty
});




}
/// @nodoc
class _$OcrLineItemCopyWithImpl<$Res>
    implements $OcrLineItemCopyWith<$Res> {
  _$OcrLineItemCopyWithImpl(this._self, this._then);

  final OcrLineItem _self;
  final $Res Function(OcrLineItem) _then;

/// Create a copy of OcrLineItem
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


/// Adds pattern-matching-related methods to [OcrLineItem].
extension OcrLineItemPatterns on OcrLineItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OcrLineItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OcrLineItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OcrLineItem value)  $default,){
final _that = this;
switch (_that) {
case _OcrLineItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OcrLineItem value)?  $default,){
final _that = this;
switch (_that) {
case _OcrLineItem() when $default != null:
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
case _OcrLineItem() when $default != null:
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
case _OcrLineItem():
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
case _OcrLineItem() when $default != null:
return $default(_that.name,_that.price,_that.qty);case _:
  return null;

}
}

}

/// @nodoc


class _OcrLineItem implements OcrLineItem {
  const _OcrLineItem({required this.name, required this.price, this.qty = 1.0});
  

@override final  String name;
@override final  double price;
@override@JsonKey() final  double qty;

/// Create a copy of OcrLineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OcrLineItemCopyWith<_OcrLineItem> get copyWith => __$OcrLineItemCopyWithImpl<_OcrLineItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OcrLineItem&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.qty, qty) || other.qty == qty));
}


@override
int get hashCode => Object.hash(runtimeType,name,price,qty);

@override
String toString() {
  return 'OcrLineItem(name: $name, price: $price, qty: $qty)';
}


}

/// @nodoc
abstract mixin class _$OcrLineItemCopyWith<$Res> implements $OcrLineItemCopyWith<$Res> {
  factory _$OcrLineItemCopyWith(_OcrLineItem value, $Res Function(_OcrLineItem) _then) = __$OcrLineItemCopyWithImpl;
@override @useResult
$Res call({
 String name, double price, double qty
});




}
/// @nodoc
class __$OcrLineItemCopyWithImpl<$Res>
    implements _$OcrLineItemCopyWith<$Res> {
  __$OcrLineItemCopyWithImpl(this._self, this._then);

  final _OcrLineItem _self;
  final $Res Function(_OcrLineItem) _then;

/// Create a copy of OcrLineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? price = null,Object? qty = null,}) {
  return _then(_OcrLineItem(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$OcrResult {

 List<OcrLineItem> get items; double? get detectedTotal; double? get detectedTax; double? get detectedService; String? get merchant; DateTime? get receiptDate; double get confidence; String get providerUsed;
/// Create a copy of OcrResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrResultCopyWith<OcrResult> get copyWith => _$OcrResultCopyWithImpl<OcrResult>(this as OcrResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrResult&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.detectedTotal, detectedTotal) || other.detectedTotal == detectedTotal)&&(identical(other.detectedTax, detectedTax) || other.detectedTax == detectedTax)&&(identical(other.detectedService, detectedService) || other.detectedService == detectedService)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.providerUsed, providerUsed) || other.providerUsed == providerUsed));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),detectedTotal,detectedTax,detectedService,merchant,receiptDate,confidence,providerUsed);

@override
String toString() {
  return 'OcrResult(items: $items, detectedTotal: $detectedTotal, detectedTax: $detectedTax, detectedService: $detectedService, merchant: $merchant, receiptDate: $receiptDate, confidence: $confidence, providerUsed: $providerUsed)';
}


}

/// @nodoc
abstract mixin class $OcrResultCopyWith<$Res>  {
  factory $OcrResultCopyWith(OcrResult value, $Res Function(OcrResult) _then) = _$OcrResultCopyWithImpl;
@useResult
$Res call({
 List<OcrLineItem> items, double? detectedTotal, double? detectedTax, double? detectedService, String? merchant, DateTime? receiptDate, double confidence, String providerUsed
});




}
/// @nodoc
class _$OcrResultCopyWithImpl<$Res>
    implements $OcrResultCopyWith<$Res> {
  _$OcrResultCopyWithImpl(this._self, this._then);

  final OcrResult _self;
  final $Res Function(OcrResult) _then;

/// Create a copy of OcrResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? detectedTotal = freezed,Object? detectedTax = freezed,Object? detectedService = freezed,Object? merchant = freezed,Object? receiptDate = freezed,Object? confidence = null,Object? providerUsed = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OcrLineItem>,detectedTotal: freezed == detectedTotal ? _self.detectedTotal : detectedTotal // ignore: cast_nullable_to_non_nullable
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


/// Adds pattern-matching-related methods to [OcrResult].
extension OcrResultPatterns on OcrResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OcrResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OcrResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OcrResult value)  $default,){
final _that = this;
switch (_that) {
case _OcrResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OcrResult value)?  $default,){
final _that = this;
switch (_that) {
case _OcrResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OcrLineItem> items,  double? detectedTotal,  double? detectedTax,  double? detectedService,  String? merchant,  DateTime? receiptDate,  double confidence,  String providerUsed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OcrResult() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OcrLineItem> items,  double? detectedTotal,  double? detectedTax,  double? detectedService,  String? merchant,  DateTime? receiptDate,  double confidence,  String providerUsed)  $default,) {final _that = this;
switch (_that) {
case _OcrResult():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OcrLineItem> items,  double? detectedTotal,  double? detectedTax,  double? detectedService,  String? merchant,  DateTime? receiptDate,  double confidence,  String providerUsed)?  $default,) {final _that = this;
switch (_that) {
case _OcrResult() when $default != null:
return $default(_that.items,_that.detectedTotal,_that.detectedTax,_that.detectedService,_that.merchant,_that.receiptDate,_that.confidence,_that.providerUsed);case _:
  return null;

}
}

}

/// @nodoc


class _OcrResult implements OcrResult {
  const _OcrResult({required final  List<OcrLineItem> items, this.detectedTotal, this.detectedTax, this.detectedService, this.merchant, this.receiptDate, this.confidence = 0.0, required this.providerUsed}): _items = items;
  

 final  List<OcrLineItem> _items;
@override List<OcrLineItem> get items {
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

/// Create a copy of OcrResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OcrResultCopyWith<_OcrResult> get copyWith => __$OcrResultCopyWithImpl<_OcrResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OcrResult&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.detectedTotal, detectedTotal) || other.detectedTotal == detectedTotal)&&(identical(other.detectedTax, detectedTax) || other.detectedTax == detectedTax)&&(identical(other.detectedService, detectedService) || other.detectedService == detectedService)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.providerUsed, providerUsed) || other.providerUsed == providerUsed));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),detectedTotal,detectedTax,detectedService,merchant,receiptDate,confidence,providerUsed);

@override
String toString() {
  return 'OcrResult(items: $items, detectedTotal: $detectedTotal, detectedTax: $detectedTax, detectedService: $detectedService, merchant: $merchant, receiptDate: $receiptDate, confidence: $confidence, providerUsed: $providerUsed)';
}


}

/// @nodoc
abstract mixin class _$OcrResultCopyWith<$Res> implements $OcrResultCopyWith<$Res> {
  factory _$OcrResultCopyWith(_OcrResult value, $Res Function(_OcrResult) _then) = __$OcrResultCopyWithImpl;
@override @useResult
$Res call({
 List<OcrLineItem> items, double? detectedTotal, double? detectedTax, double? detectedService, String? merchant, DateTime? receiptDate, double confidence, String providerUsed
});




}
/// @nodoc
class __$OcrResultCopyWithImpl<$Res>
    implements _$OcrResultCopyWith<$Res> {
  __$OcrResultCopyWithImpl(this._self, this._then);

  final _OcrResult _self;
  final $Res Function(_OcrResult) _then;

/// Create a copy of OcrResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? detectedTotal = freezed,Object? detectedTax = freezed,Object? detectedService = freezed,Object? merchant = freezed,Object? receiptDate = freezed,Object? confidence = null,Object? providerUsed = null,}) {
  return _then(_OcrResult(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OcrLineItem>,detectedTotal: freezed == detectedTotal ? _self.detectedTotal : detectedTotal // ignore: cast_nullable_to_non_nullable
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
