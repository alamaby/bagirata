// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Failure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure()';
}


}

/// @nodoc
class $FailureCopyWith<$Res>  {
$FailureCopyWith(Failure _, $Res Function(Failure) __);
}


/// Adds pattern-matching-related methods to [Failure].
extension FailurePatterns on Failure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NetworkFailure value)?  network,TResult Function( ServerFailure value)?  server,TResult Function( ParsingFailure value)?  parsing,TResult Function( AuthFailure value)?  auth,TResult Function( UnknownFailure value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that);case ServerFailure() when server != null:
return server(_that);case ParsingFailure() when parsing != null:
return parsing(_that);case AuthFailure() when auth != null:
return auth(_that);case UnknownFailure() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NetworkFailure value)  network,required TResult Function( ServerFailure value)  server,required TResult Function( ParsingFailure value)  parsing,required TResult Function( AuthFailure value)  auth,required TResult Function( UnknownFailure value)  unknown,}){
final _that = this;
switch (_that) {
case NetworkFailure():
return network(_that);case ServerFailure():
return server(_that);case ParsingFailure():
return parsing(_that);case AuthFailure():
return auth(_that);case UnknownFailure():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NetworkFailure value)?  network,TResult? Function( ServerFailure value)?  server,TResult? Function( ParsingFailure value)?  parsing,TResult? Function( AuthFailure value)?  auth,TResult? Function( UnknownFailure value)?  unknown,}){
final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that);case ServerFailure() when server != null:
return server(_that);case ParsingFailure() when parsing != null:
return parsing(_that);case AuthFailure() when auth != null:
return auth(_that);case UnknownFailure() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message)?  network,TResult Function( int? code,  String message)?  server,TResult Function( String message)?  parsing,TResult Function( String message)?  auth,TResult Function( Object error,  StackTrace? stack)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that.message);case ServerFailure() when server != null:
return server(_that.code,_that.message);case ParsingFailure() when parsing != null:
return parsing(_that.message);case AuthFailure() when auth != null:
return auth(_that.message);case UnknownFailure() when unknown != null:
return unknown(_that.error,_that.stack);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message)  network,required TResult Function( int? code,  String message)  server,required TResult Function( String message)  parsing,required TResult Function( String message)  auth,required TResult Function( Object error,  StackTrace? stack)  unknown,}) {final _that = this;
switch (_that) {
case NetworkFailure():
return network(_that.message);case ServerFailure():
return server(_that.code,_that.message);case ParsingFailure():
return parsing(_that.message);case AuthFailure():
return auth(_that.message);case UnknownFailure():
return unknown(_that.error,_that.stack);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message)?  network,TResult? Function( int? code,  String message)?  server,TResult? Function( String message)?  parsing,TResult? Function( String message)?  auth,TResult? Function( Object error,  StackTrace? stack)?  unknown,}) {final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that.message);case ServerFailure() when server != null:
return server(_that.code,_that.message);case ParsingFailure() when parsing != null:
return parsing(_that.message);case AuthFailure() when auth != null:
return auth(_that.message);case UnknownFailure() when unknown != null:
return unknown(_that.error,_that.stack);case _:
  return null;

}
}

}

/// @nodoc


class NetworkFailure implements Failure {
  const NetworkFailure(this.message);
  

 final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkFailureCopyWith<NetworkFailure> get copyWith => _$NetworkFailureCopyWithImpl<NetworkFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.network(message: $message)';
}


}

/// @nodoc
abstract mixin class $NetworkFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $NetworkFailureCopyWith(NetworkFailure value, $Res Function(NetworkFailure) _then) = _$NetworkFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$NetworkFailureCopyWithImpl<$Res>
    implements $NetworkFailureCopyWith<$Res> {
  _$NetworkFailureCopyWithImpl(this._self, this._then);

  final NetworkFailure _self;
  final $Res Function(NetworkFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(NetworkFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ServerFailure implements Failure {
  const ServerFailure({this.code, required this.message});
  

 final  int? code;
 final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerFailureCopyWith<ServerFailure> get copyWith => _$ServerFailureCopyWithImpl<ServerFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,code,message);

@override
String toString() {
  return 'Failure.server(code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $ServerFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ServerFailureCopyWith(ServerFailure value, $Res Function(ServerFailure) _then) = _$ServerFailureCopyWithImpl;
@useResult
$Res call({
 int? code, String message
});




}
/// @nodoc
class _$ServerFailureCopyWithImpl<$Res>
    implements $ServerFailureCopyWith<$Res> {
  _$ServerFailureCopyWithImpl(this._self, this._then);

  final ServerFailure _self;
  final $Res Function(ServerFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = freezed,Object? message = null,}) {
  return _then(ServerFailure(
code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as int?,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ParsingFailure implements Failure {
  const ParsingFailure(this.message);
  

 final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsingFailureCopyWith<ParsingFailure> get copyWith => _$ParsingFailureCopyWithImpl<ParsingFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsingFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.parsing(message: $message)';
}


}

/// @nodoc
abstract mixin class $ParsingFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ParsingFailureCopyWith(ParsingFailure value, $Res Function(ParsingFailure) _then) = _$ParsingFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ParsingFailureCopyWithImpl<$Res>
    implements $ParsingFailureCopyWith<$Res> {
  _$ParsingFailureCopyWithImpl(this._self, this._then);

  final ParsingFailure _self;
  final $Res Function(ParsingFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ParsingFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AuthFailure implements Failure {
  const AuthFailure(this.message);
  

 final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthFailureCopyWith<AuthFailure> get copyWith => _$AuthFailureCopyWithImpl<AuthFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.auth(message: $message)';
}


}

/// @nodoc
abstract mixin class $AuthFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $AuthFailureCopyWith(AuthFailure value, $Res Function(AuthFailure) _then) = _$AuthFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AuthFailureCopyWithImpl<$Res>
    implements $AuthFailureCopyWith<$Res> {
  _$AuthFailureCopyWithImpl(this._self, this._then);

  final AuthFailure _self;
  final $Res Function(AuthFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AuthFailure(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UnknownFailure implements Failure {
  const UnknownFailure(this.error, this.stack);
  

 final  Object error;
 final  StackTrace? stack;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownFailureCopyWith<UnknownFailure> get copyWith => _$UnknownFailureCopyWithImpl<UnknownFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownFailure&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.stack, stack) || other.stack == stack));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(error),stack);

@override
String toString() {
  return 'Failure.unknown(error: $error, stack: $stack)';
}


}

/// @nodoc
abstract mixin class $UnknownFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $UnknownFailureCopyWith(UnknownFailure value, $Res Function(UnknownFailure) _then) = _$UnknownFailureCopyWithImpl;
@useResult
$Res call({
 Object error, StackTrace? stack
});




}
/// @nodoc
class _$UnknownFailureCopyWithImpl<$Res>
    implements $UnknownFailureCopyWith<$Res> {
  _$UnknownFailureCopyWithImpl(this._self, this._then);

  final UnknownFailure _self;
  final $Res Function(UnknownFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,Object? stack = freezed,}) {
  return _then(UnknownFailure(
null == error ? _self.error : error ,freezed == stack ? _self.stack : stack // ignore: cast_nullable_to_non_nullable
as StackTrace?,
  ));
}


}

// dart format on
