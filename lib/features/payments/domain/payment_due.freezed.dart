// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_due.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentDue {

 String get id; String get gameId; String get groupId; String get playerId; String get paymentOwnerId; int get amountPaise; DueStatus get status; String? get utrReference; DateTime? get submittedAt; DateTime? get verifiedAt; String? get verifiedBy; int get rejectionCount; DateTime get createdAt;// Nested profiles join payload
 Map<String, dynamic>? get profiles;// Nested games join payload
 Map<String, dynamic>? get games;
/// Create a copy of PaymentDue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentDueCopyWith<PaymentDue> get copyWith => _$PaymentDueCopyWithImpl<PaymentDue>(this as PaymentDue, _$identity);

  /// Serializes this PaymentDue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentDue&&(identical(other.id, id) || other.id == id)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.paymentOwnerId, paymentOwnerId) || other.paymentOwnerId == paymentOwnerId)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.status, status) || other.status == status)&&(identical(other.utrReference, utrReference) || other.utrReference == utrReference)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.rejectionCount, rejectionCount) || other.rejectionCount == rejectionCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.profiles, profiles)&&const DeepCollectionEquality().equals(other.games, games));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gameId,groupId,playerId,paymentOwnerId,amountPaise,status,utrReference,submittedAt,verifiedAt,verifiedBy,rejectionCount,createdAt,const DeepCollectionEquality().hash(profiles),const DeepCollectionEquality().hash(games));

@override
String toString() {
  return 'PaymentDue(id: $id, gameId: $gameId, groupId: $groupId, playerId: $playerId, paymentOwnerId: $paymentOwnerId, amountPaise: $amountPaise, status: $status, utrReference: $utrReference, submittedAt: $submittedAt, verifiedAt: $verifiedAt, verifiedBy: $verifiedBy, rejectionCount: $rejectionCount, createdAt: $createdAt, profiles: $profiles, games: $games)';
}


}

