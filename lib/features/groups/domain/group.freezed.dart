// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Group {

 String get id; String get name; String? get description; SportType get sport; String get hostId; String? get defaultVenue; int? get maxCapacity; PaymentModel get paymentModel; int get defaultCostPaise; String? get defaultUpiId; String? get clubRules; bool get allowMemberInvites; bool get autoApproveJoins; bool get allowGuests; bool get showCostBreakdown; bool get autoApprovePayments; DateTime get createdAt;
/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupCopyWith<Group> get copyWith => _$GroupCopyWithImpl<Group>(this as Group, _$identity);

  /// Serializes this Group to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Group&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.sport, sport) || other.sport == sport)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.defaultVenue, defaultVenue) || other.defaultVenue == defaultVenue)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.paymentModel, paymentModel) || other.paymentModel == paymentModel)&&(identical(other.defaultCostPaise, defaultCostPaise) || other.defaultCostPaise == defaultCostPaise)&&(identical(other.defaultUpiId, defaultUpiId) || other.defaultUpiId == defaultUpiId)&&(identical(other.clubRules, clubRules) || other.clubRules == clubRules)&&(identical(other.allowMemberInvites, allowMemberInvites) || other.allowMemberInvites == allowMemberInvites)&&(identical(other.autoApproveJoins, autoApproveJoins) || other.autoApproveJoins == autoApproveJoins)&&(identical(other.allowGuests, allowGuests) || other.allowGuests == allowGuests)&&(identical(other.showCostBreakdown, showCostBreakdown) || other.showCostBreakdown == showCostBreakdown)&&(identical(other.autoApprovePayments, autoApprovePayments) || other.autoApprovePayments == autoApprovePayments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,sport,hostId,defaultVenue,maxCapacity,paymentModel,defaultCostPaise,defaultUpiId,clubRules,allowMemberInvites,autoApproveJoins,allowGuests,showCostBreakdown,autoApprovePayments,createdAt);

