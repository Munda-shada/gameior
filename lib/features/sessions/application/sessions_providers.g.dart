// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$upcomingGamesHash() => r'b5db5e97be28132bd54a6b35a9fac04cf5b7d0ed';

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

/// See also [upcomingGames].
@ProviderFor(upcomingGames)
const upcomingGamesProvider = UpcomingGamesFamily();

/// See also [upcomingGames].
class UpcomingGamesFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [upcomingGames].
  const UpcomingGamesFamily();

  /// See also [upcomingGames].
  UpcomingGamesProvider call(String groupId) {
    return UpcomingGamesProvider(groupId);
  }

  @override
  UpcomingGamesProvider getProviderOverride(
    covariant UpcomingGamesProvider provider,
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
  String? get name => r'upcomingGamesProvider';
}

/// See also [upcomingGames].
class UpcomingGamesProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [upcomingGames].
  UpcomingGamesProvider(String groupId)
    : this._internal(
        (ref) => upcomingGames(ref as UpcomingGamesRef, groupId),
        from: upcomingGamesProvider,
        name: r'upcomingGamesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$upcomingGamesHash,
        dependencies: UpcomingGamesFamily._dependencies,
        allTransitiveDependencies:
            UpcomingGamesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  UpcomingGamesProvider._internal(
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
    FutureOr<List<Map<String, dynamic>>> Function(UpcomingGamesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpcomingGamesProvider._internal(
        (ref) => create(ref as UpcomingGamesRef),
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
    return _UpcomingGamesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpcomingGamesProvider && other.groupId == groupId;
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
mixin UpcomingGamesRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _UpcomingGamesProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with UpcomingGamesRef {
  _UpcomingGamesProviderElement(super.provider);

  @override
  String get groupId => (origin as UpcomingGamesProvider).groupId;
}

String _$pastGamesHash() => r'eadc2c3885c0f20171c22d1e28258c99f82365cf';

/// See also [pastGames].
@ProviderFor(pastGames)
const pastGamesProvider = PastGamesFamily();

/// See also [pastGames].
class PastGamesFamily extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [pastGames].
  const PastGamesFamily();

  /// See also [pastGames].
  PastGamesProvider call({required String groupId, required int limit}) {
    return PastGamesProvider(groupId: groupId, limit: limit);
  }

  @override
  PastGamesProvider getProviderOverride(covariant PastGamesProvider provider) {
    return call(groupId: provider.groupId, limit: provider.limit);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pastGamesProvider';
}

/// See also [pastGames].
class PastGamesProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [pastGames].
  PastGamesProvider({required String groupId, required int limit})
    : this._internal(
        (ref) => pastGames(ref as PastGamesRef, groupId: groupId, limit: limit),
        from: pastGamesProvider,
        name: r'pastGamesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pastGamesHash,
        dependencies: PastGamesFamily._dependencies,
        allTransitiveDependencies: PastGamesFamily._allTransitiveDependencies,
        groupId: groupId,
        limit: limit,
      );

  PastGamesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
    required this.limit,
  }) : super.internal();

  final String groupId;
  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(PastGamesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PastGamesProvider._internal(
        (ref) => create(ref as PastGamesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _PastGamesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PastGamesProvider &&
        other.groupId == groupId &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PastGamesRef on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `groupId` of this provider.
  String get groupId;

  /// The parameter `limit` of this provider.
  int get limit;
}

class _PastGamesProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with PastGamesRef {
  _PastGamesProviderElement(super.provider);

  @override
  String get groupId => (origin as PastGamesProvider).groupId;
  @override
  int get limit => (origin as PastGamesProvider).limit;
}

String _$hasPastGamesHash() => r'abc82ae4474e89de729f135c0cbec982f3149682';

/// See also [hasPastGames].
@ProviderFor(hasPastGames)
const hasPastGamesProvider = HasPastGamesFamily();

/// See also [hasPastGames].
class HasPastGamesFamily extends Family<AsyncValue<bool>> {
  /// See also [hasPastGames].
  const HasPastGamesFamily();

  /// See also [hasPastGames].
  HasPastGamesProvider call(String groupId) {
    return HasPastGamesProvider(groupId);
  }

  @override
  HasPastGamesProvider getProviderOverride(
    covariant HasPastGamesProvider provider,
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
  String? get name => r'hasPastGamesProvider';
}

/// See also [hasPastGames].
class HasPastGamesProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [hasPastGames].
  HasPastGamesProvider(String groupId)
    : this._internal(
        (ref) => hasPastGames(ref as HasPastGamesRef, groupId),
        from: hasPastGamesProvider,
        name: r'hasPastGamesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$hasPastGamesHash,
        dependencies: HasPastGamesFamily._dependencies,
        allTransitiveDependencies:
            HasPastGamesFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  HasPastGamesProvider._internal(
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
    FutureOr<bool> Function(HasPastGamesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HasPastGamesProvider._internal(
        (ref) => create(ref as HasPastGamesRef),
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
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _HasPastGamesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HasPastGamesProvider && other.groupId == groupId;
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
mixin HasPastGamesRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _HasPastGamesProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with HasPastGamesRef {
  _HasPastGamesProviderElement(super.provider);

  @override
  String get groupId => (origin as HasPastGamesProvider).groupId;
}

String _$gameDetailHash() => r'f6fc7df0352d5930f9bb66f41e2d657cabaa0c7e';

/// See also [gameDetail].
@ProviderFor(gameDetail)
const gameDetailProvider = GameDetailFamily();

/// See also [gameDetail].
class GameDetailFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [gameDetail].
  const GameDetailFamily();

  /// See also [gameDetail].
  GameDetailProvider call(String gameId) {
    return GameDetailProvider(gameId);
  }

  @override
  GameDetailProvider getProviderOverride(
    covariant GameDetailProvider provider,
  ) {
    return call(provider.gameId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gameDetailProvider';
}

/// See also [gameDetail].
class GameDetailProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [gameDetail].
  GameDetailProvider(String gameId)
    : this._internal(
        (ref) => gameDetail(ref as GameDetailRef, gameId),
        from: gameDetailProvider,
        name: r'gameDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gameDetailHash,
        dependencies: GameDetailFamily._dependencies,
        allTransitiveDependencies: GameDetailFamily._allTransitiveDependencies,
        gameId: gameId,
      );

  GameDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameId,
  }) : super.internal();

  final String gameId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(GameDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GameDetailProvider._internal(
        (ref) => create(ref as GameDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameId: gameId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _GameDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameDetailProvider && other.gameId == gameId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameDetailRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `gameId` of this provider.
  String get gameId;
}

class _GameDetailProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with GameDetailRef {
  _GameDetailProviderElement(super.provider);

  @override
  String get gameId => (origin as GameDetailProvider).gameId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