/// @nodoc
abstract mixin class $PaymentDueCopyWith<$Res>  {
  factory $PaymentDueCopyWith(PaymentDue value, $Res Function(PaymentDue) _then) = _$PaymentDueCopyWithImpl;
@useResult
$Res call({
 String id, String gameId, String groupId, String playerId, String paymentOwnerId, int amountPaise, DueStatus status, String? utrReference, DateTime? submittedAt, DateTime? verifiedAt, String? verifiedBy, int rejectionCount, DateTime createdAt, Map<String, dynamic>? profiles, Map<String, dynamic>? games
});




}
/// @nodoc
class _$PaymentDueCopyWithImpl<$Res>
    implements $PaymentDueCopyWith<$Res> {
  _$PaymentDueCopyWithImpl(this._self, this._then);

  final PaymentDue _self;
  final $Res Function(PaymentDue) _then;

/// Create a copy of PaymentDue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gameId = null,Object? groupId = null,Object? playerId = null,Object? paymentOwnerId = null,Object? amountPaise = null,Object? status = null,Object? utrReference = freezed,Object? submittedAt = freezed,Object? verifiedAt = freezed,Object? verifiedBy = freezed,Object? rejectionCount = null,Object? createdAt = null,Object? profiles = freezed,Object? games = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,paymentOwnerId: null == paymentOwnerId ? _self.paymentOwnerId : paymentOwnerId // ignore: cast_nullable_to_non_nullable
as String,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DueStatus,utrReference: freezed == utrReference ? _self.utrReference : utrReference // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,rejectionCount: null == rejectionCount ? _self.rejectionCount : rejectionCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,profiles: freezed == profiles ? _self.profiles : profiles // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,games: freezed == games ? _self.games : games // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentDue].
extension PaymentDuePatterns on PaymentDue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentDue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentDue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentDue value)  $default,){
final _that = this;
switch (_that) {
case _PaymentDue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentDue value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentDue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gameId,  String groupId,  String playerId,  String paymentOwnerId,  int amountPaise,  DueStatus status,  String? utrReference,  DateTime? submittedAt,  DateTime? verifiedAt,  String? verifiedBy,  int rejectionCount,  DateTime createdAt,  Map<String, dynamic>? profiles,  Map<String, dynamic>? games)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentDue() when $default != null:
return $default(_that.id,_that.gameId,_that.groupId,_that.playerId,_that.paymentOwnerId,_that.amountPaise,_that.status,_that.utrReference,_that.submittedAt,_that.verifiedAt,_that.verifiedBy,_that.rejectionCount,_that.createdAt,_that.profiles,_that.games);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gameId,  String groupId,  String playerId,  String paymentOwnerId,  int amountPaise,  DueStatus status,  String? utrReference,  DateTime? submittedAt,  DateTime? verifiedAt,  String? verifiedBy,  int rejectionCount,  DateTime createdAt,  Map<String, dynamic>? profiles,  Map<String, dynamic>? games)  $default,) {final _that = this;
switch (_that) {
case _PaymentDue():
return $default(_that.id,_that.gameId,_that.groupId,_that.playerId,_that.paymentOwnerId,_that.amountPaise,_that.status,_that.utrReference,_that.submittedAt,_that.verifiedAt,_that.verifiedBy,_that.rejectionCount,_that.createdAt,_that.profiles,_that.games);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gameId,  String groupId,  String playerId,  String paymentOwnerId,  int amountPaise,  DueStatus status,  String? utrReference,  DateTime? submittedAt,  DateTime? verifiedAt,  String? verifiedBy,  int rejectionCount,  DateTime createdAt,  Map<String, dynamic>? profiles,  Map<String, dynamic>? games)?  $default,) {final _that = this;
switch (_that) {
case _PaymentDue() when $default != null:
return $default(_that.id,_that.gameId,_that.groupId,_that.playerId,_that.paymentOwnerId,_that.amountPaise,_that.status,_that.utrReference,_that.submittedAt,_that.verifiedAt,_that.verifiedBy,_that.rejectionCount,_that.createdAt,_that.profiles,_that.games);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _PaymentDue implements PaymentDue {
  const _PaymentDue({required this.id, required this.gameId, required this.groupId, required this.playerId, required this.paymentOwnerId, required this.amountPaise, required this.status, this.utrReference, this.submittedAt, this.verifiedAt, this.verifiedBy, required this.rejectionCount, required this.createdAt, final  Map<String, dynamic>? profiles, final  Map<String, dynamic>? games}): _profiles = profiles,_games = games;
  factory _PaymentDue.fromJson(Map<String, dynamic> json) => _$PaymentDueFromJson(json);

@override final  String id;
@override final  String gameId;
@override final  String groupId;
@override final  String playerId;
@override final  String paymentOwnerId;
@override final  int amountPaise;
@override final  DueStatus status;
@override final  String? utrReference;
@override final  DateTime? submittedAt;
@override final  DateTime? verifiedAt;
@override final  String? verifiedBy;
@override final  int rejectionCount;
@override final  DateTime createdAt;
// Nested profiles join payload
 final  Map<String, dynamic>? _profiles;
// Nested profiles join payload
@override Map<String, dynamic>? get profiles {
  final value = _profiles;
  if (value == null) return null;
  if (_profiles is EqualUnmodifiableMapView) return _profiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Nested games join payload
 final  Map<String, dynamic>? _games;
// Nested games join payload
@override Map<String, dynamic>? get games {
  final value = _games;
  if (value == null) return null;
  if (_games is EqualUnmodifiableMapView) return _games;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PaymentDue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentDueCopyWith<_PaymentDue> get copyWith => __$PaymentDueCopyWithImpl<_PaymentDue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentDueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentDue&&(identical(other.id, id) || other.id == id)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.paymentOwnerId, paymentOwnerId) || other.paymentOwnerId == paymentOwnerId)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.status, status) || other.status == status)&&(identical(other.utrReference, utrReference) || other.utrReference == utrReference)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.rejectionCount, rejectionCount) || other.rejectionCount == rejectionCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._profiles, _profiles)&&const DeepCollectionEquality().equals(other._games, _games));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,gameId,groupId,playerId,paymentOwnerId,amountPaise,status,utrReference,submittedAt,verifiedAt,verifiedBy,rejectionCount,createdAt,const DeepCollectionEquality().hash(_profiles),const DeepCollectionEquality().hash(_games));

