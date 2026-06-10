// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hostProfileHash() => r'18c6f5d826b4019ed1073a9180867414ffaddd10';

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

/// See also [hostProfile].
@ProviderFor(hostProfile)
const hostProfileProvider = HostProfileFamily();

/// See also [hostProfile].
class HostProfileFamily extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [hostProfile].
  const HostProfileFamily();

  /// See also [hostProfile].
  HostProfileProvider call(String hostId) {
    return HostProfileProvider(hostId);
  }

  @override
  HostProfileProvider getProviderOverride(
    covariant HostProfileProvider provider,
  ) {
    return call(provider.hostId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'hostProfileProvider';
}

/// See also [hostProfile].
class HostProfileProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>?> {
  /// See also [hostProfile].
  HostProfileProvider(String hostId)
    : this._internal(
        (ref) => hostProfile(ref as HostProfileRef, hostId),
        from: hostProfileProvider,
        name: r'hostProfileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$hostProfileHash,
        dependencies: HostProfileFamily._dependencies,
        allTransitiveDependencies: HostProfileFamily._allTransitiveDependencies,
        hostId: hostId,
      );

  HostProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.hostId,
  }) : super.internal();

  final String hostId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>?> Function(HostProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HostProfileProvider._internal(
        (ref) => create(ref as HostProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        hostId: hostId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>?> createElement() {
    return _HostProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HostProfileProvider && other.hostId == hostId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, hostId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HostProfileRef on AutoDisposeFutureProviderRef<Map<String, dynamic>?> {
  /// The parameter `hostId` of this provider.
  String get hostId;
}

class _HostProfileProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>?>
    with HostProfileRef {
  _HostProfileProviderElement(super.provider);

  @override
  String get hostId => (origin as HostProfileProvider).hostId;
}

String _$matchesPlayedHash() => r'747315e957a094bdce13e3ee920ad685ebb1c1e9';

/// See also [matchesPlayed].
@ProviderFor(matchesPlayed)
const matchesPlayedProvider = MatchesPlayedFamily();

/// See also [matchesPlayed].
class MatchesPlayedFamily extends Family<AsyncValue<int>> {
  /// See also [matchesPlayed].
  const MatchesPlayedFamily();

  /// See also [matchesPlayed].
  MatchesPlayedProvider call(String groupId) {
    return MatchesPlayedProvider(groupId);
  }

  @override
  MatchesPlayedProvider getProviderOverride(
    covariant MatchesPlayedProvider provider,
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
  String? get name => r'matchesPlayedProvider';
}

/// See also [matchesPlayed].
class MatchesPlayedProvider extends AutoDisposeFutureProvider<int> {
  /// See also [matchesPlayed].
  MatchesPlayedProvider(String groupId)
    : this._internal(
        (ref) => matchesPlayed(ref as MatchesPlayedRef, groupId),
        from: matchesPlayedProvider,
        name: r'matchesPlayedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$matchesPlayedHash,
        dependencies: MatchesPlayedFamily._dependencies,
        allTransitiveDependencies:
            MatchesPlayedFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  MatchesPlayedProvider._internal(
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
    FutureOr<int> Function(MatchesPlayedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MatchesPlayedProvider._internal(
        (ref) => create(ref as MatchesPlayedRef),
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
    return _MatchesPlayedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchesPlayedProvider && other.groupId == groupId;
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
mixin MatchesPlayedRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _MatchesPlayedProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with MatchesPlayedRef {
  _MatchesPlayedProviderElement(super.provider);

  @override
  String get groupId => (origin as MatchesPlayedProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
