// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuditLog {

 String get id;@JsonKey(name: 'group_id') String get groupId;@JsonKey(name: 'actor_id') String? get actorId;@JsonKey(name: 'target_id') String? get targetId; AuditAction get action; Map<String, dynamic>? get metadata;@JsonKey(name: 'created_at') DateTime get createdAt; Map<String, dynamic>? get actor; Map<String, dynamic>? get target;
/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogCopyWith<AuditLog> get copyWith => _$AuditLogCopyWithImpl<AuditLog>(this as AuditLog, _$identity);

  /// Serializes this AuditLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLog&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.action, action) || other.action == action)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.actor, actor)&&const DeepCollectionEquality().equals(other.target, target));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,actorId,targetId,action,const DeepCollectionEquality().hash(metadata),createdAt,const DeepCollectionEquality().hash(actor),const DeepCollectionEquality().hash(target));

@override
String toString() {
  return 'AuditLog(id: $id, groupId: $groupId, actorId: $actorId, targetId: $targetId, action: $action, metadata: $metadata, createdAt: $createdAt, actor: $actor, target: $target)';
}


}

/// @nodoc
abstract mixin class $AuditLogCopyWith<$Res>  {
  factory $AuditLogCopyWith(AuditLog value, $Res Function(AuditLog) _then) = _$AuditLogCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'group_id') String groupId,@JsonKey(name: 'actor_id') String? actorId,@JsonKey(name: 'target_id') String? targetId, AuditAction action, Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') DateTime createdAt, Map<String, dynamic>? actor, Map<String, dynamic>? target
});




}
/// @nodoc
class _$AuditLogCopyWithImpl<$Res>
    implements $AuditLogCopyWith<$Res> {
  _$AuditLogCopyWithImpl(this._self, this._then);

  final AuditLog _self;
  final $Res Function(AuditLog) _then;

/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? actorId = freezed,Object? targetId = freezed,Object? action = null,Object? metadata = freezed,Object? createdAt = null,Object? actor = freezed,Object? target = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,actorId: freezed == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String?,targetId: freezed == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as AuditAction,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,target: freezed == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLog].
extension AuditLogPatterns on AuditLog {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLog value)  $default,){
final _that = this;
switch (_that) {
case _AuditLog():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLog value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'group_id')  String groupId, @JsonKey(name: 'actor_id')  String? actorId, @JsonKey(name: 'target_id')  String? targetId,  AuditAction action,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt,  Map<String, dynamic>? actor,  Map<String, dynamic>? target)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that.id,_that.groupId,_that.actorId,_that.targetId,_that.action,_that.metadata,_that.createdAt,_that.actor,_that.target);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'group_id')  String groupId, @JsonKey(name: 'actor_id')  String? actorId, @JsonKey(name: 'target_id')  String? targetId,  AuditAction action,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt,  Map<String, dynamic>? actor,  Map<String, dynamic>? target)  $default,) {final _that = this;
switch (_that) {
case _AuditLog():
return $default(_that.id,_that.groupId,_that.actorId,_that.targetId,_that.action,_that.metadata,_that.createdAt,_that.actor,_that.target);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'group_id')  String groupId, @JsonKey(name: 'actor_id')  String? actorId, @JsonKey(name: 'target_id')  String? targetId,  AuditAction action,  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at')  DateTime createdAt,  Map<String, dynamic>? actor,  Map<String, dynamic>? target)?  $default,) {final _that = this;
switch (_that) {
case _AuditLog() when $default != null:
return $default(_that.id,_that.groupId,_that.actorId,_that.targetId,_that.action,_that.metadata,_that.createdAt,_that.actor,_that.target);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditLog implements AuditLog {
  const _AuditLog({required this.id, @JsonKey(name: 'group_id') required this.groupId, @JsonKey(name: 'actor_id') this.actorId, @JsonKey(name: 'target_id') this.targetId, required this.action, final  Map<String, dynamic>? metadata, @JsonKey(name: 'created_at') required this.createdAt, final  Map<String, dynamic>? actor, final  Map<String, dynamic>? target}): _metadata = metadata,_actor = actor,_target = target;
  factory _AuditLog.fromJson(Map<String, dynamic> json) => _$AuditLogFromJson(json);

@override final  String id;
@override@JsonKey(name: 'group_id') final  String groupId;
@override@JsonKey(name: 'actor_id') final  String? actorId;
@override@JsonKey(name: 'target_id') final  String? targetId;
@override final  AuditAction action;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'created_at') final  DateTime createdAt;
 final  Map<String, dynamic>? _actor;
@override Map<String, dynamic>? get actor {
  final value = _actor;
  if (value == null) return null;
  if (_actor is EqualUnmodifiableMapView) return _actor;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _target;
@override Map<String, dynamic>? get target {
  final value = _target;
  if (value == null) return null;
  if (_target is EqualUnmodifiableMapView) return _target;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogCopyWith<_AuditLog> get copyWith => __$AuditLogCopyWithImpl<_AuditLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLog&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.action, action) || other.action == action)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._actor, _actor)&&const DeepCollectionEquality().equals(other._target, _target));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,actorId,targetId,action,const DeepCollectionEquality().hash(_metadata),createdAt,const DeepCollectionEquality().hash(_actor),const DeepCollectionEquality().hash(_target));

@override
String toString() {
  return 'AuditLog(id: $id, groupId: $groupId, actorId: $actorId, targetId: $targetId, action: $action, metadata: $metadata, createdAt: $createdAt, actor: $actor, target: $target)';
}


}

/// @nodoc
abstract mixin class _$AuditLogCopyWith<$Res> implements $AuditLogCopyWith<$Res> {
  factory _$AuditLogCopyWith(_AuditLog value, $Res Function(_AuditLog) _then) = __$AuditLogCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'group_id') String groupId,@JsonKey(name: 'actor_id') String? actorId,@JsonKey(name: 'target_id') String? targetId, AuditAction action, Map<String, dynamic>? metadata,@JsonKey(name: 'created_at') DateTime createdAt, Map<String, dynamic>? actor, Map<String, dynamic>? target
});




}
/// @nodoc
class __$AuditLogCopyWithImpl<$Res>
    implements _$AuditLogCopyWith<$Res> {
  __$AuditLogCopyWithImpl(this._self, this._then);

  final _AuditLog _self;
  final $Res Function(_AuditLog) _then;

/// Create a copy of AuditLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? actorId = freezed,Object? targetId = freezed,Object? action = null,Object? metadata = freezed,Object? createdAt = null,Object? actor = freezed,Object? target = freezed,}) {
  return _then(_AuditLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,actorId: freezed == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String?,targetId: freezed == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String?,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as AuditAction,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,actor: freezed == actor ? _self._actor : actor // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,target: freezed == target ? _self._target : target // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