@override
String toString() {
  return 'PaymentDue(id: $id, gameId: $gameId, groupId: $groupId, playerId: $playerId, paymentOwnerId: $paymentOwnerId, amountPaise: $amountPaise, status: $status, utrReference: $utrReference, submittedAt: $submittedAt, verifiedAt: $verifiedAt, verifiedBy: $verifiedBy, rejectionCount: $rejectionCount, createdAt: $createdAt, profiles: $profiles, games: $games)';
}


}

/// @nodoc
abstract mixin class _$PaymentDueCopyWith<$Res> implements $PaymentDueCopyWith<$Res> {
  factory _$PaymentDueCopyWith(_PaymentDue value, $Res Function(_PaymentDue) _then) = __$PaymentDueCopyWithImpl;
@override @useResult
$Res call({
 String id, String gameId, String groupId, String playerId, String paymentOwnerId, int amountPaise, DueStatus status, String? utrReference, DateTime? submittedAt, DateTime? verifiedAt, String? verifiedBy, int rejectionCount, DateTime createdAt, Map<String, dynamic>? profiles, Map<String, dynamic>? games
});




}
/// @nodoc
class __$PaymentDueCopyWithImpl<$Res>
    implements _$PaymentDueCopyWith<$Res> {
  __$PaymentDueCopyWithImpl(this._self, this._then);

  final _PaymentDue _self;
  final $Res Function(_PaymentDue) _then;

/// Create a copy of PaymentDue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gameId = null,Object? groupId = null,Object? playerId = null,Object? paymentOwnerId = null,Object? amountPaise = null,Object? status = null,Object? utrReference = freezed,Object? submittedAt = freezed,Object? verifiedAt = freezed,Object? verifiedBy = freezed,Object? rejectionCount = null,Object? createdAt = null,Object? profiles = freezed,Object? games = freezed,}) {
  return _then(_PaymentDue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,paymentOwnerId: null == paymentOwnerId ? _self.paymentOwnerId : paymentOwnerId // ignore: cast_nullable_to_non_nullable
as String,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DueStatus,utrReference: freezed == utrReference ? _self.utrReference : utrReference // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,rejectionCount: null == rejectionCount ? _self.rejectionCount : rejectionCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,profiles: freezed == profiles ? _self._profiles : profiles // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,games: freezed == games ? _self._games : games // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

/// @nodoc
mixin _$PlayerDuesSummary {

 String get playerId; String get playerName; String get playerEmoji; int get totalPendingPaise; int get gameCount; List<PaymentDue> get dues;
/// Create a copy of PlayerDuesSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerDuesSummaryCopyWith<PlayerDuesSummary> get copyWith => _$PlayerDuesSummaryCopyWithImpl<PlayerDuesSummary>(this as PlayerDuesSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerDuesSummary&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.playerEmoji, playerEmoji) || other.playerEmoji == playerEmoji)&&(identical(other.totalPendingPaise, totalPendingPaise) || other.totalPendingPaise == totalPendingPaise)&&(identical(other.gameCount, gameCount) || other.gameCount == gameCount)&&const DeepCollectionEquality().equals(other.dues, dues));
}


@override
int get hashCode => Object.hash(runtimeType,playerId,playerName,playerEmoji,totalPendingPaise,gameCount,const DeepCollectionEquality().hash(dues));

@override
String toString() {
  return 'PlayerDuesSummary(playerId: $playerId, playerName: $playerName, playerEmoji: $playerEmoji, totalPendingPaise: $totalPendingPaise, gameCount: $gameCount, dues: $dues)';
}


}

/// @nodoc
abstract mixin class $PlayerDuesSummaryCopyWith<$Res>  {
  factory $PlayerDuesSummaryCopyWith(PlayerDuesSummary value, $Res Function(PlayerDuesSummary) _then) = _$PlayerDuesSummaryCopyWithImpl;
@useResult
$Res call({
 String playerId, String playerName, String playerEmoji, int totalPendingPaise, int gameCount, List<PaymentDue> dues
});




}
/// @nodoc
class _$PlayerDuesSummaryCopyWithImpl<$Res>
    implements $PlayerDuesSummaryCopyWith<$Res> {
  _$PlayerDuesSummaryCopyWithImpl(this._self, this._then);

  final PlayerDuesSummary _self;
  final $Res Function(PlayerDuesSummary) _then;

/// Create a copy of PlayerDuesSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? playerName = null,Object? playerEmoji = null,Object? totalPendingPaise = null,Object? gameCount = null,Object? dues = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,playerEmoji: null == playerEmoji ? _self.playerEmoji : playerEmoji // ignore: cast_nullable_to_non_nullable
as String,totalPendingPaise: null == totalPendingPaise ? _self.totalPendingPaise : totalPendingPaise // ignore: cast_nullable_to_non_nullable
as int,gameCount: null == gameCount ? _self.gameCount : gameCount // ignore: cast_nullable_to_non_nullable
as int,dues: null == dues ? _self.dues : dues // ignore: cast_nullable_to_non_nullable
as List<PaymentDue>,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerDuesSummary].
extension PlayerDuesSummaryPatterns on PlayerDuesSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerDuesSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerDuesSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerDuesSummary value)  $default,){
final _that = this;
switch (_that) {
case _PlayerDuesSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerDuesSummary value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerDuesSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  String playerName,  String playerEmoji,  int totalPendingPaise,  int gameCount,  List<PaymentDue> dues)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerDuesSummary() when $default != null:
return $default(_that.playerId,_that.playerName,_that.playerEmoji,_that.totalPendingPaise,_that.gameCount,_that.dues);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  String playerName,  String playerEmoji,  int totalPendingPaise,  int gameCount,  List<PaymentDue> dues)  $default,) {final _that = this;
switch (_that) {
case _PlayerDuesSummary():
return $default(_that.playerId,_that.playerName,_that.playerEmoji,_that.totalPendingPaise,_that.gameCount,_that.dues);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  String playerName,  String playerEmoji,  int totalPendingPaise,  int gameCount,  List<PaymentDue> dues)?  $default,) {final _that = this;
switch (_that) {
case _PlayerDuesSummary() when $default != null:
return $default(_that.playerId,_that.playerName,_that.playerEmoji,_that.totalPendingPaise,_that.gameCount,_that.dues);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerDuesSummary implements PlayerDuesSummary {
  const _PlayerDuesSummary({required this.playerId, required this.playerName, required this.playerEmoji, required this.totalPendingPaise, required this.gameCount, required final  List<PaymentDue> dues}): _dues = dues;
  

@override final  String playerId;
@override final  String playerName;
@override final  String playerEmoji;
@override final  int totalPendingPaise;
@override final  int gameCount;
 final  List<PaymentDue> _dues;
@override List<PaymentDue> get dues {
  if (_dues is EqualUnmodifiableListView) return _dues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dues);
}


/// Create a copy of PlayerDuesSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerDuesSummaryCopyWith<_PlayerDuesSummary> get copyWith => __$PlayerDuesSummaryCopyWithImpl<_PlayerDuesSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerDuesSummary&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.playerEmoji, playerEmoji) || other.playerEmoji == playerEmoji)&&(identical(other.totalPendingPaise, totalPendingPaise) || other.totalPendingPaise == totalPendingPaise)&&(identical(other.gameCount, gameCount) || other.gameCount == gameCount)&&const DeepCollectionEquality().equals(other._dues, _dues));
}


@override
int get hashCode => Object.hash(runtimeType,playerId,playerName,playerEmoji,totalPendingPaise,gameCount,const DeepCollectionEquality().hash(_dues));

@override
String toString() {
  return 'PlayerDuesSummary(playerId: $playerId, playerName: $playerName, playerEmoji: $playerEmoji, totalPendingPaise: $totalPendingPaise, gameCount: $gameCount, dues: $dues)';
}


}

