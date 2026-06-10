// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_dues_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedDuesSummary {

 int get totalPaise; int get groupCount; List<GroupDueSummary> get groupBreakdown;
/// Create a copy of FeedDuesSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedDuesSummaryCopyWith<FeedDuesSummary> get copyWith => _$FeedDuesSummaryCopyWithImpl<FeedDuesSummary>(this as FeedDuesSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedDuesSummary&&(identical(other.totalPaise, totalPaise) || other.totalPaise == totalPaise)&&(identical(other.groupCount, groupCount) || other.groupCount == groupCount)&&const DeepCollectionEquality().equals(other.groupBreakdown, groupBreakdown));
}


@override
int get hashCode => Object.hash(runtimeType,totalPaise,groupCount,const DeepCollectionEquality().hash(groupBreakdown));

@override
String toString() {
  return 'FeedDuesSummary(totalPaise: $totalPaise, groupCount: $groupCount, groupBreakdown: $groupBreakdown)';
}


}

/// @nodoc
abstract mixin class $FeedDuesSummaryCopyWith<$Res>  {
  factory $FeedDuesSummaryCopyWith(FeedDuesSummary value, $Res Function(FeedDuesSummary) _then) = _$FeedDuesSummaryCopyWithImpl;
@useResult
$Res call({
 int totalPaise, int groupCount, List<GroupDueSummary> groupBreakdown
});




}
/// @nodoc
class _$FeedDuesSummaryCopyWithImpl<$Res>
    implements $FeedDuesSummaryCopyWith<$Res> {
  _$FeedDuesSummaryCopyWithImpl(this._self, this._then);

  final FeedDuesSummary _self;
  final $Res Function(FeedDuesSummary) _then;

/// Create a copy of FeedDuesSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalPaise = null,Object? groupCount = null,Object? groupBreakdown = null,}) {
  return _then(_self.copyWith(
totalPaise: null == totalPaise ? _self.totalPaise : totalPaise // ignore: cast_nullable_to_non_nullable
as int,groupCount: null == groupCount ? _self.groupCount : groupCount // ignore: cast_nullable_to_non_nullable
as int,groupBreakdown: null == groupBreakdown ? _self.groupBreakdown : groupBreakdown // ignore: cast_nullable_to_non_nullable
as List<GroupDueSummary>,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedDuesSummary].
extension FeedDuesSummaryPatterns on FeedDuesSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedDuesSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedDuesSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedDuesSummary value)  $default,){
final _that = this;
switch (_that) {
case _FeedDuesSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedDuesSummary value)?  $default,){
final _that = this;
switch (_that) {
case _FeedDuesSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalPaise,  int groupCount,  List<GroupDueSummary> groupBreakdown)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedDuesSummary() when $default != null:
return $default(_that.totalPaise,_that.groupCount,_that.groupBreakdown);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalPaise,  int groupCount,  List<GroupDueSummary> groupBreakdown)  $default,) {final _that = this;
switch (_that) {
case _FeedDuesSummary():
return $default(_that.totalPaise,_that.groupCount,_that.groupBreakdown);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalPaise,  int groupCount,  List<GroupDueSummary> groupBreakdown)?  $default,) {final _that = this;
switch (_that) {
case _FeedDuesSummary() when $default != null:
return $default(_that.totalPaise,_that.groupCount,_that.groupBreakdown);case _:
  return null;

}
}

}

/// @nodoc


class _FeedDuesSummary implements FeedDuesSummary {
  const _FeedDuesSummary({required this.totalPaise, required this.groupCount, required final  List<GroupDueSummary> groupBreakdown}): _groupBreakdown = groupBreakdown;
  

@override final  int totalPaise;
@override final  int groupCount;
 final  List<GroupDueSummary> _groupBreakdown;
@override List<GroupDueSummary> get groupBreakdown {
  if (_groupBreakdown is EqualUnmodifiableListView) return _groupBreakdown;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groupBreakdown);
}


