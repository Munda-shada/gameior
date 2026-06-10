// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_dues_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupDueSummary _$GroupDueSummaryFromJson(Map<String, dynamic> json) =>
    _GroupDueSummary(
      groupId: json['group_id'] as String,
      pendingPaise: (json['pending_paise'] as num).toInt(),
      unpaidCount: (json['unpaid_count'] as num).toInt(),
      groups: json['groups'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GroupDueSummaryToJson(_GroupDueSummary instance) =>
    <String, dynamic>{
      'group_id': instance.groupId,
      'pending_paise': instance.pendingPaise,
      'unpaid_count': instance.unpaidCount,
      'groups': instance.groups,
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedDuesSummaryHash() => r'0edaa3eaa0f96f506312950896d78d0706fac7aa';

/// See also [feedDuesSummary].
@ProviderFor(feedDuesSummary)
final feedDuesSummaryProvider =
    AutoDisposeFutureProvider<FeedDuesSummary>.internal(
      feedDuesSummary,
      name: r'feedDuesSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feedDuesSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedDuesSummaryRef = AutoDisposeFutureProviderRef<FeedDuesSummary>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
