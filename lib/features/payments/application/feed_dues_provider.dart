// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gameior/core/supabase/supabase_client.dart';

part 'feed_dues_provider.freezed.dart';
part 'feed_dues_provider.g.dart';

@freezed
abstract class FeedDuesSummary with _$FeedDuesSummary {
  const factory FeedDuesSummary({
    required int totalPaise,
    required int groupCount,
    required List<GroupDueSummary> groupBreakdown,
  }) = _FeedDuesSummary;
}

@freezed
abstract class GroupDueSummary with _$GroupDueSummary {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory GroupDueSummary({
    required String groupId,
    required int pendingPaise,
    required int unpaidCount,
    Map<String, dynamic>? groups, // Nested groups query
  }) = _GroupDueSummary;

  factory GroupDueSummary.fromJson(Map<String, dynamic> json) =>
      _$GroupDueSummaryFromJson(json);
}

extension GroupDueSummaryGetters on GroupDueSummary {
  String get groupName {
    if (groups != null) {
      return groups!['name'] as String? ?? 'Group';
    }
    return 'Group';
  }
}

@riverpod
Future<FeedDuesSummary> feedDuesSummary(FeedDuesSummaryRef ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) {
    return const FeedDuesSummary(totalPaise: 0, groupCount: 0, groupBreakdown: []);
  }

  // Uses the v_player_dues_summary view with nested groups table select
  final response = await client
      .from('v_player_dues_summary')
      .select('*, groups(name)')
      .eq('player_id', userId);

  int totalPaise = 0;
  int groupCount = 0;
  final groupBreakdown = <GroupDueSummary>[];

  for (final row in response as List) {
    final pending = row['pending_paise'] as int? ?? 0;
    if (pending > 0) {
      totalPaise += pending;
      groupCount++;
      groupBreakdown.add(GroupDueSummary.fromJson(row as Map<String, dynamic>));
    }
  }

  return FeedDuesSummary(
    totalPaise:      totalPaise,
    groupCount:      groupCount,
    groupBreakdown:  groupBreakdown,
  );
}