/// Create a copy of FeedDuesSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedDuesSummaryCopyWith<_FeedDuesSummary> get copyWith => __$FeedDuesSummaryCopyWithImpl<_FeedDuesSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedDuesSummary&&(identical(other.totalPaise, totalPaise) || other.totalPaise == totalPaise)&&(identical(other.groupCount, groupCount) || other.groupCount == groupCount)&&const DeepCollectionEquality().equals(other._groupBreakdown, _groupBreakdown));
}


@override
int get hashCode => Object.hash(runtimeType,totalPaise,groupCount,const DeepCollectionEquality().hash(_groupBreakdown));

@override
String toString() {
  return 'FeedDuesSummary(totalPaise: $totalPaise, groupCount: $groupCount, groupBreakdown: $groupBreakdown)';
}


}

/// @nodoc
abstract mixin class _$FeedDuesSummaryCopyWith<$Res> implements $FeedDuesSummaryCopyWith<$Res> {
  factory _$FeedDuesSummaryCopyWith(_FeedDuesSummary value, $Res Function(_FeedDuesSummary) _then) = __$FeedDuesSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalPaise, int groupCount, List<GroupDueSummary> groupBreakdown
});




}
/// @nodoc
class __$FeedDuesSummaryCopyWithImpl<$Res>
    implements _$FeedDuesSummaryCopyWith<$Res> {
  __$FeedDuesSummaryCopyWithImpl(this._self, this._then);

  final _FeedDuesSummary _self;
  final $Res Function(_FeedDuesSummary) _then;

/// Create a copy of FeedDuesSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalPaise = null,Object? groupCount = null,Object? groupBreakdown = null,}) {
  return _then(_FeedDuesSummary(
totalPaise: null == totalPaise ? _self.totalPaise : totalPaise // ignore: cast_nullable_to_non_nullable
as int,groupCount: null == groupCount ? _self.groupCount : groupCount // ignore: cast_nullable_to_non_nullable
as int,groupBreakdown: null == groupBreakdown ? _self._groupBreakdown : groupBreakdown // ignore: cast_nullable_to_non_nullable
as List<GroupDueSummary>,
  ));
}


}


/// @nodoc
mixin _$GroupDueSummary {

 String get groupId; int get pendingPaise; int get unpaidCount; Map<String, dynamic>? get groups;
/// Create a copy of GroupDueSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupDueSummaryCopyWith<GroupDueSummary> get copyWith => _$GroupDueSummaryCopyWithImpl<GroupDueSummary>(this as GroupDueSummary, _$identity);

  /// Serializes this GroupDueSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupDueSummary&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.pendingPaise, pendingPaise) || other.pendingPaise == pendingPaise)&&(identical(other.unpaidCount, unpaidCount) || other.unpaidCount == unpaidCount)&&const DeepCollectionEquality().equals(other.groups, groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,pendingPaise,unpaidCount,const DeepCollectionEquality().hash(groups));

@override
String toString() {
  return 'GroupDueSummary(groupId: $groupId, pendingPaise: $pendingPaise, unpaidCount: $unpaidCount, groups: $groups)';
}


}

