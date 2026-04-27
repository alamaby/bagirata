// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OcrState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OcrState()';
}


}

/// @nodoc
class $OcrStateCopyWith<$Res>  {
$OcrStateCopyWith(OcrState _, $Res Function(OcrState) __);
}


/// Adds pattern-matching-related methods to [OcrState].
extension OcrStatePatterns on OcrState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OcrIdle value)?  idle,TResult Function( OcrProcessing value)?  processing,TResult Function( OcrSuccess value)?  success,TResult Function( OcrFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OcrIdle() when idle != null:
return idle(_that);case OcrProcessing() when processing != null:
return processing(_that);case OcrSuccess() when success != null:
return success(_that);case OcrFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OcrIdle value)  idle,required TResult Function( OcrProcessing value)  processing,required TResult Function( OcrSuccess value)  success,required TResult Function( OcrFailure value)  failure,}){
final _that = this;
switch (_that) {
case OcrIdle():
return idle(_that);case OcrProcessing():
return processing(_that);case OcrSuccess():
return success(_that);case OcrFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OcrIdle value)?  idle,TResult? Function( OcrProcessing value)?  processing,TResult? Function( OcrSuccess value)?  success,TResult? Function( OcrFailure value)?  failure,}){
final _that = this;
switch (_that) {
case OcrIdle() when idle != null:
return idle(_that);case OcrProcessing() when processing != null:
return processing(_that);case OcrSuccess() when success != null:
return success(_that);case OcrFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( int imageCount)?  processing,TResult Function( OcrResult result)?  success,TResult Function( Failure failure)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OcrIdle() when idle != null:
return idle();case OcrProcessing() when processing != null:
return processing(_that.imageCount);case OcrSuccess() when success != null:
return success(_that.result);case OcrFailure() when failure != null:
return failure(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( int imageCount)  processing,required TResult Function( OcrResult result)  success,required TResult Function( Failure failure)  failure,}) {final _that = this;
switch (_that) {
case OcrIdle():
return idle();case OcrProcessing():
return processing(_that.imageCount);case OcrSuccess():
return success(_that.result);case OcrFailure():
return failure(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( int imageCount)?  processing,TResult? Function( OcrResult result)?  success,TResult? Function( Failure failure)?  failure,}) {final _that = this;
switch (_that) {
case OcrIdle() when idle != null:
return idle();case OcrProcessing() when processing != null:
return processing(_that.imageCount);case OcrSuccess() when success != null:
return success(_that.result);case OcrFailure() when failure != null:
return failure(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class OcrIdle implements OcrState {
  const OcrIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OcrState.idle()';
}


}




/// @nodoc


class OcrProcessing implements OcrState {
  const OcrProcessing(this.imageCount);
  

 final  int imageCount;

/// Create a copy of OcrState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrProcessingCopyWith<OcrProcessing> get copyWith => _$OcrProcessingCopyWithImpl<OcrProcessing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrProcessing&&(identical(other.imageCount, imageCount) || other.imageCount == imageCount));
}


@override
int get hashCode => Object.hash(runtimeType,imageCount);

@override
String toString() {
  return 'OcrState.processing(imageCount: $imageCount)';
}


}

/// @nodoc
abstract mixin class $OcrProcessingCopyWith<$Res> implements $OcrStateCopyWith<$Res> {
  factory $OcrProcessingCopyWith(OcrProcessing value, $Res Function(OcrProcessing) _then) = _$OcrProcessingCopyWithImpl;
@useResult
$Res call({
 int imageCount
});




}
/// @nodoc
class _$OcrProcessingCopyWithImpl<$Res>
    implements $OcrProcessingCopyWith<$Res> {
  _$OcrProcessingCopyWithImpl(this._self, this._then);

  final OcrProcessing _self;
  final $Res Function(OcrProcessing) _then;

/// Create a copy of OcrState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? imageCount = null,}) {
  return _then(OcrProcessing(
null == imageCount ? _self.imageCount : imageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class OcrSuccess implements OcrState {
  const OcrSuccess(this.result);
  

 final  OcrResult result;

/// Create a copy of OcrState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrSuccessCopyWith<OcrSuccess> get copyWith => _$OcrSuccessCopyWithImpl<OcrSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrSuccess&&(identical(other.result, result) || other.result == result));
}


@override
int get hashCode => Object.hash(runtimeType,result);

@override
String toString() {
  return 'OcrState.success(result: $result)';
}


}

/// @nodoc
abstract mixin class $OcrSuccessCopyWith<$Res> implements $OcrStateCopyWith<$Res> {
  factory $OcrSuccessCopyWith(OcrSuccess value, $Res Function(OcrSuccess) _then) = _$OcrSuccessCopyWithImpl;
@useResult
$Res call({
 OcrResult result
});


$OcrResultCopyWith<$Res> get result;

}
/// @nodoc
class _$OcrSuccessCopyWithImpl<$Res>
    implements $OcrSuccessCopyWith<$Res> {
  _$OcrSuccessCopyWithImpl(this._self, this._then);

  final OcrSuccess _self;
  final $Res Function(OcrSuccess) _then;

/// Create a copy of OcrState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? result = null,}) {
  return _then(OcrSuccess(
null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as OcrResult,
  ));
}

/// Create a copy of OcrState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrResultCopyWith<$Res> get result {
  
  return $OcrResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

/// @nodoc


class OcrFailure implements OcrState {
  const OcrFailure(this.failure);
  

 final  Failure failure;

/// Create a copy of OcrState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrFailureCopyWith<OcrFailure> get copyWith => _$OcrFailureCopyWithImpl<OcrFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrFailure&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'OcrState.failure(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $OcrFailureCopyWith<$Res> implements $OcrStateCopyWith<$Res> {
  factory $OcrFailureCopyWith(OcrFailure value, $Res Function(OcrFailure) _then) = _$OcrFailureCopyWithImpl;
@useResult
$Res call({
 Failure failure
});


$FailureCopyWith<$Res> get failure;

}
/// @nodoc
class _$OcrFailureCopyWithImpl<$Res>
    implements $OcrFailureCopyWith<$Res> {
  _$OcrFailureCopyWithImpl(this._self, this._then);

  final OcrFailure _self;
  final $Res Function(OcrFailure) _then;

/// Create a copy of OcrState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(OcrFailure(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}

/// Create a copy of OcrState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res> get failure {
  
  return $FailureCopyWith<$Res>(_self.failure, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
