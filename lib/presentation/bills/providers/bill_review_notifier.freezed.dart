// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill_review_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BillReviewItem {

 String get localId; String get name; double get price; double get qty;
/// Create a copy of BillReviewItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillReviewItemCopyWith<BillReviewItem> get copyWith => _$BillReviewItemCopyWithImpl<BillReviewItem>(this as BillReviewItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillReviewItem&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.qty, qty) || other.qty == qty));
}


@override
int get hashCode => Object.hash(runtimeType,localId,name,price,qty);

@override
String toString() {
  return 'BillReviewItem(localId: $localId, name: $name, price: $price, qty: $qty)';
}


}

/// @nodoc
abstract mixin class $BillReviewItemCopyWith<$Res>  {
  factory $BillReviewItemCopyWith(BillReviewItem value, $Res Function(BillReviewItem) _then) = _$BillReviewItemCopyWithImpl;
@useResult
$Res call({
 String localId, String name, double price, double qty
});




}
/// @nodoc
class _$BillReviewItemCopyWithImpl<$Res>
    implements $BillReviewItemCopyWith<$Res> {
  _$BillReviewItemCopyWithImpl(this._self, this._then);

  final BillReviewItem _self;
  final $Res Function(BillReviewItem) _then;

/// Create a copy of BillReviewItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localId = null,Object? name = null,Object? price = null,Object? qty = null,}) {
  return _then(_self.copyWith(
localId: null == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BillReviewItem].
extension BillReviewItemPatterns on BillReviewItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillReviewItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillReviewItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillReviewItem value)  $default,){
final _that = this;
switch (_that) {
case _BillReviewItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillReviewItem value)?  $default,){
final _that = this;
switch (_that) {
case _BillReviewItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String localId,  String name,  double price,  double qty)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillReviewItem() when $default != null:
return $default(_that.localId,_that.name,_that.price,_that.qty);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String localId,  String name,  double price,  double qty)  $default,) {final _that = this;
switch (_that) {
case _BillReviewItem():
return $default(_that.localId,_that.name,_that.price,_that.qty);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String localId,  String name,  double price,  double qty)?  $default,) {final _that = this;
switch (_that) {
case _BillReviewItem() when $default != null:
return $default(_that.localId,_that.name,_that.price,_that.qty);case _:
  return null;

}
}

}

/// @nodoc


class _BillReviewItem implements BillReviewItem {
  const _BillReviewItem({required this.localId, required this.name, required this.price, required this.qty});
  

@override final  String localId;
@override final  String name;
@override final  double price;
@override final  double qty;

/// Create a copy of BillReviewItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillReviewItemCopyWith<_BillReviewItem> get copyWith => __$BillReviewItemCopyWithImpl<_BillReviewItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillReviewItem&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.qty, qty) || other.qty == qty));
}


@override
int get hashCode => Object.hash(runtimeType,localId,name,price,qty);

@override
String toString() {
  return 'BillReviewItem(localId: $localId, name: $name, price: $price, qty: $qty)';
}


}