/// @nodoc
abstract mixin class _$PlayerDuesSummaryCopyWith<$Res> implements $PlayerDuesSummaryCopyWith<$Res> {
  factory _$PlayerDuesSummaryCopyWith(_PlayerDuesSummary value, $Res Function(_PlayerDuesSummary) _then) = __$PlayerDuesSummaryCopyWithImpl;
@override @useResult
$Res call({
 String playerId, String playerName, String playerEmoji, int totalPendingPaise, int gameCount, List<PaymentDue> dues
});




}
/// @nodoc
class __$PlayerDuesSummaryCopyWithImpl<$Res>
    implements _$PlayerDuesSummaryCopyWith<$Res> {
  __$PlayerDuesSummaryCopyWithImpl(this._self, this._then);

  final _PlayerDuesSummary _self;
  final $Res Function(_PlayerDuesSummary) _then;

/// Create a copy of PlayerDuesSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? playerName = null,Object? playerEmoji = null,Object? totalPendingPaise = null,Object? gameCount = null,Object? dues = null,}) {
  return _then(_PlayerDuesSummary(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,playerEmoji: null == playerEmoji ? _self.playerEmoji : playerEmoji // ignore: cast_nullable_to_non_nullable
as String,totalPendingPaise: null == totalPendingPaise ? _self.totalPendingPaise : totalPendingPaise // ignore: cast_nullable_to_non_nullable
as int,gameCount: null == gameCount ? _self.gameCount : gameCount // ignore: cast_nullable_to_non_nullable
as int,dues: null == dues ? _self._dues : dues // ignore: cast_nullable_to_non_nullable
as List<PaymentDue>,
  ));
}


}

