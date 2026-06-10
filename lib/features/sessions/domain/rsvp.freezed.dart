// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rsvp.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Rsvp {

 String get id; String get gameId; String get userId; RsvpStatus get status; int get guestCount; bool get userIsPlaying; int? get waitlistPosition; DateTime? get respondedAt;
/// Create a copy of Rsvp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RsvpCopyWith<Rsvp> get copyWith => _$RsvpCopyWithImpl<Rsvp>(this as Rsvp, _$identity);

  /// Serializes this Rsvp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Rsvp&&(identical(other.id, id) || other.id == id)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.guestCount, guestCount) || other.guestCount == guestCount)&&(identical(other.userIsPlaying, userIsPlaying) || other.userIsPlaying == userIsPlaying)&&(identical(other.waitlistPosition, waitlistPosition) || other.waitlistPosition == waitlistPosition)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gameId,userId,status,guestCount,userIsPlaying,waitlistPosition,respondedAt);

@override
String toString() {
  return 'Rsvp(id: $id, gameId: $gameId, userId: $userId, status: $status, guestCount: $guestCount, userIsPlaying: $userIsPlaying, waitlistPosition: $waitlistPosition, respondedAt: $respondedAt)';
}


}

/// @nodoc
abstract mixin class $RsvpCopyWith<$Res>  {
  factory $RsvpCopyWith(Rsvp value, $Res Function(Rsvp) _then) = _$RsvpCopyWithImpl;
@useResult
$Res call({
 String id, String gameId, String userId, RsvpStatus status, int guestCount, bool userIsPlaying, int? waitlistPosition, DateTime? respondedAt
});




}
/// @nodoc
class _$RsvpCopyWithImpl<$Res>
    implements $RsvpCopyWith<$Res> {
  _$RsvpCopyWithImpl(this._self, this._then);

  final Rsvp _self;
  final $Res Function(Rsvp) _then;

/// Create a copy of Rsvp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gameId = null,Object? userId = null,Object? status = null,Object? guestCount = null,Object? userIsPlaying = null,Object? waitlistPosition = freezed,Object? respondedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RsvpStatus,guestCount: null == guestCount ? _self.guestCount : guestCount // ignore: cast_nullable_to_non_nullable
as int,userIsPlaying: null == userIsPlaying ? _self.userIsPlaying : userIsPlaying // ignore: cast_nullable_to_non_nullable
as bool,waitlistPosition: freezed == waitlistPosition ? _self.waitlistPosition : waitlistPosition // ignore: cast_nullable_to_non_nullable
as int?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Rsvp].
extension RsvpPatterns on Rsvp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Rsvp value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Rsvp() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Rsvp value)  $default,){
final _that = this;
switch (_that) {
case _Rsvp():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Rsvp value)?  $default,){
final _that = this;
switch (_that) {
case _Rsvp() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gameId,  String userId,  RsvpStatus status,  int guestCount,  bool userIsPlaying,  int? waitlistPosition,  DateTime? respondedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Rsvp() when $default != null:
return $default(_that.id,_that.gameId,_that.userId,_that.status,_that.guestCount,_that.userIsPlaying,_that.waitlistPosition,_that.respondedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gameId,  String userId,  RsvpStatus status,  int guestCount,  bool userIsPlaying,  int? waitlistPosition,  DateTime? respondedAt)  $default,) {final _that = this;
switch (_that) {
case _Rsvp():
return $default(_that.id,_that.gameId,_that.userId,_that.status,_that.guestCount,_that.userIsPlaying,_that.waitlistPosition,_that.respondedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gameId,  String userId,  RsvpStatus status,  int guestCount,  bool userIsPlaying,  int? waitlistPosition,  DateTime? respondedAt)?  $default,) {final _that = this;
switch (_that) {
case _Rsvp() when $default != null:
return $default(_that.id,_that.gameId,_that.userId,_that.status,_that.guestCount,_that.userIsPlaying,_that.waitlistPosition,_that.respondedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Rsvp implements Rsvp {
  const _Rsvp({required this.id, required this.gameId, required this.userId, required this.status, required this.guestCount, required this.userIsPlaying, this.waitlistPosition, this.respondedAt});
  factory _Rsvp.fromJson(Map<String, dynamic> json) => _$RsvpFromJson(json);

@override final  String id;
@override final  String gameId;
@override final  String userId;
@override final  RsvpStatus status;
@override final  int guestCount;
@override final  bool userIsPlaying;
@override final  int? waitlistPosition;
@override final  DateTime? respondedAt;

/// Create a copy of Rsvp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RsvpCopyWith<_Rsvp> get copyWith => __$RsvpCopyWithImpl<_Rsvp>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RsvpToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Rsvp&&(identical(other.id, id) || other.id == id)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.status, status) || other.status == status)&&(identical(other.guestCount, guestCount) || other.guestCount == guestCount)&&(identical(other.userIsPlaying, userIsPlaying) || other.userIsPlaying == userIsPlaying)&&(identical(other.waitlistPosition, waitlistPosition) || other.waitlistPosition == waitlistPosition)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gameId,userId,status,guestCount,userIsPlaying,waitlistPosition,respondedAt);

@override
String toString() {
  return 'Rsvp(id: $id, gameId: $gameId, userId: $userId, status: $status, guestCount: $guestCount, userIsPlaying: $userIsPlaying, waitlistPosition: $waitlistPosition, respondedAt: $respondedAt)';
}


}

/// @nodoc
abstract mixin class _$RsvpCopyWith<$Res> implements $RsvpCopyWith<$Res> {
  factory _$RsvpCopyWith(_Rsvp value, $Res Function(_Rsvp) _then) = __$RsvpCopyWithImpl;
@override @useResult
$Res call({
 String id, String gameId, String userId, RsvpStatus status, int guestCount, bool userIsPlaying, int? waitlistPosition, DateTime? respondedAt
});




}
/// @nodoc
class __$RsvpCopyWithImpl<$Res>
    implements _$RsvpCopyWith<$Res> {
  __$RsvpCopyWithImpl(this._self, this._then);

  final _Rsvp _self;
  final $Res Function(_Rsvp) _then;

/// Create a copy of Rsvp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gameId = null,Object? userId = null,Object? status = null,Object? guestCount = null,Object? userIsPlaying = null,Object? waitlistPosition = freezed,Object? respondedAt = freezed,}) {
  return _then(_Rsvp(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RsvpStatus,guestCount: null == guestCount ? _self.guestCount : guestCount // ignore: cast_nullable_to_non_nullable
as int,userIsPlaying: null == userIsPlaying ? _self.userIsPlaying : userIsPlaying // ignore: cast_nullable_to_non_nullable
as bool,waitlistPosition: freezed == waitlistPosition ? _self.waitlistPosition : waitlistPosition // ignore: cast_nullable_to_non_nullable
as int?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
