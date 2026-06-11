// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminDuesByPlayerHash() => r'a24731e43923a51c7e110a6f8fc31dcd761e6ae9';

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

/// See also [adminDuesByPlayer].
@ProviderFor(adminDuesByPlayer)
const adminDuesByPlayerProvider = AdminDuesByPlayerFamily();

/// See also [adminDuesByPlayer].
class AdminDuesByPlayerFamily
    extends Family<AsyncValue<List<PlayerDuesSummary>>> {
  /// See also [adminDuesByPlayer].
  const AdminDuesByPlayerFamily();

  /// See also [adminDuesByPlayer].
  AdminDuesByPlayerProvider call(String groupId) {
    return AdminDuesByPlayerProvider(groupId);
  }

  @override
  AdminDuesByPlayerProvider getProviderOverride(
    covariant AdminDuesByPlayerProvider provider,
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
  String? get name => r'adminDuesByPlayerProvider';
}

/// See also [adminDuesByPlayer].
class AdminDuesByPlayerProvider
    extends AutoDisposeFutureProvider<List<PlayerDuesSummary>> {
  /// See also [adminDuesByPlayer].
  AdminDuesByPlayerProvider(String groupId)
    : this._internal(
        (ref) => adminDuesByPlayer(ref as AdminDuesByPlayerRef, groupId),
        from: adminDuesByPlayerProvider,
        name: r'adminDuesByPlayerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminDuesByPlayerHash,
        dependencies: AdminDuesByPlayerFamily._dependencies,
        allTransitiveDependencies:
            AdminDuesByPlayerFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  AdminDuesByPlayerProvider._internal(
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
    FutureOr<List<PlayerDuesSummary>> Function(AdminDuesByPlayerRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminDuesByPlayerProvider._internal(
        (ref) => create(ref as AdminDuesByPlayerRef),
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
  AutoDisposeFutureProviderElement<List<PlayerDuesSummary>> createElement() {
    return _AdminDuesByPlayerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminDuesByPlayerProvider && other.groupId == groupId;
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
mixin AdminDuesByPlayerRef
    on AutoDisposeFutureProviderRef<List<PlayerDuesSummary>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _AdminDuesByPlayerProviderElement
    extends AutoDisposeFutureProviderElement<List<PlayerDuesSummary>>
    with AdminDuesByPlayerRef {
  _AdminDuesByPlayerProviderElement(super.provider);

  @override
  String get groupId => (origin as AdminDuesByPlayerProvider).groupId;
}

String _$adminDuesByGameHash() => r'aa8eaf60869adb6d31721e633eb6a2cfa8932aaf';

/// See also [adminDuesByGame].
@ProviderFor(adminDuesByGame)
const adminDuesByGameProvider = AdminDuesByGameFamily();

/// See also [adminDuesByGame].
class AdminDuesByGameFamily extends Family<AsyncValue<List<GameDuesSummary>>> {
  /// See also [adminDuesByGame].
  const AdminDuesByGameFamily();

  /// See also [adminDuesByGame].
  AdminDuesByGameProvider call(String groupId) {
    return AdminDuesByGameProvider(groupId);
  }

  @override
  AdminDuesByGameProvider getProviderOverride(
    covariant AdminDuesByGameProvider provider,
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
  String? get name => r'adminDuesByGameProvider';
}

/// See also [adminDuesByGame].
class AdminDuesByGameProvider
    extends AutoDisposeFutureProvider<List<GameDuesSummary>> {
  /// See also [adminDuesByGame].
  AdminDuesByGameProvider(String groupId)
    : this._internal(
        (ref) => adminDuesByGame(ref as AdminDuesByGameRef, groupId),
        from: adminDuesByGameProvider,
        name: r'adminDuesByGameProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminDuesByGameHash,
        dependencies: AdminDuesByGameFamily._dependencies,
        allTransitiveDependencies:
            AdminDuesByGameFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  AdminDuesByGameProvider._internal(
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
    FutureOr<List<GameDuesSummary>> Function(AdminDuesByGameRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminDuesByGameProvider._internal(
        (ref) => create(ref as AdminDuesByGameRef),
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
  AutoDisposeFutureProviderElement<List<GameDuesSummary>> createElement() {
    return _AdminDuesByGameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminDuesByGameProvider && other.groupId == groupId;
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
mixin AdminDuesByGameRef
    on AutoDisposeFutureProviderRef<List<GameDuesSummary>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _AdminDuesByGameProviderElement
    extends AutoDisposeFutureProviderElement<List<GameDuesSummary>>
    with AdminDuesByGameRef {
  _AdminDuesByGameProviderElement(super.provider);

  @override
  String get groupId => (origin as AdminDuesByGameProvider).groupId;
}

String _$adminDuesNotifierHash() => r'c7d815f0bbfea5275ac6bdcd1fce3fc5428917ba';

abstract class _$AdminDuesNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<PaymentDue>> {
  late final String groupId;

  FutureOr<List<PaymentDue>> build(String groupId);
}

/// See also [AdminDuesNotifier].
@ProviderFor(AdminDuesNotifier)
const adminDuesNotifierProvider = AdminDuesNotifierFamily();

/// See also [AdminDuesNotifier].
class AdminDuesNotifierFamily extends Family<AsyncValue<List<PaymentDue>>> {
  /// See also [AdminDuesNotifier].
  const AdminDuesNotifierFamily();

  /// See also [AdminDuesNotifier].
  AdminDuesNotifierProvider call(String groupId) {
    return AdminDuesNotifierProvider(groupId);
  }

  @override
  AdminDuesNotifierProvider getProviderOverride(
    covariant AdminDuesNotifierProvider provider,
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
  String? get name => r'adminDuesNotifierProvider';
}

/// See also [AdminDuesNotifier].
class AdminDuesNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          AdminDuesNotifier,
          List<PaymentDue>
        > {
  /// See also [AdminDuesNotifier].
  AdminDuesNotifierProvider(String groupId)
    : this._internal(
        () => AdminDuesNotifier()..groupId = groupId,
        from: adminDuesNotifierProvider,
        name: r'adminDuesNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminDuesNotifierHash,
        dependencies: AdminDuesNotifierFamily._dependencies,
        allTransitiveDependencies:
            AdminDuesNotifierFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  AdminDuesNotifierProvider._internal(
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
  FutureOr<List<PaymentDue>> runNotifierBuild(
    covariant AdminDuesNotifier notifier,
  ) {
    return notifier.build(groupId);
  }

  @override
  Override overrideWith(AdminDuesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: AdminDuesNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<AdminDuesNotifier, List<PaymentDue>>
  createElement() {
    return _AdminDuesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminDuesNotifierProvider && other.groupId == groupId;
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
mixin AdminDuesNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<PaymentDue>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _AdminDuesNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          AdminDuesNotifier,
          List<PaymentDue>
        >
    with AdminDuesNotifierRef {
  _AdminDuesNotifierProviderElement(super.provider);

  @override
  String get groupId => (origin as AdminDuesNotifierProvider).groupId;
}

String _$myDuesNotifierHash() => r'eaa2df4d4a0edbfd5527adf6e8498fb85a36778f';

abstract class _$MyDuesNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<PaymentDue>> {
  late final String groupId;

  FutureOr<List<PaymentDue>> build(String groupId);
}

/// See also [MyDuesNotifier].
@ProviderFor(MyDuesNotifier)
const myDuesNotifierProvider = MyDuesNotifierFamily();

/// See also [MyDuesNotifier].
class MyDuesNotifierFamily extends Family<AsyncValue<List<PaymentDue>>> {
  /// See also [MyDuesNotifier].
  const MyDuesNotifierFamily();

  /// See also [MyDuesNotifier].
  MyDuesNotifierProvider call(String groupId) {
    return MyDuesNotifierProvider(groupId);
  }

  @override
  MyDuesNotifierProvider getProviderOverride(
    covariant MyDuesNotifierProvider provider,
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
  String? get name => r'myDuesNotifierProvider';
}

/// See also [MyDuesNotifier].
class MyDuesNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<MyDuesNotifier, List<PaymentDue>> {
  /// See also [MyDuesNotifier].
  MyDuesNotifierProvider(String groupId)
    : this._internal(
        () => MyDuesNotifier()..groupId = groupId,
        from: myDuesNotifierProvider,
        name: r'myDuesNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myDuesNotifierHash,
        dependencies: MyDuesNotifierFamily._dependencies,
        allTransitiveDependencies:
            MyDuesNotifierFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  MyDuesNotifierProvider._internal(
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
  FutureOr<List<PaymentDue>> runNotifierBuild(
    covariant MyDuesNotifier notifier,
  ) {
    return notifier.build(groupId);
  }

  @override
  Override overrideWith(MyDuesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MyDuesNotifierProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<MyDuesNotifier, List<PaymentDue>>
  createElement() {
    return _MyDuesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyDuesNotifierProvider && other.groupId == groupId;
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
mixin MyDuesNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<PaymentDue>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _MyDuesNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MyDuesNotifier,
          List<PaymentDue>
        >
    with MyDuesNotifierRef {
  _MyDuesNotifierProviderElement(super.provider);

  @override
  String get groupId => (origin as MyDuesNotifierProvider).groupId;
}

String _$paymentsPlayerFilterHash() =>
    r'8f2ce89f6dae99ba7ae2682cc1d34604f5046bf5';

abstract class _$PaymentsPlayerFilter
    extends BuildlessAutoDisposeNotifier<String?> {
  late final String groupId;

  String? build(String groupId);
}

/// See also [PaymentsPlayerFilter].
@ProviderFor(PaymentsPlayerFilter)
const paymentsPlayerFilterProvider = PaymentsPlayerFilterFamily();

/// See also [PaymentsPlayerFilter].
class PaymentsPlayerFilterFamily extends Family<String?> {
  /// See also [PaymentsPlayerFilter].
  const PaymentsPlayerFilterFamily();

  /// See also [PaymentsPlayerFilter].
  PaymentsPlayerFilterProvider call(String groupId) {
    return PaymentsPlayerFilterProvider(groupId);
  }

  @override
  PaymentsPlayerFilterProvider getProviderOverride(
    covariant PaymentsPlayerFilterProvider provider,
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
  String? get name => r'paymentsPlayerFilterProvider';
}

/// See also [PaymentsPlayerFilter].
class PaymentsPlayerFilterProvider
    extends AutoDisposeNotifierProviderImpl<PaymentsPlayerFilter, String?> {
  /// See also [PaymentsPlayerFilter].
  PaymentsPlayerFilterProvider(String groupId)
    : this._internal(
        () => PaymentsPlayerFilter()..groupId = groupId,
        from: paymentsPlayerFilterProvider,
        name: r'paymentsPlayerFilterProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$paymentsPlayerFilterHash,
        dependencies: PaymentsPlayerFilterFamily._dependencies,
        allTransitiveDependencies:
            PaymentsPlayerFilterFamily._allTransitiveDependencies,
        groupId: groupId,
      );

  PaymentsPlayerFilterProvider._internal(
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
  String? runNotifierBuild(covariant PaymentsPlayerFilter notifier) {
    return notifier.build(groupId);
  }

  @override
  Override overrideWith(PaymentsPlayerFilter Function() create) {
    return ProviderOverride(
      origin: this,
      override: PaymentsPlayerFilterProvider._internal(
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
  AutoDisposeNotifierProviderElement<PaymentsPlayerFilter, String?>
  createElement() {
    return _PaymentsPlayerFilterProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PaymentsPlayerFilterProvider && other.groupId == groupId;
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
mixin PaymentsPlayerFilterRef on AutoDisposeNotifierProviderRef<String?> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _PaymentsPlayerFilterProviderElement
    extends AutoDisposeNotifierProviderElement<PaymentsPlayerFilter, String?>
    with PaymentsPlayerFilterRef {
  _PaymentsPlayerFilterProviderElement(super.provider);

  @override
  String get groupId => (origin as PaymentsPlayerFilterProvider).groupId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
