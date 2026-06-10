// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rsvp_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RsvpState {

 RsvpStatus get status; int? get waitlistPosition; int get guestCount; bool get userIsPlaying; bool get isUpdating; String? get error;
/// Create a copy of RsvpState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsvpStateCopyWith<RsvpState> get copyWith => _$RsvpStateCopyWithImpl<RsvpState>(this as RsvpState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RsvpState&&(identical(other.status, status) || other.status == status)&&(identical(other.waitlistPosition, waitlistPosition) || other.waitlistPosition == waitlistPosition)&&(identical(other.guestCount, guestCount) || other.guestCount == guestCount)&&(identical(other.userIsPlaying, userIsPlaying) || other.userIsPlaying == userIsPlaying)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,waitlistPosition,guestCount,userIsPlaying,isUpdating,error);

@override
String toString() {
  return 'RsvpState(status: $status, waitlistPosition: $waitlistPosition, guestCount: $guestCount, userIsPlaying: $userIsPlaying, isUpdating: $isUpdating, error: $error)';
}


}

/// @nodoc
abstract mixin class $RsvpStateCopyWith<$Res>  {
  factory $RsvpStateCopyWith(RsvpState value, $Res Function(RsvpState) _then) = _$RsvpStateCopyWithImpl;
@useResult
$Res call({
 RsvpStatus status, int? waitlistPosition, int guestCount, bool userIsPlaying, bool isUpdating, String? error
});




}
/// @nodoc
class _$RsvpStateCopyWithImpl<$Res>
    implements $RsvpStateCopyWith<$Res> {
  _$RsvpStateCopyWithImpl(this._self, this._then);

  final RsvpState _self;
  final $Res Function(RsvpState) _then;

/// Create a copy of RsvpState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? waitlistPosition = freezed,Object? guestCount = null,Object? userIsPlaying = null,Object? isUpdating = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RsvpStatus,waitlistPosition: freezed == waitlistPosition ? _self.waitlistPosition : waitlistPosition // ignore: cast_nullable_to_non_nullable
as int?,guestCount: null == guestCount ? _self.guestCount : guestCount // ignore: cast_nullable_to_non_nullable
as int,userIsPlaying: null == userIsPlaying ? _self.userIsPlaying : userIsPlaying // ignore: cast_nullable_to_non_nullable
as bool,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RsvpState].
extension RsvpStatePatterns on RsvpState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RsvpState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RsvpState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RsvpState value)  $default,){
final _that = this;
switch (_that) {
case _RsvpState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RsvpState value)?  $default,){
final _that = this;
switch (_that) {
case _RsvpState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RsvpStatus status,  int? waitlistPosition,  int guestCount,  bool userIsPlaying,  bool isUpdating,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RsvpState() when $default != null:
return $default(_that.status,_that.waitlistPosition,_that.guestCount,_that.userIsPlaying,_that.isUpdating,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RsvpStatus status,  int? waitlistPosition,  int guestCount,  bool userIsPlaying,  bool isUpdating,  String? error)  $default,) {final _that = this;
switch (_that) {
case _RsvpState():
return $default(_that.status,_that.waitlistPosition,_that.guestCount,_that.userIsPlaying,_that.isUpdating,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RsvpStatus status,  int? waitlistPosition,  int guestCount,  bool userIsPlaying,  bool isUpdating,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _RsvpState() when $default != null:
return $default(_that.status,_that.waitlistPosition,_that.guestCount,_that.userIsPlaying,_that.isUpdating,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _RsvpState implements RsvpState {
  const _RsvpState({required this.status, this.waitlistPosition, required this.guestCount, this.userIsPlaying = true, this.isUpdating = false, this.error});
  

@override final  RsvpStatus status;
@override final  int? waitlistPosition;
@override final  int guestCount;
@override@JsonKey() final  bool userIsPlaying;
@override@JsonKey() final  bool isUpdating;
@override final  String? error;

/// Create a copy of RsvpState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RsvpStateCopyWith<_RsvpState> get copyWith => __$RsvpStateCopyWithImpl<_RsvpState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RsvpState&&(identical(other.status, status) || other.status == status)&&(identical(other.waitlistPosition, waitlistPosition) || other.waitlistPosition == waitlistPosition)&&(identical(other.guestCount, guestCount) || other.guestCount == guestCount)&&(identical(other.userIsPlaying, userIsPlaying) || other.userIsPlaying == userIsPlaying)&&(identical(other.isUpdating, isUpdating) || other.isUpdating == isUpdating)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,waitlistPosition,guestCount,userIsPlaying,isUpdating,error);

@override
String toString() {
  return 'RsvpState(status: $status, waitlistPosition: $waitlistPosition, guestCount: $guestCount, userIsPlaying: $userIsPlaying, isUpdating: $isUpdating, error: $error)';
}


}

/// @nodoc
abstract mixin class _$RsvpStateCopyWith<$Res> implements $RsvpStateCopyWith<$Res> {
  factory _$RsvpStateCopyWith(_RsvpState value, $Res Function(_RsvpState) _then) = __$RsvpStateCopyWithImpl;
@override @useResult
$Res call({
 RsvpStatus status, int? waitlistPosition, int guestCount, bool userIsPlaying, bool isUpdating, String? error
});




}
/// @nodoc
class __$RsvpStateCopyWithImpl<$Res>
    implements _$RsvpStateCopyWith<$Res> {
  __$RsvpStateCopyWithImpl(this._self, this._then);

  final _RsvpState _self;
  final $Res Function(_RsvpState) _then;

/// Create a copy of RsvpState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? waitlistPosition = freezed,Object? guestCount = null,Object? userIsPlaying = null,Object? isUpdating = null,Object? error = freezed,}) {
  return _then(_RsvpState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RsvpStatus,waitlistPosition: freezed == waitlistPosition ? _self.waitlistPosition : waitlistPosition // ignore: cast_nullable_to_non_nullable
as int?,guestCount: null == guestCount ? _self.guestCount : guestCount // ignore: cast_nullable_to_non_nullable
as int,userIsPlaying: null == userIsPlaying ? _self.userIsPlaying : userIsPlaying // ignore: cast_nullable_to_non_nullable
as bool,isUpdating: null == isUpdating ? _self.isUpdating : isUpdating // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
