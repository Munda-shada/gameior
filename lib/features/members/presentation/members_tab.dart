import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/members/application/members_providers.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';

import 'package:gameior/features/members/presentation/widgets/segment_button.dart';
import 'package:gameior/features/members/presentation/roster_view.dart';
import 'package:gameior/features/members/presentation/join_requests_view.dart';

class MembersTab extends ConsumerStatefulWidget {
  final String groupId;
  const MembersTab({required this.groupId, super.key});

  @override
  ConsumerState<MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends ConsumerState<MembersTab> {
  int _activeSegment = 0; // 0 = Roster, 1 = Join Requests

  @override
  Widget build(BuildContext context) {
    final contextAsync = ref.watch(groupContextProvider(widget.groupId));

    return contextAsync.when(
      loading: () => const AppLoadingShimmer(type: ShimmerType.card),
      error: (e, _) => Center(
        child: Text('Failed to load group context', style: AppTextStyles.bodyMedium),
      ),
      data: (groupCtx) {
        final myRole = groupCtx.myRole;
        final isAdmin = myRole == MemberRole.host || myRole == MemberRole.coHost;

        final requestsAsync = ref.watch(groupJoinRequestsProvider(widget.groupId));
        final pendingCount = requestsAsync.maybeWhen(
          data: (list) => list.length,
          orElse: () => 0,
        );

        return Column(
          children: [
            // Segmented Tab bar (Admins only see "Join Requests" segment option)
            if (isAdmin)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.sm,
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SegmentButton(
                          label: 'Roster',
                          isActive: _activeSegment == 0,
                          onPressed: () => setState(() => _activeSegment = 0),
                        ),
                      ),
                      Expanded(
                        child: SegmentButton(
                          label: 'Requests',
                          badgeCount: pendingCount,
                          isActive: _activeSegment == 1,
                          onPressed: () => setState(() => _activeSegment = 1),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const SizedBox(height: AppSpacing.xs),

            // Main Content area
            Expanded(
              child: (_activeSegment == 1 && isAdmin)
                  ? JoinRequestsView(groupId: widget.groupId)
                  : MembersRosterView(groupId: widget.groupId, currentRole: myRole),
            ),
          ],
        );
      },
    );
  }
}
