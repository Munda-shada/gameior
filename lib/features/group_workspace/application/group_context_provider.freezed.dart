// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_context_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GroupContext {

 Group get group; MemberRole get myRole; MembershipStatus get myStatus; String get inviteCode;
/// Create a copy of GroupContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupContextCopyWith<GroupContext> get copyWith => _$GroupContextCopyWithImpl<GroupContext>(this as GroupContext, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupContext&&(identical(other.group, group) || other.group == group)&&(identical(other.myRole, myRole) || other.myRole == myRole)&&(identical(other.myStatus, myStatus) || other.myStatus == myStatus)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode));
}


@override
int get hashCode => Object.hash(runtimeType,group,myRole,myStatus,inviteCode);

@override
String toString() {
  return 'GroupContext(group: $group, myRole: $myRole, myStatus: $myStatus, inviteCode: $inviteCode)';
}


}

/// @nodoc
abstract mixin class $GroupContextCopyWith<$Res>  {
  factory $GroupContextCopyWith(GroupContext value, $Res Function(GroupContext) _then) = _$GroupContextCopyWithImpl;
@useResult
$Res call({
 Group group, MemberRole myRole, MembershipStatus myStatus, String inviteCode
});


$GroupCopyWith<$Res> get group;

}
/// @nodoc
class _$GroupContextCopyWithImpl<$Res>
    implements $GroupContextCopyWith<$Res> {
  _$GroupContextCopyWithImpl(this._self, this._then);

  final GroupContext _self;
  final $Res Function(GroupContext) _then;

/// Create a copy of GroupContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? group = null,Object? myRole = null,Object? myStatus = null,Object? inviteCode = null,}) {
  return _then(_self.copyWith(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group,myRole: null == myRole ? _self.myRole : myRole // ignore: cast_nullable_to_non_nullable
as MemberRole,myStatus: null == myStatus ? _self.myStatus : myStatus // ignore: cast_nullable_to_non_nullable
as MembershipStatus,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of GroupContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupCopyWith<$Res> get group {
  
  return $GroupCopyWith<$Res>(_self.group, (value) {
    return _then(_self.copyWith(group: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupContext].
extension GroupContextPatterns on GroupContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupContext value)  $default,){
final _that = this;
switch (_that) {
case _GroupContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupContext value)?  $default,){
final _that = this;
switch (_that) {
case _GroupContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Group group,  MemberRole myRole,  MembershipStatus myStatus,  String inviteCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupContext() when $default != null:
return $default(_that.group,_that.myRole,_that.myStatus,_that.inviteCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Group group,  MemberRole myRole,  MembershipStatus myStatus,  String inviteCode)  $default,) {final _that = this;
switch (_that) {
case _GroupContext():
return $default(_that.group,_that.myRole,_that.myStatus,_that.inviteCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Group group,  MemberRole myRole,  MembershipStatus myStatus,  String inviteCode)?  $default,) {final _that = this;
switch (_that) {
case _GroupContext() when $default != null:
return $default(_that.group,_that.myRole,_that.myStatus,_that.inviteCode);case _:
  return null;

}
}

}

/// @nodoc


class _GroupContext implements GroupContext {
  const _GroupContext({required this.group, required this.myRole, required this.myStatus, required this.inviteCode});
  

@override final  Group group;
@override final  MemberRole myRole;
@override final  MembershipStatus myStatus;
@override final  String inviteCode;

/// Create a copy of GroupContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupContextCopyWith<_GroupContext> get copyWith => __$GroupContextCopyWithImpl<_GroupContext>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupContext&&(identical(other.group, group) || other.group == group)&&(identical(other.myRole, myRole) || other.myRole == myRole)&&(identical(other.myStatus, myStatus) || other.myStatus == myStatus)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode));
}


@override
int get hashCode => Object.hash(runtimeType,group,myRole,myStatus,inviteCode);

@override
String toString() {
  return 'GroupContext(group: $group, myRole: $myRole, myStatus: $myStatus, inviteCode: $inviteCode)';
}


}

/// @nodoc
abstract mixin class _$GroupContextCopyWith<$Res> implements $GroupContextCopyWith<$Res> {
  factory _$GroupContextCopyWith(_GroupContext value, $Res Function(_GroupContext) _then) = __$GroupContextCopyWithImpl;
@override @useResult
$Res call({
 Group group, MemberRole myRole, MembershipStatus myStatus, String inviteCode
});


@override $GroupCopyWith<$Res> get group;

}
/// @nodoc
class __$GroupContextCopyWithImpl<$Res>
    implements _$GroupContextCopyWith<$Res> {
  __$GroupContextCopyWithImpl(this._self, this._then);

  final _GroupContext _self;
  final $Res Function(_GroupContext) _then;

/// Create a copy of GroupContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? group = null,Object? myRole = null,Object? myStatus = null,Object? inviteCode = null,}) {
  return _then(_GroupContext(
group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as Group,myRole: null == myRole ? _self.myRole : myRole // ignore: cast_nullable_to_non_nullable
as MemberRole,myStatus: null == myStatus ? _self.myStatus : myStatus // ignore: cast_nullable_to_non_nullable
as MembershipStatus,inviteCode: null == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of GroupContext
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupCopyWith<$Res> get group {
  
  return $GroupCopyWith<$Res>(_self.group, (value) {
    return _then(_self.copyWith(group: value));
  });
}
}

// dart format on
