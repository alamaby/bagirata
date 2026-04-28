// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemDto {

 String get id;@JsonKey(name: 'bill_id') String get billId; String get name; double get price; double get qty;
/// Create a copy of ItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemDtoCopyWith<ItemDto> get copyWith => _$ItemDtoCopyWithImpl<ItemDto>(this as ItemDto, _$identity);

  /// Serializes this ItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.billId, billId) || other.billId == billId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.qty, qty) || other.qty == qty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,billId,name,price,qty);

@override
String toString() {
  return 'ItemDto(id: $id, billId: $billId, name: $name, price: $price, qty: $qty)';
}


}

/// @nodoc
abstract mixin class $ItemDtoCopyWith<$Res>  {
  factory $ItemDtoCopyWith(ItemDto value, $Res Function(ItemDto) _then) = _$ItemDtoCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'bill_id') String billId, String name, double price, double qty
});




}
/// @nodoc
class _$ItemDtoCopyWithImpl<$Res>
    implements $ItemDtoCopyWith<$Res> {
  _$ItemDtoCopyWithImpl(this._self, this._then);

  final ItemDto _self;
  final $Res Function(ItemDto) _then;

/// Create a copy of ItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? billId = null,Object? name = null,Object? price = null,Object? qty = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,billId: null == billId ? _self.billId : billId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemDto].
extension ItemDtoPatterns on ItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemDto value)  $default,){
final _that = this;
switch (_that) {
case _ItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _ItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'bill_id')  String billId,  String name,  double price,  double qty)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemDto() when $default != null:
return $default(_that.id,_that.billId,_that.name,_that.price,_that.qty);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'bill_id')  String billId,  String name,  double price,  double qty)  $default,) {final _that = this;
switch (_that) {
case _ItemDto():
return $default(_that.id,_that.billId,_that.name,_that.price,_that.qty);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'bill_id')  String billId,  String name,  double price,  double qty)?  $default,) {final _that = this;
switch (_that) {
case _ItemDto() when $default != null:
return $default(_that.id,_that.billId,_that.name,_that.price,_that.qty);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemDto extends ItemDto {
  const _ItemDto({required this.id, @JsonKey(name: 'bill_id') required this.billId, required this.name, required this.price, this.qty = 1.0}): super._();
  factory _ItemDto.fromJson(Map<String, dynamic> json) => _$ItemDtoFromJson(json);

@override final  String id;
@override@JsonKey(name: 'bill_id') final  String billId;
@override final  String name;
@override final  double price;
@override@JsonKey() final  double qty;

/// Create a copy of ItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemDtoCopyWith<_ItemDto> get copyWith => __$ItemDtoCopyWithImpl<_ItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.billId, billId) || other.billId == billId)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.qty, qty) || other.qty == qty));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,billId,name,price,qty);

@override
String toString() {
  return 'ItemDto(id: $id, billId: $billId, name: $name, price: $price, qty: $qty)';
}


}

/// @nodoc
abstract mixin class _$ItemDtoCopyWith<$Res> implements $ItemDtoCopyWith<$Res> {
  factory _$ItemDtoCopyWith(_ItemDto value, $Res Function(_ItemDto) _then) = __$ItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'bill_id') String billId, String name, double price, double qty
});




}
/// @nodoc
class __$ItemDtoCopyWithImpl<$Res>
    implements _$ItemDtoCopyWith<$Res> {
  __$ItemDtoCopyWithImpl(this._self, this._then);

  final _ItemDto _self;
  final $Res Function(_ItemDto) _then;

/// Create a copy of ItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? billId = null,Object? name = null,Object? price = null,Object? qty = null,}) {
  return _then(_ItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,billId: null == billId ? _self.billId : billId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,qty: null == qty ? _self.qty : qty // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
