// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$nextGroupGameHash() => r'947b8c95e7d2865a65825f4d593f42c7fbb937d7';

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

/// See also [nextGroupGame].
@ProviderFor(nextGroupGame)
const nextGroupGameProvider = NextGroupGameFamily();

/// See also [nextGroupGame].
class NextGroupGameFamily extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [nextGroupGame].
  const NextGroupGameFamily();

  /// See also [nextGroupGame].
  NextGroupGameProvider call(String groupId) {
    return NextGroupGameProvider(groupId);
  }

  @override
  NextGroupGameProvider getProviderOverride(
    covariant NextGroupGameProvider provider,
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
  String? get name => r'nextGroupGameProvider';
}

/// See also [nextGroupGame].
class NextGroupGameProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>?> {
  /// See also [nextGroupGame].
  NextGroupGameProvider(String groupId)
    : this._internal(
        (ref) => nextGroupGame(ref as NextGroupGameRef, groupId),
        from: nextGroupGameProvider,
        name: r'nextGroupGameProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$nextGroupGameHash,
        dependencies: NextGroupGameFamily._dependencies,
        allTransitiveDependencies:
            NextGroupGameFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  NextGroupGameProvider._internal(
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
    FutureOr<Map<String, dynamic>?> Function(NextGroupGameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NextGroupGameProvider._internal(
        (ref) => create(ref as NextGroupGameRef),
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
  AutoDisposeFutureProviderElement<Map<String, dynamic>?> createElement() {
    return _NextGroupGameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NextGroupGameProvider && other.groupId == groupId;
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
mixin NextGroupGameRef on AutoDisposeFutureProviderRef<Map<String, dynamic>?> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _NextGroupGameProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>?>
    with NextGroupGameRef {
  _NextGroupGameProviderElement(super.provider);

  @override
  String get groupId => (origin as NextGroupGameProvider).groupId;
}

String _$playerDuesHash() => r'07093b07364554cd24b726e5e479116565a5e6dd';

/// See also [playerDues].
@ProviderFor(playerDues)
const playerDuesProvider = PlayerDuesFamily();

/// See also [playerDues].
class PlayerDuesFamily extends Family<AsyncValue<int>> {
  /// See also [playerDues].
  const PlayerDuesFamily();

  /// See also [playerDues].
  PlayerDuesProvider call(String groupId) {
    return PlayerDuesProvider(groupId);
  }

  @override
  PlayerDuesProvider getProviderOverride(
    covariant PlayerDuesProvider provider,
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
  String? get name => r'playerDuesProvider';
}

/// See also [playerDues].
class PlayerDuesProvider extends AutoDisposeFutureProvider<int> {
  /// See also [playerDues].
  PlayerDuesProvider(String groupId)
    : this._internal(
        (ref) => playerDues(ref as PlayerDuesRef, groupId),
        from: playerDuesProvider,
        name: r'playerDuesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$playerDuesHash,
        dependencies: PlayerDuesFamily._dependencies,
        allTransitiveDependencies: PlayerDuesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  PlayerDuesProvider._internal(
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
  Override overrideWith(FutureOr<int> Function(PlayerDuesRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: PlayerDuesProvider._internal(
        (ref) => create(ref as PlayerDuesRef),
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
  AutoDisposeFutureProviderElement<int> createElement() {
    return _PlayerDuesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerDuesProvider && other.groupId == groupId;
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
mixin PlayerDuesRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _PlayerDuesProviderElement extends AutoDisposeFutureProviderElement<int>
    with PlayerDuesRef {
  _PlayerDuesProviderElement(super.provider);

  @override
  String get groupId => (origin as PlayerDuesProvider).groupId;
}

String _$adminDuesHash() => r'ae7117a5ffbc4f50aec39288f93882776a6dbb95';

/// See also [adminDues].
@ProviderFor(adminDues)
const adminDuesProvider = AdminDuesFamily();

/// See also [adminDues].
class AdminDuesFamily extends Family<AsyncValue<int>> {
  /// See also [adminDues].
  const AdminDuesFamily();

  /// See also [adminDues].
  AdminDuesProvider call(String groupId) {
    return AdminDuesProvider(groupId);
  }

  @override
  AdminDuesProvider getProviderOverride(covariant AdminDuesProvider provider) {
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
  String? get name => r'adminDuesProvider';
}

/// See also [adminDues].
class AdminDuesProvider extends AutoDisposeFutureProvider<int> {
  /// See also [adminDues].
  AdminDuesProvider(String groupId)
    : this._internal(
        (ref) => adminDues(ref as AdminDuesRef, groupId),
        from: adminDuesProvider,
        name: r'adminDuesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminDuesHash,
        dependencies: AdminDuesFamily._dependencies,
        allTransitiveDependencies: AdminDuesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  AdminDuesProvider._internal(
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
  Override overrideWith(FutureOr<int> Function(AdminDuesRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: AdminDuesProvider._internal(
        (ref) => create(ref as AdminDuesRef),
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
  AutoDisposeFutureProviderElement<int> createElement() {
    return _AdminDuesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminDuesProvider && other.groupId == groupId;
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
mixin AdminDuesRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _AdminDuesProviderElement extends AutoDisposeFutureProviderElement<int>
    with AdminDuesRef {
  _AdminDuesProviderElement(super.provider);

  @override
  String get groupId => (origin as AdminDuesProvider).groupId;
}

String _$groupAnnouncementsHash() =>
    r'df66032351f6aab57247a6cc7da5dc001c25dd52';

/// See also [groupAnnouncements].
@ProviderFor(groupAnnouncements)
const groupAnnouncementsProvider = GroupAnnouncementsFamily();

/// See also [groupAnnouncements].
class GroupAnnouncementsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [groupAnnouncements].
  const GroupAnnouncementsFamily();

  /// See also [groupAnnouncements].
  GroupAnnouncementsProvider call(String groupId) {
    return GroupAnnouncementsProvider(groupId);
  }

  @override
  GroupAnnouncementsProvider getProviderOverride(
    covariant GroupAnnouncementsProvider provider,
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
  String? get name => r'groupAnnouncementsProvider';
}

/// See also [groupAnnouncements].
class GroupAnnouncementsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [groupAnnouncements].
  GroupAnnouncementsProvider(String groupId)
    : this._internal(
        (ref) => groupAnnouncements(ref as GroupAnnouncementsRef, groupId),
        from: groupAnnouncementsProvider,
        name: r'groupAnnouncementsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupAnnouncementsHash,
        dependencies: GroupAnnouncementsFamily._dependencies,
        allTransitiveDependencies:
            GroupAnnouncementsFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupAnnouncementsProvider._internal(
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
    FutureOr<List<Map<String, dynamic>>> Function(
      GroupAnnouncementsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupAnnouncementsProvider._internal(
        (ref) => create(ref as GroupAnnouncementsRef),
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
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _GroupAnnouncementsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupAnnouncementsProvider && other.groupId == groupId;
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
mixin GroupAnnouncementsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupAnnouncementsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with GroupAnnouncementsRef {
  _GroupAnnouncementsProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupAnnouncementsProvider).groupId;
}

String _$groupUpcomingGamesHash() =>
    r'54d618c5d0005f73901df6cdcb07e479c9636c23';

/// See also [groupUpcomingGames].
@ProviderFor(groupUpcomingGames)
const groupUpcomingGamesProvider = GroupUpcomingGamesFamily();

/// See also [groupUpcomingGames].
class GroupUpcomingGamesFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [groupUpcomingGames].
  const GroupUpcomingGamesFamily();

  /// See also [groupUpcomingGames].
  GroupUpcomingGamesProvider call(String groupId) {
    return GroupUpcomingGamesProvider(groupId);
  }

  @override
  GroupUpcomingGamesProvider getProviderOverride(
    covariant GroupUpcomingGamesProvider provider,
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
  String? get name => r'groupUpcomingGamesProvider';
}

/// See also [groupUpcomingGames].
class GroupUpcomingGamesProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [groupUpcomingGames].
  GroupUpcomingGamesProvider(String groupId)
    : this._internal(
        (ref) => groupUpcomingGames(ref as GroupUpcomingGamesRef, groupId),
        from: groupUpcomingGamesProvider,
        name: r'groupUpcomingGamesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$groupUpcomingGamesHash,
        dependencies: GroupUpcomingGamesFamily._dependencies,
        allTransitiveDependencies:
            GroupUpcomingGamesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  GroupUpcomingGamesProvider._internal(
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
    FutureOr<List<Map<String, dynamic>>> Function(
      GroupUpcomingGamesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupUpcomingGamesProvider._internal(
        (ref) => create(ref as GroupUpcomingGamesRef),
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
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _GroupUpcomingGamesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupUpcomingGamesProvider && other.groupId == groupId;
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
mixin GroupUpcomingGamesRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupUpcomingGamesProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with GroupUpcomingGamesRef {
  _GroupUpcomingGamesProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupUpcomingGamesProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
