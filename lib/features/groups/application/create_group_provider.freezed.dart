// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_group_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateGroupFormState {

 int get currentStep;// Step 1
 String get name; SportType? get sport; String get description;// Step 2
 String get defaultVenue; String get mapsLink;// Step 3
 int get maxCapacity; PaymentModel get paymentModel; int get defaultCostPaise; String get defaultUpiId; String get clubRules;// Step 4
 bool get requireApproval; bool get allowMemberInvites; bool get allowGuests;// Submission
 bool get isSubmitting; String? get error;
/// Create a copy of CreateGroupFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateGroupFormStateCopyWith<CreateGroupFormState> get copyWith => _$CreateGroupFormStateCopyWithImpl<CreateGroupFormState>(this as CreateGroupFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateGroupFormState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.name, name) || other.name == name)&&(identical(other.sport, sport) || other.sport == sport)&&(identical(other.description, description) || other.description == description)&&(identical(other.defaultVenue, defaultVenue) || other.defaultVenue == defaultVenue)&&(identical(other.mapsLink, mapsLink) || other.mapsLink == mapsLink)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.paymentModel, paymentModel) || other.paymentModel == paymentModel)&&(identical(other.defaultCostPaise, defaultCostPaise) || other.defaultCostPaise == defaultCostPaise)&&(identical(other.defaultUpiId, defaultUpiId) || other.defaultUpiId == defaultUpiId)&&(identical(other.clubRules, clubRules) || other.clubRules == clubRules)&&(identical(other.requireApproval, requireApproval) || other.requireApproval == requireApproval)&&(identical(other.allowMemberInvites, allowMemberInvites) || other.allowMemberInvites == allowMemberInvites)&&(identical(other.allowGuests, allowGuests) || other.allowGuests == allowGuests)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,name,sport,description,defaultVenue,mapsLink,maxCapacity,paymentModel,defaultCostPaise,defaultUpiId,clubRules,requireApproval,allowMemberInvites,allowGuests,isSubmitting,error);

@override
String toString() {
  return 'CreateGroupFormState(currentStep: $currentStep, name: $name, sport: $sport, description: $description, defaultVenue: $defaultVenue, mapsLink: $mapsLink, maxCapacity: $maxCapacity, paymentModel: $paymentModel, defaultCostPaise: $defaultCostPaise, defaultUpiId: $defaultUpiId, clubRules: $clubRules, requireApproval: $requireApproval, allowMemberInvites: $allowMemberInvites, allowGuests: $allowGuests, isSubmitting: $isSubmitting, error: $error)';
}


}