/// @nodoc
abstract mixin class _$BillReviewItemCopyWith<$Res> implements $BillReviewItemCopyWith<$Res> {
  factory _$BillReviewItemCopyWith(_BillReviewItem value, $Res Function(_BillReviewItem) _then) = __$BillReviewItemCopyWithImpl;
@override @useResult
$Res call({
 String localId, String name, double price, double qty
});




}
/// @nodoc
class __$BillReviewItemCopyWithImpl<$Res>
    implements _$BillReviewItemCopyWith<$Res> {
  __$BillReviewItemCopyWithImpl(this._self, this._then);

  final _BillReviewItem _self;
  final $Res Function(_BillReviewItem) _then;

/// Create a copy of BillReviewItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? localId = null,Object? name = null,Object? price = null,Object? qty = null,}) {
  return _then(_BillReviewItem(
localId: null == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$BillReviewState {

 String get title; List<BillReviewItem> get items; double get tax; double get service; DateTime? get receiptDate; double? get detectedTotal; double get confidence; bool get saving;
/// Create a copy of BillReviewState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillReviewStateCopyWith<BillReviewState> get copyWith => _$BillReviewStateCopyWithImpl<BillReviewState>(this as BillReviewState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BillReviewState&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.service, service) || other.service == service)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.detectedTotal, detectedTotal) || other.detectedTotal == detectedTotal)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.saving, saving) || other.saving == saving));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(items),tax,service,receiptDate,detectedTotal,confidence,saving);

@override
String toString() {
  return 'BillReviewState(title: $title, items: $items, tax: $tax, service: $service, receiptDate: $receiptDate, detectedTotal: $detectedTotal, confidence: $confidence, saving: $saving)';
}


}

/// @nodoc
abstract mixin class $BillReviewStateCopyWith<$Res>  {
  factory $BillReviewStateCopyWith(BillReviewState value, $Res Function(BillReviewState) _then) = _$BillReviewStateCopyWithImpl;
@useResult
$Res call({
 String title, List<BillReviewItem> items, double tax, double service, DateTime? receiptDate, double? detectedTotal, double confidence, bool saving
});




}
/// @nodoc
class _$BillReviewStateCopyWithImpl<$Res>
    implements $BillReviewStateCopyWith<$Res> {
  _$BillReviewStateCopyWithImpl(this._self, this._then);

  final BillReviewState _self;
  final $Res Function(BillReviewState) _then;

/// Create a copy of BillReviewState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? items = null,Object? tax = null,Object? service = null,Object? receiptDate = freezed,Object? detectedTotal = freezed,Object? confidence = null,Object? saving = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BillReviewItem>,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as double,receiptDate: freezed == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,detectedTotal: freezed == detectedTotal ? _self.detectedTotal : detectedTotal // ignore: cast_nullable_to_non_nullable
as double?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BillReviewState].
extension BillReviewStatePatterns on BillReviewState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BillReviewState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BillReviewState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BillReviewState value)  $default,){
final _that = this;
switch (_that) {
case _BillReviewState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BillReviewState value)?  $default,){
final _that = this;
switch (_that) {
case _BillReviewState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  List<BillReviewItem> items,  double tax,  double service,  DateTime? receiptDate,  double? detectedTotal,  double confidence,  bool saving)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BillReviewState() when $default != null:
return $default(_that.title,_that.items,_that.tax,_that.service,_that.receiptDate,_that.detectedTotal,_that.confidence,_that.saving);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  List<BillReviewItem> items,  double tax,  double service,  DateTime? receiptDate,  double? detectedTotal,  double confidence,  bool saving)  $default,) {final _that = this;
switch (_that) {
case _BillReviewState():
return $default(_that.title,_that.items,_that.tax,_that.service,_that.receiptDate,_that.detectedTotal,_that.confidence,_that.saving);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  List<BillReviewItem> items,  double tax,  double service,  DateTime? receiptDate,  double? detectedTotal,  double confidence,  bool saving)?  $default,) {final _that = this;
switch (_that) {
case _BillReviewState() when $default != null:
return $default(_that.title,_that.items,_that.tax,_that.service,_that.receiptDate,_that.detectedTotal,_that.confidence,_that.saving);case _:
  return null;

}
}

}

/// @nodoc


class _BillReviewState extends BillReviewState {
  const _BillReviewState({required this.title, required final  List<BillReviewItem> items, required this.tax, required this.service, this.receiptDate, this.detectedTotal, required this.confidence, this.saving = false}): _items = items,super._();
  

@override final  String title;
 final  List<BillReviewItem> _items;
@override List<BillReviewItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  double tax;
@override final  double service;
@override final  DateTime? receiptDate;
@override final  double? detectedTotal;
@override final  double confidence;
@override@JsonKey() final  bool saving;

/// Create a copy of BillReviewState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillReviewStateCopyWith<_BillReviewState> get copyWith => __$BillReviewStateCopyWithImpl<_BillReviewState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BillReviewState&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.tax, tax) || other.tax == tax)&&(identical(other.service, service) || other.service == service)&&(identical(other.receiptDate, receiptDate) || other.receiptDate == receiptDate)&&(identical(other.detectedTotal, detectedTotal) || other.detectedTotal == detectedTotal)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.saving, saving) || other.saving == saving));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_items),tax,service,receiptDate,detectedTotal,confidence,saving);

@override
String toString() {
  return 'BillReviewState(title: $title, items: $items, tax: $tax, service: $service, receiptDate: $receiptDate, detectedTotal: $detectedTotal, confidence: $confidence, saving: $saving)';
}


}

/// @nodoc
abstract mixin class _$BillReviewStateCopyWith<$Res> implements $BillReviewStateCopyWith<$Res> {
  factory _$BillReviewStateCopyWith(_BillReviewState value, $Res Function(_BillReviewState) _then) = __$BillReviewStateCopyWithImpl;
@override @useResult
$Res call({
 String title, List<BillReviewItem> items, double tax, double service, DateTime? receiptDate, double? detectedTotal, double confidence, bool saving
});




}
/// @nodoc
class __$BillReviewStateCopyWithImpl<$Res>
    implements _$BillReviewStateCopyWith<$Res> {
  __$BillReviewStateCopyWithImpl(this._self, this._then);

  final _BillReviewState _self;
  final $Res Function(_BillReviewState) _then;

/// Create a copy of BillReviewState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? items = null,Object? tax = null,Object? service = null,Object? receiptDate = freezed,Object? detectedTotal = freezed,Object? confidence = null,Object? saving = null,}) {
  return _then(_BillReviewState(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<BillReviewItem>,tax: null == tax ? _self.tax : tax // ignore: cast_nullable_to_non_nullable
as double,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as double,receiptDate: freezed == receiptDate ? _self.receiptDate : receiptDate // ignore: cast_nullable_to_non_nullable
as DateTime?,detectedTotal: freezed == detectedTotal ? _self.detectedTotal : detectedTotal // ignore: cast_nullable_to_non_nullable
as double?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,saving: null == saving ? _self.saving : saving // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
