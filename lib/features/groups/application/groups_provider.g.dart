// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myGroupsNotifierHash() => r'79a88e1b7526cd4118029bead31aee6f752a289d';

/// See also [MyGroupsNotifier].
@ProviderFor(MyGroupsNotifier)
final myGroupsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      MyGroupsNotifier,
      List<GroupSummary>
    >.internal(
      MyGroupsNotifier.new,
      name: r'myGroupsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myGroupsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MyGroupsNotifier = AutoDisposeAsyncNotifier<List<GroupSummary>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