/// @nodoc
abstract mixin class $GroupDueSummaryCopyWith<$Res>  {
  factory $GroupDueSummaryCopyWith(GroupDueSummary value, $Res Function(GroupDueSummary) _then) = _$GroupDueSummaryCopyWithImpl;
@useResult
$Res call({
 String groupId, int pendingPaise, int unpaidCount, Map<String, dynamic>? groups
});




}
/// @nodoc
class _$GroupDueSummaryCopyWithImpl<$Res>
    implements $GroupDueSummaryCopyWith<$Res> {
  _$GroupDueSummaryCopyWithImpl(this._self, this._then);

  final GroupDueSummary _self;
  final $Res Function(GroupDueSummary) _then;

/// Create a copy of GroupDueSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupId = null,Object? pendingPaise = null,Object? unpaidCount = null,Object? groups = freezed,}) {
  return _then(_self.copyWith(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,pendingPaise: null == pendingPaise ? _self.pendingPaise : pendingPaise // ignore: cast_nullable_to_non_nullable
as int,unpaidCount: null == unpaidCount ? _self.unpaidCount : unpaidCount // ignore: cast_nullable_to_non_nullable
as int,groups: freezed == groups ? _self.groups : groups // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupDueSummary].
extension GroupDueSummaryPatterns on GroupDueSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupDueSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupDueSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupDueSummary value)  $default,){
final _that = this;
switch (_that) {
case _GroupDueSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupDueSummary value)?  $default,){
final _that = this;
switch (_that) {
case _GroupDueSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String groupId,  int pendingPaise,  int unpaidCount,  Map<String, dynamic>? groups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupDueSummary() when $default != null:
return $default(_that.groupId,_that.pendingPaise,_that.unpaidCount,_that.groups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String groupId,  int pendingPaise,  int unpaidCount,  Map<String, dynamic>? groups)  $default,) {final _that = this;
switch (_that) {
case _GroupDueSummary():
return $default(_that.groupId,_that.pendingPaise,_that.unpaidCount,_that.groups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String groupId,  int pendingPaise,  int unpaidCount,  Map<String, dynamic>? groups)?  $default,) {final _that = this;
switch (_that) {
case _GroupDueSummary() when $default != null:
return $default(_that.groupId,_that.pendingPaise,_that.unpaidCount,_that.groups);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _GroupDueSummary implements GroupDueSummary {
  const _GroupDueSummary({required this.groupId, required this.pendingPaise, required this.unpaidCount, final  Map<String, dynamic>? groups}): _groups = groups;
  factory _GroupDueSummary.fromJson(Map<String, dynamic> json) => _$GroupDueSummaryFromJson(json);

@override final  String groupId;
@override final  int pendingPaise;
@override final  int unpaidCount;
 final  Map<String, dynamic>? _groups;
@override Map<String, dynamic>? get groups {
  final value = _groups;
  if (value == null) return null;
  if (_groups is EqualUnmodifiableMapView) return _groups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of GroupDueSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupDueSummaryCopyWith<_GroupDueSummary> get copyWith => __$GroupDueSummaryCopyWithImpl<_GroupDueSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupDueSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupDueSummary&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.pendingPaise, pendingPaise) || other.pendingPaise == pendingPaise)&&(identical(other.unpaidCount, unpaidCount) || other.unpaidCount == unpaidCount)&&const DeepCollectionEquality().equals(other._groups, _groups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,groupId,pendingPaise,unpaidCount,const DeepCollectionEquality().hash(_groups));

@override
String toString() {
  return 'GroupDueSummary(groupId: $groupId, pendingPaise: $pendingPaise, unpaidCount: $unpaidCount, groups: $groups)';
}


}

/// @nodoc
abstract mixin class _$GroupDueSummaryCopyWith<$Res> implements $GroupDueSummaryCopyWith<$Res> {
  factory _$GroupDueSummaryCopyWith(_GroupDueSummary value, $Res Function(_GroupDueSummary) _then) = __$GroupDueSummaryCopyWithImpl;
@override @useResult
$Res call({
 String groupId, int pendingPaise, int unpaidCount, Map<String, dynamic>? groups
});




}
/// @nodoc
class __$GroupDueSummaryCopyWithImpl<$Res>
    implements _$GroupDueSummaryCopyWith<$Res> {
  __$GroupDueSummaryCopyWithImpl(this._self, this._then);

  final _GroupDueSummary _self;
  final $Res Function(_GroupDueSummary) _then;

/// Create a copy of GroupDueSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? pendingPaise = null,Object? unpaidCount = null,Object? groups = freezed,}) {
  return _then(_GroupDueSummary(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,pendingPaise: null == pendingPaise ? _self.pendingPaise : pendingPaise // ignore: cast_nullable_to_non_nullable
as int,unpaidCount: null == unpaidCount ? _self.unpaidCount : unpaidCount // ignore: cast_nullable_to_non_nullable
as int,groups: freezed == groups ? _self._groups : groups // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