/// @nodoc
mixin _$GameDuesSummary {

 String get gameId; String get gameTitle; DateTime get scheduledAt; int get totalPendingPaise; int get unpaidCount; List<GamePlayerDue> get playerDues;
/// Create a copy of GameDuesSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameDuesSummaryCopyWith<GameDuesSummary> get copyWith => _$GameDuesSummaryCopyWithImpl<GameDuesSummary>(this as GameDuesSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameDuesSummary&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.gameTitle, gameTitle) || other.gameTitle == gameTitle)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.totalPendingPaise, totalPendingPaise) || other.totalPendingPaise == totalPendingPaise)&&(identical(other.unpaidCount, unpaidCount) || other.unpaidCount == unpaidCount)&&const DeepCollectionEquality().equals(other.playerDues, playerDues));
}


@override
int get hashCode => Object.hash(runtimeType,gameId,gameTitle,scheduledAt,totalPendingPaise,unpaidCount,const DeepCollectionEquality().hash(playerDues));

@override
String toString() {
  return 'GameDuesSummary(gameId: $gameId, gameTitle: $gameTitle, scheduledAt: $scheduledAt, totalPendingPaise: $totalPendingPaise, unpaidCount: $unpaidCount, playerDues: $playerDues)';
}


}

/// @nodoc
abstract mixin class $GameDuesSummaryCopyWith<$Res>  {
  factory $GameDuesSummaryCopyWith(GameDuesSummary value, $Res Function(GameDuesSummary) _then) = _$GameDuesSummaryCopyWithImpl;
@useResult
$Res call({
 String gameId, String gameTitle, DateTime scheduledAt, int totalPendingPaise, int unpaidCount, List<GamePlayerDue> playerDues
});




}
/// @nodoc
class _$GameDuesSummaryCopyWithImpl<$Res>
    implements $GameDuesSummaryCopyWith<$Res> {
  _$GameDuesSummaryCopyWithImpl(this._self, this._then);

  final GameDuesSummary _self;
  final $Res Function(GameDuesSummary) _then;

/// Create a copy of GameDuesSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gameId = null,Object? gameTitle = null,Object? scheduledAt = null,Object? totalPendingPaise = null,Object? unpaidCount = null,Object? playerDues = null,}) {
  return _then(_self.copyWith(
gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,gameTitle: null == gameTitle ? _self.gameTitle : gameTitle // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,totalPendingPaise: null == totalPendingPaise ? _self.totalPendingPaise : totalPendingPaise // ignore: cast_nullable_to_non_nullable
as int,unpaidCount: null == unpaidCount ? _self.unpaidCount : unpaidCount // ignore: cast_nullable_to_non_nullable
as int,playerDues: null == playerDues ? _self.playerDues : playerDues // ignore: cast_nullable_to_non_nullable
as List<GamePlayerDue>,
  ));
}

}


