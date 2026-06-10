// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_context_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupContextHash() => r'da7d44eebfffc2cf844ad3ca77350b5b1a78c796';

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

/// See also [groupContext].
@ProviderFor(groupContext)
const groupContextProvider = GroupContextFamily();

/// See also [groupContext].
class GroupContextFamily extends Family<AsyncValue<GroupContext>> {
  /// See also [groupContext].
  const GroupContextFamily();

  /// See also [groupContext].
  GroupContextProvider call(String groupId) {
    return GroupContextProvider(groupId);
  }

  @override
  GroupContextProvider getProviderOverride(
    covariant GroupContextProvider provider,
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
  String? get name => r'groupContextProvider';
}

/// See also [groupContext].
class GroupContextProvider extends AutoDisposeFutureProvider<GroupContext> {
  /// See also [groupContext].
  GroupContextProvider(String groupId)
    : this._internal(
        (ref) => groupContext(ref as GroupContextRef, groupId),
        from: groupContextProvider,
        name: r'groupContextProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupContextHash,
        dependencies: GroupContextFamily._dependencies,
        allTransitiveDependencies:
            GroupContextFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupContextProvider._internal(
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
  Override overrideWith(
    FutureOr<GroupContext> Function(GroupContextRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupContextProvider._internal(
        (ref) => create(ref as GroupContextRef),
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
  AutoDisposeFutureProviderElement<GroupContext> createElement() {
    return _GroupContextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupContextProvider && other.groupId == groupId;
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
mixin GroupContextRef on AutoDisposeFutureProviderRef<GroupContext> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupContextProviderElement
    extends AutoDisposeFutureProviderElement<GroupContext>
    with GroupContextRef {
  _GroupContextProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupContextProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
