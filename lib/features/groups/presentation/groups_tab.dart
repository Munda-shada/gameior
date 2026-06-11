import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/groups/application/groups_provider.dart';
import 'package:gameior/features/groups/domain/group.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/router/route_names.dart';
import 'package:gameior/features/groups/presentation/widgets/join_group_bottom_sheet.dart';
import 'package:gameior/features/groups/presentation/widgets/group_card.dart';

import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';
import 'package:gameior/shared/widgets/app_button.dart';

class GroupsTab extends ConsumerWidget {
  const GroupsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(myGroupsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.createGroup),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'join') {
                _showJoinSheet(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'join',
                child: Text('Join with Code'),
              ),
            ],
          ),
        ],
      ),
      body: groupsAsync.when(
        loading: () => const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.base),
            child: Column(
              children: [
                AppLoadingShimmer(type: ShimmerType.card),
                SizedBox(height: AppSpacing.base),
                AppLoadingShimmer(type: ShimmerType.card),
                SizedBox(height: AppSpacing.base),
                AppLoadingShimmer(type: ShimmerType.card),
              ],
            ),
          ),
        ),
        error: (e, stack) => AppErrorState(
          message: 'Failed to load groups: $e',
          onRetry: () => ref.invalidate(myGroupsNotifierProvider),
        ),
        data: (groups) {
          if (groups.isEmpty) return _buildEmptyState(context);
          return _buildGroupList(context, ref, groups);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups_outlined, size: 64, color: AppColors.textDisabled),
            const SizedBox(height: AppSpacing.md),
            const Text("You're not in any groups yet", style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Create a Group',
              onPressed: () => context.push(Routes.createGroup),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Join with Code',
              variant: AppButtonVariant.ghost,
              onPressed: () => _showJoinSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      child: const JoinGroupBottomSheet(),
    );
  }

  Widget _buildGroupList(BuildContext context, WidgetRef ref, List<GroupSummary> groups) {
    // Separate into 3 categories
    final pending = groups.where(
      (g) => g.myStatus.name == 'pendingApproval').toList();
    final active  = groups.where(
      (g) => g.myStatus.name == 'active' && g.hasUpcomingSessions).toList();
    final quiet   = groups.where(
      (g) => g.myStatus.name == 'active' && !g.hasUpcomingSessions).toList();

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myGroupsNotifierProvider),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.base),
        children: [
          if (pending.isNotEmpty) ...[
            _buildSectionHeader('PENDING APPROVAL'),
            ...pending.map((g) => GroupCard(group: g)),
            const SizedBox(height: AppSpacing.base),
          ],
          if (active.isNotEmpty) ...[
            _buildSectionHeader('ACTIVE GROUPS'),
            ...active.map((g) => GroupCard(group: g)),
            const SizedBox(height: AppSpacing.base),
          ],
          if (quiet.isNotEmpty) ...[
            _buildSectionHeader('QUIET GROUPS'),
            ...quiet.map((g) => GroupCard(group: g)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        title,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}