/// Adds pattern-matching-related methods to [GameDuesSummary].
extension GameDuesSummaryPatterns on GameDuesSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameDuesSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameDuesSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameDuesSummary value)  $default,){
final _that = this;
switch (_that) {
case _GameDuesSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameDuesSummary value)?  $default,){
final _that = this;
switch (_that) {
case _GameDuesSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String gameId,  String gameTitle,  DateTime scheduledAt,  int totalPendingPaise,  int unpaidCount,  List<GamePlayerDue> playerDues)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameDuesSummary() when $default != null:
return $default(_that.gameId,_that.gameTitle,_that.scheduledAt,_that.totalPendingPaise,_that.unpaidCount,_that.playerDues);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String gameId,  String gameTitle,  DateTime scheduledAt,  int totalPendingPaise,  int unpaidCount,  List<GamePlayerDue> playerDues)  $default,) {final _that = this;
switch (_that) {
case _GameDuesSummary():
return $default(_that.gameId,_that.gameTitle,_that.scheduledAt,_that.totalPendingPaise,_that.unpaidCount,_that.playerDues);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String gameId,  String gameTitle,  DateTime scheduledAt,  int totalPendingPaise,  int unpaidCount,  List<GamePlayerDue> playerDues)?  $default,) {final _that = this;
switch (_that) {
case _GameDuesSummary() when $default != null:
return $default(_that.gameId,_that.gameTitle,_that.scheduledAt,_that.totalPendingPaise,_that.unpaidCount,_that.playerDues);case _:
  return null;

}
}

}

/// @nodoc


class _GameDuesSummary implements GameDuesSummary {
  const _GameDuesSummary({required this.gameId, required this.gameTitle, required this.scheduledAt, required this.totalPendingPaise, required this.unpaidCount, required final  List<GamePlayerDue> playerDues}): _playerDues = playerDues;
  

@override final  String gameId;
@override final  String gameTitle;
@override final  DateTime scheduledAt;
@override final  int totalPendingPaise;
@override final  int unpaidCount;
 final  List<GamePlayerDue> _playerDues;
@override List<GamePlayerDue> get playerDues {
  if (_playerDues is EqualUnmodifiableListView) return _playerDues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playerDues);
}


/// Create a copy of GameDuesSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameDuesSummaryCopyWith<_GameDuesSummary> get copyWith => __$GameDuesSummaryCopyWithImpl<_GameDuesSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameDuesSummary&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.gameTitle, gameTitle) || other.gameTitle == gameTitle)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.totalPendingPaise, totalPendingPaise) || other.totalPendingPaise == totalPendingPaise)&&(identical(other.unpaidCount, unpaidCount) || other.unpaidCount == unpaidCount)&&const DeepCollectionEquality().equals(other._playerDues, _playerDues));
}


