// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemberStats {

 String get userId; String get groupId; int get gamesPlayed; double get attendancePct;// 0.0 to 100.0
 DateTime? get joinedAt; List<MonthlyParticipation> get monthlyData;
/// Create a copy of MemberStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberStatsCopyWith<MemberStats> get copyWith => _$MemberStatsCopyWithImpl<MemberStats>(this as MemberStats, _$identity);

  /// Serializes this MemberStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberStats&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.gamesPlayed, gamesPlayed) || other.gamesPlayed == gamesPlayed)&&(identical(other.attendancePct, attendancePct) || other.attendancePct == attendancePct)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&const DeepCollectionEquality().equals(other.monthlyData, monthlyData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,groupId,gamesPlayed,attendancePct,joinedAt,const DeepCollectionEquality().hash(monthlyData));

@override
String toString() {
  return 'MemberStats(userId: $userId, groupId: $groupId, gamesPlayed: $gamesPlayed, attendancePct: $attendancePct, joinedAt: $joinedAt, monthlyData: $monthlyData)';
}


}

/// @nodoc
abstract mixin class $MemberStatsCopyWith<$Res>  {
  factory $MemberStatsCopyWith(MemberStats value, $Res Function(MemberStats) _then) = _$MemberStatsCopyWithImpl;
@useResult
$Res call({
 String userId, String groupId, int gamesPlayed, double attendancePct, DateTime? joinedAt, List<MonthlyParticipation> monthlyData
});




}
/// @nodoc
class _$MemberStatsCopyWithImpl<$Res>
    implements $MemberStatsCopyWith<$Res> {
  _$MemberStatsCopyWithImpl(this._self, this._then);

  final MemberStats _self;
  final $Res Function(MemberStats) _then;

/// Create a copy of MemberStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? groupId = null,Object? gamesPlayed = null,Object? attendancePct = null,Object? joinedAt = freezed,Object? monthlyData = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,gamesPlayed: null == gamesPlayed ? _self.gamesPlayed : gamesPlayed // ignore: cast_nullable_to_non_nullable
as int,attendancePct: null == attendancePct ? _self.attendancePct : attendancePct // ignore: cast_nullable_to_non_nullable
as double,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,monthlyData: null == monthlyData ? _self.monthlyData : monthlyData // ignore: cast_nullable_to_non_nullable
as List<MonthlyParticipation>,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberStats].
extension MemberStatsPatterns on MemberStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberStats value)  $default,){
final _that = this;
switch (_that) {
case _MemberStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberStats value)?  $default,){
final _that = this;
switch (_that) {
case _MemberStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String groupId,  int gamesPlayed,  double attendancePct,  DateTime? joinedAt,  List<MonthlyParticipation> monthlyData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberStats() when $default != null:
return $default(_that.userId,_that.groupId,_that.gamesPlayed,_that.attendancePct,_that.joinedAt,_that.monthlyData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String groupId,  int gamesPlayed,  double attendancePct,  DateTime? joinedAt,  List<MonthlyParticipation> monthlyData)  $default,) {final _that = this;
switch (_that) {
case _MemberStats():
return $default(_that.userId,_that.groupId,_that.gamesPlayed,_that.attendancePct,_that.joinedAt,_that.monthlyData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String groupId,  int gamesPlayed,  double attendancePct,  DateTime? joinedAt,  List<MonthlyParticipation> monthlyData)?  $default,) {final _that = this;
switch (_that) {
case _MemberStats() when $default != null:
return $default(_that.userId,_that.groupId,_that.gamesPlayed,_that.attendancePct,_that.joinedAt,_that.monthlyData);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MemberStats implements MemberStats {
  const _MemberStats({required this.userId, required this.groupId, required this.gamesPlayed, required this.attendancePct, required this.joinedAt, required final  List<MonthlyParticipation> monthlyData}): _monthlyData = monthlyData;
  factory _MemberStats.fromJson(Map<String, dynamic> json) => _$MemberStatsFromJson(json);

@override final  String userId;
@override final  String groupId;
@override final  int gamesPlayed;
@override final  double attendancePct;
// 0.0 to 100.0
@override final  DateTime? joinedAt;
 final  List<MonthlyParticipation> _monthlyData;
@override List<MonthlyParticipation> get monthlyData {
  if (_monthlyData is EqualUnmodifiableListView) return _monthlyData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_monthlyData);
}


/// Create a copy of MemberStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberStatsCopyWith<_MemberStats> get copyWith => __$MemberStatsCopyWithImpl<_MemberStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberStats&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.gamesPlayed, gamesPlayed) || other.gamesPlayed == gamesPlayed)&&(identical(other.attendancePct, attendancePct) || other.attendancePct == attendancePct)&&(identical(other.joinedAt, joinedAt) || other.joinedAt == joinedAt)&&const DeepCollectionEquality().equals(other._monthlyData, _monthlyData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,groupId,gamesPlayed,attendancePct,joinedAt,const DeepCollectionEquality().hash(_monthlyData));

@override
String toString() {
  return 'MemberStats(userId: $userId, groupId: $groupId, gamesPlayed: $gamesPlayed, attendancePct: $attendancePct, joinedAt: $joinedAt, monthlyData: $monthlyData)';
}


}

/// @nodoc
abstract mixin class _$MemberStatsCopyWith<$Res> implements $MemberStatsCopyWith<$Res> {
  factory _$MemberStatsCopyWith(_MemberStats value, $Res Function(_MemberStats) _then) = __$MemberStatsCopyWithImpl;
@override @useResult
$Res call({
 String userId, String groupId, int gamesPlayed, double attendancePct, DateTime? joinedAt, List<MonthlyParticipation> monthlyData
});




}
/// @nodoc
class __$MemberStatsCopyWithImpl<$Res>
    implements _$MemberStatsCopyWith<$Res> {
  __$MemberStatsCopyWithImpl(this._self, this._then);

  final _MemberStats _self;
  final $Res Function(_MemberStats) _then;

/// Create a copy of MemberStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? groupId = null,Object? gamesPlayed = null,Object? attendancePct = null,Object? joinedAt = freezed,Object? monthlyData = null,}) {
  return _then(_MemberStats(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,gamesPlayed: null == gamesPlayed ? _self.gamesPlayed : gamesPlayed // ignore: cast_nullable_to_non_nullable
as int,attendancePct: null == attendancePct ? _self.attendancePct : attendancePct // ignore: cast_nullable_to_non_nullable
as double,joinedAt: freezed == joinedAt ? _self.joinedAt : joinedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,monthlyData: null == monthlyData ? _self._monthlyData : monthlyData // ignore: cast_nullable_to_non_nullable
as List<MonthlyParticipation>,
  ));
}


}


/// @nodoc
mixin _$MonthlyParticipation {

 int get year; int get month; int get gamesPlayed;
/// Create a copy of MonthlyParticipation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyParticipationCopyWith<MonthlyParticipation> get copyWith => _$MonthlyParticipationCopyWithImpl<MonthlyParticipation>(this as MonthlyParticipation, _$identity);

  /// Serializes this MonthlyParticipation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyParticipation&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.gamesPlayed, gamesPlayed) || other.gamesPlayed == gamesPlayed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,month,gamesPlayed);

@override
String toString() {
  return 'MonthlyParticipation(year: $year, month: $month, gamesPlayed: $gamesPlayed)';
}


}

/// @nodoc
abstract mixin class $MonthlyParticipationCopyWith<$Res>  {
  factory $MonthlyParticipationCopyWith(MonthlyParticipation value, $Res Function(MonthlyParticipation) _then) = _$MonthlyParticipationCopyWithImpl;
@useResult
$Res call({
 int year, int month, int gamesPlayed
});




}
/// @nodoc
class _$MonthlyParticipationCopyWithImpl<$Res>
    implements $MonthlyParticipationCopyWith<$Res> {
  _$MonthlyParticipationCopyWithImpl(this._self, this._then);

  final MonthlyParticipation _self;
  final $Res Function(MonthlyParticipation) _then;

/// Create a copy of MonthlyParticipation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? month = null,Object? gamesPlayed = null,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,gamesPlayed: null == gamesPlayed ? _self.gamesPlayed : gamesPlayed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyParticipation].
extension MonthlyParticipationPatterns on MonthlyParticipation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyParticipation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyParticipation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyParticipation value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyParticipation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyParticipation value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyParticipation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  int month,  int gamesPlayed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyParticipation() when $default != null:
return $default(_that.year,_that.month,_that.gamesPlayed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  int month,  int gamesPlayed)  $default,) {final _that = this;
switch (_that) {
case _MonthlyParticipation():
return $default(_that.year,_that.month,_that.gamesPlayed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  int month,  int gamesPlayed)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyParticipation() when $default != null:
return $default(_that.year,_that.month,_that.gamesPlayed);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MonthlyParticipation implements MonthlyParticipation {
  const _MonthlyParticipation({required this.year, required this.month, required this.gamesPlayed});
  factory _MonthlyParticipation.fromJson(Map<String, dynamic> json) => _$MonthlyParticipationFromJson(json);

@override final  int year;
@override final  int month;
@override final  int gamesPlayed;

/// Create a copy of MonthlyParticipation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyParticipationCopyWith<_MonthlyParticipation> get copyWith => __$MonthlyParticipationCopyWithImpl<_MonthlyParticipation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyParticipationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyParticipation&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.gamesPlayed, gamesPlayed) || other.gamesPlayed == gamesPlayed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,month,gamesPlayed);

@override
String toString() {
  return 'MonthlyParticipation(year: $year, month: $month, gamesPlayed: $gamesPlayed)';
}


}

/// @nodoc
abstract mixin class _$MonthlyParticipationCopyWith<$Res> implements $MonthlyParticipationCopyWith<$Res> {
  factory _$MonthlyParticipationCopyWith(_MonthlyParticipation value, $Res Function(_MonthlyParticipation) _then) = __$MonthlyParticipationCopyWithImpl;
@override @useResult
$Res call({
 int year, int month, int gamesPlayed
});




}
/// @nodoc
class __$MonthlyParticipationCopyWithImpl<$Res>
    implements _$MonthlyParticipationCopyWith<$Res> {
  __$MonthlyParticipationCopyWithImpl(this._self, this._then);

  final _MonthlyParticipation _self;
  final $Res Function(_MonthlyParticipation) _then;

/// Create a copy of MonthlyParticipation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? month = null,Object? gamesPlayed = null,}) {
  return _then(_MonthlyParticipation(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,gamesPlayed: null == gamesPlayed ? _self.gamesPlayed : gamesPlayed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
