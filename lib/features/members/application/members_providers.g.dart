// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupMembersHash() => r'54275bb2b78a48c02ceeb13da52f8d25b2c3f938';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$GroupMembers
    extends BuildlessAutoDisposeAsyncNotifier<List<GroupMember>> {
  late final String groupId;

  FutureOr<List<GroupMember>> build(String groupId);
}

/// See also [GroupMembers].
@ProviderFor(GroupMembers)
const groupMembersProvider = GroupMembersFamily();

/// See also [GroupMembers].
class GroupMembersFamily extends Family<AsyncValue<List<GroupMember>>> {
  /// See also [GroupMembers].
  const GroupMembersFamily();

  /// See also [GroupMembers].
  GroupMembersProvider call(String groupId) {
    return GroupMembersProvider(groupId);
  }

  @override
  GroupMembersProvider getProviderOverride(
    covariant GroupMembersProvider provider,
  ) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupMembersProvider';
}

/// See also [GroupMembers].
class GroupMembersProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<GroupMembers, List<GroupMember>> {
  /// See also [GroupMembers].
  GroupMembersProvider(String groupId)
    : this._internal(
        () => GroupMembers()..groupId = groupId,
        from: groupMembersProvider,
        name: r'groupMembersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupMembersHash,
        dependencies: GroupMembersFamily._dependencies,
        allTransitiveDependencies:
            GroupMembersFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  FutureOr<List<GroupMember>> runNotifierBuild(
    covariant GroupMembers notifier,
  ) {
    return notifier.build(groupId);
  }

  @override
  Override overrideWith(GroupMembers Function() create) {
    return ProviderOverride(
      origin: this,
      override: GroupMembersProvider._internal(
        () => create()..groupId = groupId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<GroupMembers, List<GroupMember>>
  createElement() {
    return _GroupMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMembersProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupMembersRef
    on AutoDisposeAsyncNotifierProviderRef<List<GroupMember>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupMembersProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<GroupMembers, List<GroupMember>>
    with GroupMembersRef {
  _GroupMembersProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupMembersProvider).groupId;
}

String _$groupJoinRequestsHash() => r'd25938b334c5829a897bf82d72d8b877fdffbf6d';

abstract class _$GroupJoinRequests
    extends BuildlessAutoDisposeAsyncNotifier<List<GroupMember>> {
  late final String groupId;

  FutureOr<List<GroupMember>> build(String groupId);
}

/// See also [GroupJoinRequests].
@ProviderFor(GroupJoinRequests)
const groupJoinRequestsProvider = GroupJoinRequestsFamily();

/// See also [GroupJoinRequests].
class GroupJoinRequestsFamily extends Family<AsyncValue<List<GroupMember>>> {
  /// See also [GroupJoinRequests].
  const GroupJoinRequestsFamily();

  /// See also [GroupJoinRequests].
  GroupJoinRequestsProvider call(String groupId) {
    return GroupJoinRequestsProvider(groupId);
  }

  @override
  GroupJoinRequestsProvider getProviderOverride(
    covariant GroupJoinRequestsProvider provider,
  ) {
    return call(provider.groupId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupJoinRequestsProvider';
}

/// See also [GroupJoinRequests].
class GroupJoinRequestsProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          GroupJoinRequests,
          List<GroupMember>
        > {
  /// See also [GroupJoinRequests].
  GroupJoinRequestsProvider(String groupId)
    : this._internal(
        () => GroupJoinRequests()..groupId = groupId,
        from: groupJoinRequestsProvider,
        name: r'groupJoinRequestsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupJoinRequestsHash,
        dependencies: GroupJoinRequestsFamily._dependencies,
        allTransitiveDependencies:
            GroupJoinRequestsFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupJoinRequestsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  FutureOr<List<GroupMember>> runNotifierBuild(
    covariant GroupJoinRequests notifier,
  ) {
    return notifier.build(groupId);
  }

  @override
  Override overrideWith(GroupJoinRequests Function() create) {
    return ProviderOverride(
      origin: this,
      override: GroupJoinRequestsProvider._internal(
        () => create()..groupId = groupId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<GroupJoinRequests, List<GroupMember>>
  createElement() {
    return _GroupJoinRequestsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupJoinRequestsProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GroupJoinRequestsRef
    on AutoDisposeAsyncNotifierProviderRef<List<GroupMember>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupJoinRequestsProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          GroupJoinRequests,
          List<GroupMember>
        >
    with GroupJoinRequestsRef {
  _GroupJoinRequestsProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupJoinRequestsProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