/// @nodoc
abstract mixin class $CreateGroupFormStateCopyWith<$Res>  {
  factory $CreateGroupFormStateCopyWith(CreateGroupFormState value, $Res Function(CreateGroupFormState) _then) = _$CreateGroupFormStateCopyWithImpl;
@useResult
$Res call({
 int currentStep, String name, SportType? sport, String description, String defaultVenue, String mapsLink, int maxCapacity, PaymentModel paymentModel, int defaultCostPaise, String defaultUpiId, String clubRules, bool requireApproval, bool allowMemberInvites, bool allowGuests, bool isSubmitting, String? error
});




}
/// @nodoc
class _$CreateGroupFormStateCopyWithImpl<$Res>
    implements $CreateGroupFormStateCopyWith<$Res> {
  _$CreateGroupFormStateCopyWithImpl(this._self, this._then);

  final CreateGroupFormState _self;
  final $Res Function(CreateGroupFormState) _then;

/// Create a copy of CreateGroupFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentStep = null,Object? name = null,Object? sport = freezed,Object? description = null,Object? defaultVenue = null,Object? mapsLink = null,Object? maxCapacity = null,Object? paymentModel = null,Object? defaultCostPaise = null,Object? defaultUpiId = null,Object? clubRules = null,Object? requireApproval = null,Object? allowMemberInvites = null,Object? allowGuests = null,Object? isSubmitting = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sport: freezed == sport ? _self.sport : sport // ignore: cast_nullable_to_non_nullable
as SportType?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,defaultVenue: null == defaultVenue ? _self.defaultVenue : defaultVenue // ignore: cast_nullable_to_non_nullable
as String,mapsLink: null == mapsLink ? _self.mapsLink : mapsLink // ignore: cast_nullable_to_non_nullable
as String,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,paymentModel: null == paymentModel ? _self.paymentModel : paymentModel // ignore: cast_nullable_to_non_nullable
as PaymentModel,defaultCostPaise: null == defaultCostPaise ? _self.defaultCostPaise : defaultCostPaise // ignore: cast_nullable_to_non_nullable
as int,defaultUpiId: null == defaultUpiId ? _self.defaultUpiId : defaultUpiId // ignore: cast_nullable_to_non_nullable
as String,clubRules: null == clubRules ? _self.clubRules : clubRules // ignore: cast_nullable_to_non_nullable
as String,requireApproval: null == requireApproval ? _self.requireApproval : requireApproval // ignore: cast_nullable_to_non_nullable
as bool,allowMemberInvites: null == allowMemberInvites ? _self.allowMemberInvites : allowMemberInvites // ignore: cast_nullable_to_non_nullable
as bool,allowGuests: null == allowGuests ? _self.allowGuests : allowGuests // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateGroupFormState].
extension CreateGroupFormStatePatterns on CreateGroupFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateGroupFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateGroupFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateGroupFormState value)  $default,){
final _that = this;
switch (_that) {
case _CreateGroupFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateGroupFormState value)?  $default,){
final _that = this;
switch (_that) {
case _CreateGroupFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int currentStep,  String name,  SportType? sport,  String description,  String defaultVenue,  String mapsLink,  int maxCapacity,  PaymentModel paymentModel,  int defaultCostPaise,  String defaultUpiId,  String clubRules,  bool requireApproval,  bool allowMemberInvites,  bool allowGuests,  bool isSubmitting,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateGroupFormState() when $default != null:
return $default(_that.currentStep,_that.name,_that.sport,_that.description,_that.defaultVenue,_that.mapsLink,_that.maxCapacity,_that.paymentModel,_that.defaultCostPaise,_that.defaultUpiId,_that.clubRules,_that.requireApproval,_that.allowMemberInvites,_that.allowGuests,_that.isSubmitting,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int currentStep,  String name,  SportType? sport,  String description,  String defaultVenue,  String mapsLink,  int maxCapacity,  PaymentModel paymentModel,  int defaultCostPaise,  String defaultUpiId,  String clubRules,  bool requireApproval,  bool allowMemberInvites,  bool allowGuests,  bool isSubmitting,  String? error)  $default,) {final _that = this;
switch (_that) {
case _CreateGroupFormState():
return $default(_that.currentStep,_that.name,_that.sport,_that.description,_that.defaultVenue,_that.mapsLink,_that.maxCapacity,_that.paymentModel,_that.defaultCostPaise,_that.defaultUpiId,_that.clubRules,_that.requireApproval,_that.allowMemberInvites,_that.allowGuests,_that.isSubmitting,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int currentStep,  String name,  SportType? sport,  String description,  String defaultVenue,  String mapsLink,  int maxCapacity,  PaymentModel paymentModel,  int defaultCostPaise,  String defaultUpiId,  String clubRules,  bool requireApproval,  bool allowMemberInvites,  bool allowGuests,  bool isSubmitting,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _CreateGroupFormState() when $default != null:
return $default(_that.currentStep,_that.name,_that.sport,_that.description,_that.defaultVenue,_that.mapsLink,_that.maxCapacity,_that.paymentModel,_that.defaultCostPaise,_that.defaultUpiId,_that.clubRules,_that.requireApproval,_that.allowMemberInvites,_that.allowGuests,_that.isSubmitting,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CreateGroupFormState implements CreateGroupFormState {
  const _CreateGroupFormState({this.currentStep = 1, this.name = '', this.sport, this.description = '', this.defaultVenue = '', this.mapsLink = '', this.maxCapacity = 20, this.paymentModel = PaymentModel.prepaid, this.defaultCostPaise = 0, this.defaultUpiId = '', this.clubRules = '', this.requireApproval = true, this.allowMemberInvites = true, this.allowGuests = true, this.isSubmitting = false, this.error});
  

@override@JsonKey() final  int currentStep;
// Step 1
@override@JsonKey() final  String name;
@override final  SportType? sport;
@override@JsonKey() final  String description;
// Step 2
@override@JsonKey() final  String defaultVenue;
@override@JsonKey() final  String mapsLink;
// Step 3
@override@JsonKey() final  int maxCapacity;
@override@JsonKey() final  PaymentModel paymentModel;
@override@JsonKey() final  int defaultCostPaise;
@override@JsonKey() final  String defaultUpiId;
@override@JsonKey() final  String clubRules;
// Step 4
@override@JsonKey() final  bool requireApproval;
@override@JsonKey() final  bool allowMemberInvites;
@override@JsonKey() final  bool allowGuests;
// Submission
@override@JsonKey() final  bool isSubmitting;
@override final  String? error;

/// Create a copy of CreateGroupFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateGroupFormStateCopyWith<_CreateGroupFormState> get copyWith => __$CreateGroupFormStateCopyWithImpl<_CreateGroupFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateGroupFormState&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.name, name) || other.name == name)&&(identical(other.sport, sport) || other.sport == sport)&&(identical(other.description, description) || other.description == description)&&(identical(other.defaultVenue, defaultVenue) || other.defaultVenue == defaultVenue)&&(identical(other.mapsLink, mapsLink) || other.mapsLink == mapsLink)&&(identical(other.maxCapacity, maxCapacity) || other.maxCapacity == maxCapacity)&&(identical(other.paymentModel, paymentModel) || other.paymentModel == paymentModel)&&(identical(other.defaultCostPaise, defaultCostPaise) || other.defaultCostPaise == defaultCostPaise)&&(identical(other.defaultUpiId, defaultUpiId) || other.defaultUpiId == defaultUpiId)&&(identical(other.clubRules, clubRules) || other.clubRules == clubRules)&&(identical(other.requireApproval, requireApproval) || other.requireApproval == requireApproval)&&(identical(other.allowMemberInvites, allowMemberInvites) || other.allowMemberInvites == allowMemberInvites)&&(identical(other.allowGuests, allowGuests) || other.allowGuests == allowGuests)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,currentStep,name,sport,description,defaultVenue,mapsLink,maxCapacity,paymentModel,defaultCostPaise,defaultUpiId,clubRules,requireApproval,allowMemberInvites,allowGuests,isSubmitting,error);

@override
String toString() {
  return 'CreateGroupFormState(currentStep: $currentStep, name: $name, sport: $sport, description: $description, defaultVenue: $defaultVenue, mapsLink: $mapsLink, maxCapacity: $maxCapacity, paymentModel: $paymentModel, defaultCostPaise: $defaultCostPaise, defaultUpiId: $defaultUpiId, clubRules: $clubRules, requireApproval: $requireApproval, allowMemberInvites: $allowMemberInvites, allowGuests: $allowGuests, isSubmitting: $isSubmitting, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CreateGroupFormStateCopyWith<$Res> implements $CreateGroupFormStateCopyWith<$Res> {
  factory _$CreateGroupFormStateCopyWith(_CreateGroupFormState value, $Res Function(_CreateGroupFormState) _then) = __$CreateGroupFormStateCopyWithImpl;
@override @useResult
$Res call({
 int currentStep, String name, SportType? sport, String description, String defaultVenue, String mapsLink, int maxCapacity, PaymentModel paymentModel, int defaultCostPaise, String defaultUpiId, String clubRules, bool requireApproval, bool allowMemberInvites, bool allowGuests, bool isSubmitting, String? error
});




}
/// @nodoc
class __$CreateGroupFormStateCopyWithImpl<$Res>
    implements _$CreateGroupFormStateCopyWith<$Res> {
  __$CreateGroupFormStateCopyWithImpl(this._self, this._then);

  final _CreateGroupFormState _self;
  final $Res Function(_CreateGroupFormState) _then;

/// Create a copy of CreateGroupFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentStep = null,Object? name = null,Object? sport = freezed,Object? description = null,Object? defaultVenue = null,Object? mapsLink = null,Object? maxCapacity = null,Object? paymentModel = null,Object? defaultCostPaise = null,Object? defaultUpiId = null,Object? clubRules = null,Object? requireApproval = null,Object? allowMemberInvites = null,Object? allowGuests = null,Object? isSubmitting = null,Object? error = freezed,}) {
  return _then(_CreateGroupFormState(
currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sport: freezed == sport ? _self.sport : sport // ignore: cast_nullable_to_non_nullable
as SportType?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,defaultVenue: null == defaultVenue ? _self.defaultVenue : defaultVenue // ignore: cast_nullable_to_non_nullable
as String,mapsLink: null == mapsLink ? _self.mapsLink : mapsLink // ignore: cast_nullable_to_non_nullable
as String,maxCapacity: null == maxCapacity ? _self.maxCapacity : maxCapacity // ignore: cast_nullable_to_non_nullable
as int,paymentModel: null == paymentModel ? _self.paymentModel : paymentModel // ignore: cast_nullable_to_non_nullable
as PaymentModel,defaultCostPaise: null == defaultCostPaise ? _self.defaultCostPaise : defaultCostPaise // ignore: cast_nullable_to_non_nullable
as int,defaultUpiId: null == defaultUpiId ? _self.defaultUpiId : defaultUpiId // ignore: cast_nullable_to_non_nullable
as String,clubRules: null == clubRules ? _self.clubRules : clubRules // ignore: cast_nullable_to_non_nullable
as String,requireApproval: null == requireApproval ? _self.requireApproval : requireApproval // ignore: cast_nullable_to_non_nullable
as bool,allowMemberInvites: null == allowMemberInvites ? _self.allowMemberInvites : allowMemberInvites // ignore: cast_nullable_to_non_nullable
as bool,allowGuests: null == allowGuests ? _self.allowGuests : allowGuests // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