@override
int get hashCode => Object.hash(runtimeType,gameId,gameTitle,scheduledAt,totalPendingPaise,unpaidCount,const DeepCollectionEquality().hash(_playerDues));

@override
String toString() {
  return 'GameDuesSummary(gameId: $gameId, gameTitle: $gameTitle, scheduledAt: $scheduledAt, totalPendingPaise: $totalPendingPaise, unpaidCount: $unpaidCount, playerDues: $playerDues)';
}


}

/// @nodoc
abstract mixin class _$GameDuesSummaryCopyWith<$Res> implements $GameDuesSummaryCopyWith<$Res> {
  factory _$GameDuesSummaryCopyWith(_GameDuesSummary value, $Res Function(_GameDuesSummary) _then) = __$GameDuesSummaryCopyWithImpl;
@override @useResult
$Res call({
 String gameId, String gameTitle, DateTime scheduledAt, int totalPendingPaise, int unpaidCount, List<GamePlayerDue> playerDues
});




}
/// @nodoc
class __$GameDuesSummaryCopyWithImpl<$Res>
    implements _$GameDuesSummaryCopyWith<$Res> {
  __$GameDuesSummaryCopyWithImpl(this._self, this._then);

  final _GameDuesSummary _self;
  final $Res Function(_GameDuesSummary) _then;

/// Create a copy of GameDuesSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gameId = null,Object? gameTitle = null,Object? scheduledAt = null,Object? totalPendingPaise = null,Object? unpaidCount = null,Object? playerDues = null,}) {
  return _then(_GameDuesSummary(
gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,gameTitle: null == gameTitle ? _self.gameTitle : gameTitle // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,totalPendingPaise: null == totalPendingPaise ? _self.totalPendingPaise : totalPendingPaise // ignore: cast_nullable_to_non_nullable
as int,unpaidCount: null == unpaidCount ? _self.unpaidCount : unpaidCount // ignore: cast_nullable_to_non_nullable
as int,playerDues: null == playerDues ? _self._playerDues : playerDues // ignore: cast_nullable_to_non_nullable
as List<GamePlayerDue>,
  ));
}


}

/// @nodoc
mixin _$GamePlayerDue {

 String get playerId; String get playerName; String get playerEmoji; PaymentDue get due;
/// Create a copy of GamePlayerDue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GamePlayerDueCopyWith<GamePlayerDue> get copyWith => _$GamePlayerDueCopyWithImpl<GamePlayerDue>(this as GamePlayerDue, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamePlayerDue&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.playerEmoji, playerEmoji) || other.playerEmoji == playerEmoji)&&(identical(other.due, due) || other.due == due));
}


@override
int get hashCode => Object.hash(runtimeType,playerId,playerName,playerEmoji,due);

@override
String toString() {
  return 'GamePlayerDue(playerId: $playerId, playerName: $playerName, playerEmoji: $playerEmoji, due: $due)';
}


}

/// @nodoc
abstract mixin class $GamePlayerDueCopyWith<$Res>  {
  factory $GamePlayerDueCopyWith(GamePlayerDue value, $Res Function(GamePlayerDue) _then) = _$GamePlayerDueCopyWithImpl;
@useResult
$Res call({
 String playerId, String playerName, String playerEmoji, PaymentDue due
});


$PaymentDueCopyWith<$Res> get due;

}
/// @nodoc
class _$GamePlayerDueCopyWithImpl<$Res>
    implements $GamePlayerDueCopyWith<$Res> {
  _$GamePlayerDueCopyWithImpl(this._self, this._then);

  final GamePlayerDue _self;
  final $Res Function(GamePlayerDue) _then;

/// Create a copy of GamePlayerDue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? playerName = null,Object? playerEmoji = null,Object? due = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,playerEmoji: null == playerEmoji ? _self.playerEmoji : playerEmoji // ignore: cast_nullable_to_non_nullable
as String,due: null == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as PaymentDue,
  ));
}
/// Create a copy of GamePlayerDue
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentDueCopyWith<$Res> get due {
  
  return $PaymentDueCopyWith<$Res>(_self.due, (value) {
    return _then(_self.copyWith(due: value));
  });
}
}