@override
String toString() {
  return 'Group(id: $id, name: $name, description: $description, sport: $sport, hostId: $hostId, defaultVenue: $defaultVenue, maxCapacity: $maxCapacity, paymentModel: $paymentModel, defaultCostPaise: $defaultCostPaise, defaultUpiId: $defaultUpiId, clubRules: $clubRules, allowMemberInvites: $allowMemberInvites, autoApproveJoins: $autoApproveJoins, allowGuests: $allowGuests, showCostBreakdown: $showCostBreakdown, autoApprovePayments: $autoApprovePayments, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $GroupCopyWith<$Res>  {
  factory $GroupCopyWith(Group value, $Res Function(Group) _then) = _$GroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, SportType sport, String hostId, String? defaultVenue, int? maxCapacity, PaymentModel paymentModel, int defaultCostPaise, String? defaultUpiId, String? clubRules, bool allowMemberInvites, bool autoApproveJoins, bool allowGuests, bool showCostBreakdown, bool autoApprovePayments, DateTime createdAt
});




}
/// @nodoc
class _$GroupCopyWithImpl<$Res>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._self, this._then);

  final Group _self;
  final $Res Function(Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? sport = null,Object? hostId = null,Object? defaultVenue = freezed,Object? maxCapacity = freezed,Object? paymentModel = null,Object? defaultCostPaise = null,Object? defaultUpiId = freezed,Object? clubRules = freezed,Object? allowMemberInvites = null,Object? autoApproveJoins = null,Object? allowGuests = null,Object? showCostBreakdown = null,Object? autoApprovePayments = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,sport: null == sport ? _self.sport : sport // ignore: cast_nullable_to_non_nullable
as SportType,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,defaultVenue: freezed == defaultVenue ? _self.defaultVenue : defaultVenue // ignore: cast_nullable_to_non_nullable
as String?,maxCapacity: freezed == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int?,paymentModel: null == paymentModel ? _self.paymentModel : paymentModel // ignore: cast_nullable_to_non_nullable
as PaymentModel,defaultCostPaise: null == defaultCostPaise ? _self.defaultCostPaise : defaultCostPaise // ignore: cast_nullable_to_non_nullable
as int,defaultUpiId: freezed == defaultUpiId ? _self.defaultUpiId : defaultUpiId // ignore: cast_nullable_to_non_nullable
as String?,clubRules: freezed == clubRules ? _self.clubRules : clubRules // ignore: cast_nullable_to_non_nullable
as String?,allowMemberInvites: null == allowMemberInvites ? _self.allowMemberInvites : allowMemberInvites // ignore: cast_nullable_to_non_nullable
as bool,autoApproveJoins: null == autoApproveJoins ? _self.autoApproveJoins : autoApproveJoins // ignore: cast_nullable_to_non_nullable
as bool,allowGuests: null == allowGuests ? _self.allowGuests : allowGuests // ignore: cast_nullable_to_non_nullable
as bool,showCostBreakdown: null == showCostBreakdown ? _self.showCostBreakdown : showCostBreakdown // ignore: cast_nullable_to_non_nullable
as bool,autoApprovePayments: null == autoApprovePayments ? _self.autoApprovePayments : autoApprovePayments // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Group].
extension GroupPatterns on Group {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Group value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Group value)  $default,){
final _that = this;
switch (_that) {
case _Group():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Group value)?  $default,){
final _that = this;
switch (_that) {
case _Group() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  SportType sport,  String hostId,  String? defaultVenue,  int? maxCapacity,  PaymentModel paymentModel,  int defaultCostPaise,  String? defaultUpiId,  String? clubRules,  bool allowMemberInvites,  bool autoApproveJoins,  bool allowGuests,  bool showCostBreakdown,  bool autoApprovePayments,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.sport,_that.hostId,_that.defaultVenue,_that.maxCapacity,_that.paymentModel,_that.defaultCostPaise,_that.defaultUpiId,_that.clubRules,_that.allowMemberInvites,_that.autoApproveJoins,_that.allowGuests,_that.showCostBreakdown,_that.autoApprovePayments,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  SportType sport,  String hostId,  String? defaultVenue,  int? maxCapacity,  PaymentModel paymentModel,  int defaultCostPaise,  String? defaultUpiId,  String? clubRules,  bool allowMemberInvites,  bool autoApproveJoins,  bool allowGuests,  bool showCostBreakdown,  bool autoApprovePayments,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Group():
return $default(_that.id,_that.name,_that.description,_that.sport,_that.hostId,_that.defaultVenue,_that.maxCapacity,_that.paymentModel,_that.defaultCostPaise,_that.defaultUpiId,_that.clubRules,_that.allowMemberInvites,_that.autoApproveJoins,_that.allowGuests,_that.showCostBreakdown,_that.autoApprovePayments,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  SportType sport,  String hostId,  String? defaultVenue,  int? maxCapacity,  PaymentModel paymentModel,  int defaultCostPaise,  String? defaultUpiId,  String? clubRules,  bool allowMemberInvites,  bool autoApproveJoins,  bool allowGuests,  bool showCostBreakdown,  bool autoApprovePayments,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.sport,_that.hostId,_that.defaultVenue,_that.maxCapacity,_that.paymentModel,_that.defaultCostPaise,_that.defaultUpiId,_that.clubRules,_that.allowMemberInvites,_that.autoApproveJoins,_that.allowGuests,_that.showCostBreakdown,_that.autoApprovePayments,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Group implements Group {
  const _Group({required this.id, required this.name, this.description, required this.sport, required this.hostId, this.defaultVenue, this.maxCapacity, required this.paymentModel, required this.defaultCostPaise, this.defaultUpiId, this.clubRules, required this.allowMemberInvites, required this.autoApproveJoins, required this.allowGuests, required this.showCostBreakdown, required this.autoApprovePayments, required this.createdAt});
  factory _Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  SportType sport;
@override final  String hostId;
@override final  String? defaultVenue;
@override final  int? maxCapacity;
@override final  PaymentModel paymentModel;
@override final  int defaultCostPaise;
@override final  String? defaultUpiId;
@override final  String? clubRules;
@override final  bool allowMemberInvites;
@override final  bool autoApproveJoins;
@override final  bool allowGuests;
@override final  bool showCostBreakdown;
@override final  bool autoApprovePayments;
@override final  DateTime createdAt;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupCopyWith<_Group> get copyWith => __$GroupCopyWithImpl<_Group>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Group&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.sport, sport) || other.sport == sport)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.defaultVenue, defaultVenue) || other.defaultVenue == defaultVenue)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.paymentModel, paymentModel) || other.paymentModel == paymentModel)&&(identical(other.defaultCostPaise, defaultCostPaise) || other.defaultCostPaise == defaultCostPaise)&&(identical(other.defaultUpiId, defaultUpiId) || other.defaultUpiId == defaultUpiId)&&(identical(other.clubRules, clubRules) || other.clubRules == clubRules)&&(identical(other.allowMemberInvites, allowMemberInvites) || other.allowMemberInvites == allowMemberInvites)&&(identical(other.autoApproveJoins, autoApproveJoins) || other.autoApproveJoins == autoApproveJoins)&&(identical(other.allowGuests, allowGuests) || other.allowGuests == allowGuests)&&(identical(other.showCostBreakdown, showCostBreakdown) || other.showCostBreakdown == showCostBreakdown)&&(identical(other.autoApprovePayments, autoApprovePayments) || other.autoApprovePayments == autoApprovePayments)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,sport,hostId,defaultVenue,maxCapacity,paymentModel,defaultCostPaise,defaultUpiId,clubRules,allowMemberInvites,autoApproveJoins,allowGuests,showCostBreakdown,autoApprovePayments,createdAt);

