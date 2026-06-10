// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rsvp_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myRsvpNotifierHash() => r'f7163118726be704aa13606848c78083b52e3c5b';

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

abstract class _$MyRsvpNotifier
    extends BuildlessAutoDisposeAsyncNotifier<RsvpState> {
  late final String gameId;

  FutureOr<RsvpState> build(String gameId);
}

/// See also [MyRsvpNotifier].
@ProviderFor(MyRsvpNotifier)
const myRsvpNotifierProvider = MyRsvpNotifierFamily();

/// See also [MyRsvpNotifier].
class MyRsvpNotifierFamily extends Family<AsyncValue<RsvpState>> {
  /// See also [MyRsvpNotifier].
  const MyRsvpNotifierFamily();

  /// See also [MyRsvpNotifier].
  MyRsvpNotifierProvider call(String gameId) {
    return MyRsvpNotifierProvider(gameId);
  }

  @override
  MyRsvpNotifierProvider getProviderOverride(
    covariant MyRsvpNotifierProvider provider,
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
  String? get name => r'myRsvpNotifierProvider';
}

/// See also [MyRsvpNotifier].
class MyRsvpNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<MyRsvpNotifier, RsvpState> {
  /// See also [MyRsvpNotifier].
  MyRsvpNotifierProvider(String gameId)
    : this._internal(
        () => MyRsvpNotifier()..gameId = gameId,
        from: myRsvpNotifierProvider,
        name: r'myRsvpNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myRsvpNotifierHash,
        dependencies: MyRsvpNotifierFamily._dependencies,
        allTransitiveDependencies:
            MyRsvpNotifierFamily._allTransitiveDependencies,
        gameId: gameId,
      );

  MyRsvpNotifierProvider._internal(
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
  FutureOr<RsvpState> runNotifierBuild(covariant MyRsvpNotifier notifier) {
    return notifier.build(gameId);
  }

  @override
  Override overrideWith(MyRsvpNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MyRsvpNotifierProvider._internal(
        () => create()..gameId = gameId,
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
  AutoDisposeAsyncNotifierProviderElement<MyRsvpNotifier, RsvpState>
  createElement() {
    return _MyRsvpNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyRsvpNotifierProvider && other.gameId == gameId;
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
mixin MyRsvpNotifierRef on AutoDisposeAsyncNotifierProviderRef<RsvpState> {
  /// The parameter `gameId` of this provider.
  String get gameId;
}

class _MyRsvpNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MyRsvpNotifier, RsvpState>
    with MyRsvpNotifierRef {
  _MyRsvpNotifierProviderElement(super.provider);

  @override
  String get gameId => (origin as MyRsvpNotifierProvider).gameId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