/// Adds pattern-matching-related methods to [GamePlayerDue].
extension GamePlayerDuePatterns on GamePlayerDue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GamePlayerDue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GamePlayerDue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GamePlayerDue value)  $default,){
final _that = this;
switch (_that) {
case _GamePlayerDue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GamePlayerDue value)?  $default,){
final _that = this;
switch (_that) {
case _GamePlayerDue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  String playerName,  String playerEmoji,  PaymentDue due)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GamePlayerDue() when $default != null:
return $default(_that.playerId,_that.playerName,_that.playerEmoji,_that.due);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  String playerName,  String playerEmoji,  PaymentDue due)  $default,) {final _that = this;
switch (_that) {
case _GamePlayerDue():
return $default(_that.playerId,_that.playerName,_that.playerEmoji,_that.due);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  String playerName,  String playerEmoji,  PaymentDue due)?  $default,) {final _that = this;
switch (_that) {
case _GamePlayerDue() when $default != null:
return $default(_that.playerId,_that.playerName,_that.playerEmoji,_that.due);case _:
  return null;

}
}

}

/// @nodoc


class _GamePlayerDue implements GamePlayerDue {
  const _GamePlayerDue({required this.playerId, required this.playerName, required this.playerEmoji, required this.due});
  

@override final  String playerId;
@override final  String playerName;
@override final  String playerEmoji;
@override final  PaymentDue due;

/// Create a copy of GamePlayerDue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GamePlayerDueCopyWith<_GamePlayerDue> get copyWith => __$GamePlayerDueCopyWithImpl<_GamePlayerDue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GamePlayerDue&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.playerName, playerName) || other.playerName == playerName)&&(identical(other.playerEmoji, playerEmoji) || other.playerEmoji == playerEmoji)&&(identical(other.due, due) || other.due == due));
}


@override
int get hashCode => Object.hash(runtimeType,playerId,playerName,playerEmoji,due);

@override
String toString() {
  return 'GamePlayerDue(playerId: $playerId, playerName: $playerName, playerEmoji: $playerEmoji, due: $due)';
}


}

/// @nodoc
abstract mixin class _$GamePlayerDueCopyWith<$Res> implements $GamePlayerDueCopyWith<$Res> {
  factory _$GamePlayerDueCopyWith(_GamePlayerDue value, $Res Function(_GamePlayerDue) _then) = __$GamePlayerDueCopyWithImpl;
@override @useResult
$Res call({
 String playerId, String playerName, String playerEmoji, PaymentDue due
});


@override $PaymentDueCopyWith<$Res> get due;

}
/// @nodoc
class __$GamePlayerDueCopyWithImpl<$Res>
    implements _$GamePlayerDueCopyWith<$Res> {
  __$GamePlayerDueCopyWithImpl(this._self, this._then);

  final _GamePlayerDue _self;
  final $Res Function(_GamePlayerDue) _then;

/// Create a copy of GamePlayerDue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? playerName = null,Object? playerEmoji = null,Object? due = null,}) {
  return _then(_GamePlayerDue(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,playerName: null == playerName ? _self.playerName : playerName // ignore: cast_nullable_to_non_nullable
as String,playerEmoji: null == playerEmoji ? _self.playerEmoji : playerEmoji // ignore: cast_nullable_to_non_nullable
as String,due: null == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as PaymentDue,
  ));
}

/// Create a copy of GamePlayerDue
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentDueCopyWith<$Res> get due {
  
  return $PaymentDueCopyWith<$Res>(_self.due, (value) {
    return _then(_self.copyWith(due: value));
  });
}
}

// dart format on