@override
String toString() {
  return 'Group(id: $id, name: $name, description: $description, sport: $sport, hostId: $hostId, defaultVenue: $defaultVenue, maxCapacity: $maxCapacity, paymentModel: $paymentModel, defaultCostPaise: $defaultCostPaise, defaultUpiId: $defaultUpiId, clubRules: $clubRules, allowMemberInvites: $allowMemberInvites, autoApproveJoins: $autoApproveJoins, allowGuests: $allowGuests, showCostBreakdown: $showCostBreakdown, autoApprovePayments: $autoApprovePayments, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$GroupCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$GroupCopyWith(_Group value, $Res Function(_Group) _then) = __$GroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, SportType sport, String hostId, String? defaultVenue, int? maxCapacity, PaymentModel paymentModel, int defaultCostPaise, String? defaultUpiId, String? clubRules, bool allowMemberInvites, bool autoApproveJoins, bool allowGuests, bool showCostBreakdown, bool autoApprovePayments, DateTime createdAt
});




}
/// @nodoc
class __$GroupCopyWithImpl<$Res>
    implements _$GroupCopyWith<$Res> {
  __$GroupCopyWithImpl(this._self, this._then);

  final _Group _self;
  final $Res Function(_Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? sport = null,Object? hostId = null,Object? defaultVenue = freezed,Object? maxCapacity = freezed,Object? paymentModel = null,Object? defaultCostPaise = null,Object? defaultUpiId = freezed,Object? clubRules = freezed,Object? allowMemberInvites = null,Object? autoApproveJoins = null,Object? allowGuests = null,Object? showCostBreakdown = null,Object? autoApprovePayments = null,Object? createdAt = null,}) {
  return _then(_Group(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,sport: null == sport ? _self.sport : sport // ignore: cast_nullable_to_non_nullable
as SportType,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as String,defaultVenue: freezed == defaultVenue ? _self.defaultVenue : defaultVenue // ignore: cast_nullable_to_non_nullable
as String?,maxCapacity: freezed == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int?,paymentModel: null == paymentModel ? _self.paymentModel : paymentModel // ignore: cast_nullable_to_non_nullable
as PaymentModel,defaultCostPaise: null == defaultCostPaise ? _self.defaultCostPaise : defaultCostPaise // ignore: cast_nullable_to_non_nullable
as int,defaultUpiId: freezed == defaultUpiId ? _self.defaultUpiId : defaultUpiId // ignore: cast_nullable_to_non_nullable
as String?,clubRules: freezed == clubRules ? _self.clubRules : clubRules // ignore: cast_nullable_to_non_nullable
as String?,allowMemberInvites: null == allowMemberInvites ? _self.allowMemberInvites : allowMemberInvites // ignore: cast_nullable_to_non_nullable
as bool,autoApproveJoins: null == autoApproveJoins ? _self.autoApproveJoins : autoApproveJoins // ignore: cast_nullable_to_non_nullable
as bool,allowGuests: null == allowGuests ? _self.allowGuests : allowGuests // ignore: cast_nullable_to_non_nullable
as bool,showCostBreakdown: null == showCostBreakdown ? _self.showCostBreakdown : showCostBreakdown // ignore: cast_nullable_to_non_nullable
as bool,autoApprovePayments: null == autoApprovePayments ? _self.autoApprovePayments : autoApprovePayments // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$GroupSummary {

 String get id; String get name; SportType get sport; MemberRole get myRole; MembershipStatus get myStatus; int get memberCount; int get pendingDuesPaise;// player view
 int get pendingFromPlayersPaise;// admin view
 bool get hasUpcomingSessions;
/// Create a copy of GroupSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupSummaryCopyWith<GroupSummary> get copyWith => _$GroupSummaryCopyWithImpl<GroupSummary>(this as GroupSummary, _$identity);

  /// Serializes this GroupSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sport, sport) || other.sport == sport)&&(identical(other.myRole, myRole) || other.myRole == myRole)&&(identical(other.myStatus, myStatus) || other.myStatus == myStatus)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.pendingDuesPaise, pendingDuesPaise) || other.pendingDuesPaise == pendingDuesPaise)&&(identical(other.pendingFromPlayersPaise, pendingFromPlayersPaise) || other.pendingFromPlayersPaise == pendingFromPlayersPaise)&&(identical(other.hasUpcomingSessions, hasUpcomingSessions) || other.hasUpcomingSessions == hasUpcomingSessions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sport,myRole,myStatus,memberCount,pendingDuesPaise,pendingFromPlayersPaise,hasUpcomingSessions);

@override
String toString() {
  return 'GroupSummary(id: $id, name: $name, sport: $sport, myRole: $myRole, myStatus: $myStatus, memberCount: $memberCount, pendingDuesPaise: $pendingDuesPaise, pendingFromPlayersPaise: $pendingFromPlayersPaise, hasUpcomingSessions: $hasUpcomingSessions)';
}


}

/// @nodoc
abstract mixin class $GroupSummaryCopyWith<$Res>  {
  factory $GroupSummaryCopyWith(GroupSummary value, $Res Function(GroupSummary) _then) = _$GroupSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, SportType sport, MemberRole myRole, MembershipStatus myStatus, int memberCount, int pendingDuesPaise, int pendingFromPlayersPaise, bool hasUpcomingSessions
});




}
/// @nodoc
class _$GroupSummaryCopyWithImpl<$Res>
    implements $GroupSummaryCopyWith<$Res> {
  _$GroupSummaryCopyWithImpl(this._self, this._then);

  final GroupSummary _self;
  final $Res Function(GroupSummary) _then;

/// Create a copy of GroupSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? sport = null,Object? myRole = null,Object? myStatus = null,Object? memberCount = null,Object? pendingDuesPaise = null,Object? pendingFromPlayersPaise = null,Object? hasUpcomingSessions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sport: null == sport ? _self.sport : sport // ignore: cast_nullable_to_non_nullable
as SportType,myRole: null == myRole ? _self.myRole : myRole // ignore: cast_nullable_to_non_nullable
as MemberRole,myStatus: null == myStatus ? _self.myStatus : myStatus // ignore: cast_nullable_to_non_nullable
as MembershipStatus,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,pendingDuesPaise: null == pendingDuesPaise ? _self.pendingDuesPaise : pendingDuesPaise // ignore: cast_nullable_to_non_nullable
as int,pendingFromPlayersPaise: null == pendingFromPlayersPaise ? _self.pendingFromPlayersPaise : pendingFromPlayersPaise // ignore: cast_nullable_to_non_nullable
as int,hasUpcomingSessions: null == hasUpcomingSessions ? _self.hasUpcomingSessions : hasUpcomingSessions // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupSummary].
extension GroupSummaryPatterns on GroupSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupSummary value)  $default,){
final _that = this;
switch (_that) {
case _GroupSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupSummary value)?  $default,){
final _that = this;
switch (_that) {
case _GroupSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  SportType sport,  MemberRole myRole,  MembershipStatus myStatus,  int memberCount,  int pendingDuesPaise,  int pendingFromPlayersPaise,  bool hasUpcomingSessions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupSummary() when $default != null:
return $default(_that.id,_that.name,_that.sport,_that.myRole,_that.myStatus,_that.memberCount,_that.pendingDuesPaise,_that.pendingFromPlayersPaise,_that.hasUpcomingSessions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  SportType sport,  MemberRole myRole,  MembershipStatus myStatus,  int memberCount,  int pendingDuesPaise,  int pendingFromPlayersPaise,  bool hasUpcomingSessions)  $default,) {final _that = this;
switch (_that) {
case _GroupSummary():
return $default(_that.id,_that.name,_that.sport,_that.myRole,_that.myStatus,_that.memberCount,_that.pendingDuesPaise,_that.pendingFromPlayersPaise,_that.hasUpcomingSessions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  SportType sport,  MemberRole myRole,  MembershipStatus myStatus,  int memberCount,  int pendingDuesPaise,  int pendingFromPlayersPaise,  bool hasUpcomingSessions)?  $default,) {final _that = this;
switch (_that) {
case _GroupSummary() when $default != null:
return $default(_that.id,_that.name,_that.sport,_that.myRole,_that.myStatus,_that.memberCount,_that.pendingDuesPaise,_that.pendingFromPlayersPaise,_that.hasUpcomingSessions);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _GroupSummary implements GroupSummary {
  const _GroupSummary({required this.id, required this.name, required this.sport, required this.myRole, required this.myStatus, required this.memberCount, required this.pendingDuesPaise, required this.pendingFromPlayersPaise, required this.hasUpcomingSessions});
  factory _GroupSummary.fromJson(Map<String, dynamic> json) => _$GroupSummaryFromJson(json);

@override final  String id;
@override final  String name;
@override final  SportType sport;
@override final  MemberRole myRole;
@override final  MembershipStatus myStatus;
@override final  int memberCount;
@override final  int pendingDuesPaise;
// player view
@override final  int pendingFromPlayersPaise;
// admin view
@override final  bool hasUpcomingSessions;

/// Create a copy of GroupSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupSummaryCopyWith<_GroupSummary> get copyWith => __$GroupSummaryCopyWithImpl<_GroupSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GroupSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.sport, sport) || other.sport == sport)&&(identical(other.myRole, myRole) || other.myRole == myRole)&&(identical(other.myStatus, myStatus) || other.myStatus == myStatus)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.pendingDuesPaise, pendingDuesPaise) || other.pendingDuesPaise == pendingDuesPaise)&&(identical(other.pendingFromPlayersPaise, pendingFromPlayersPaise) || other.pendingFromPlayersPaise == pendingFromPlayersPaise)&&(identical(other.hasUpcomingSessions, hasUpcomingSessions) || other.hasUpcomingSessions == hasUpcomingSessions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,sport,myRole,myStatus,memberCount,pendingDuesPaise,pendingFromPlayersPaise,hasUpcomingSessions);

@override
String toString() {
  return 'GroupSummary(id: $id, name: $name, sport: $sport, myRole: $myRole, myStatus: $myStatus, memberCount: $memberCount, pendingDuesPaise: $pendingDuesPaise, pendingFromPlayersPaise: $pendingFromPlayersPaise, hasUpcomingSessions: $hasUpcomingSessions)';
}


}

/// @nodoc
abstract mixin class _$GroupSummaryCopyWith<$Res> implements $GroupSummaryCopyWith<$Res> {
  factory _$GroupSummaryCopyWith(_GroupSummary value, $Res Function(_GroupSummary) _then) = __$GroupSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, SportType sport, MemberRole myRole, MembershipStatus myStatus, int memberCount, int pendingDuesPaise, int pendingFromPlayersPaise, bool hasUpcomingSessions
});




}
/// @nodoc
class __$GroupSummaryCopyWithImpl<$Res>
    implements _$GroupSummaryCopyWith<$Res> {
  __$GroupSummaryCopyWithImpl(this._self, this._then);

  final _GroupSummary _self;
  final $Res Function(_GroupSummary) _then;

/// Create a copy of GroupSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? sport = null,Object? myRole = null,Object? myStatus = null,Object? memberCount = null,Object? pendingDuesPaise = null,Object? pendingFromPlayersPaise = null,Object? hasUpcomingSessions = null,}) {
  return _then(_GroupSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sport: null == sport ? _self.sport : sport // ignore: cast_nullable_to_non_nullable
as SportType,myRole: null == myRole ? _self.myRole : myRole // ignore: cast_nullable_to_non_nullable
as MemberRole,myStatus: null == myStatus ? _self.myStatus : myStatus // ignore: cast_nullable_to_non_nullable
as MembershipStatus,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,pendingDuesPaise: null == pendingDuesPaise ? _self.pendingDuesPaise : pendingDuesPaise // ignore: cast_nullable_to_non_nullable
as int,pendingFromPlayersPaise: null == pendingFromPlayersPaise ? _self.pendingFromPlayersPaise : pendingFromPlayersPaise // ignore: cast_nullable_to_non_nullable
as int,hasUpcomingSessions: null == hasUpcomingSessions ? _self.hasUpcomingSessions : hasUpcomingSessions // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
