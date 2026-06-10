import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/groups/application/groups_provider.dart';
import 'package:gameior/features/groups/domain/group.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/router/route_names.dart';
import 'package:gameior/features/groups/presentation/widgets/join_group_bottom_sheet.dart';

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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text('Failed to load groups:\n$e', 
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(myGroupsNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.groups_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: AppSpacing.md),
          const Text("You're not in any groups yet"),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () => context.push(Routes.createGroup),
            child: const Text('Create a Group'),
          ),
          TextButton(
            onPressed: () => _showJoinSheet(context),
            child: const Text('Join with Code'),
          ),
        ],
      ),
    );
  }

  void _showJoinSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        child: const JoinGroupBottomSheet(),
      ),
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
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class GroupCard extends StatelessWidget {
  final GroupSummary group;

  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final isAdmin = group.myRole.name == 'host' || group.myRole.name == 'coHost';
    final hasPendingDues = group.pendingDuesPaise > 0;
    final hasPendingFromPlayers = group.pendingFromPlayersPaise > 0 && isAdmin;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/group/${group.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Members: ${group.memberCount}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              if (hasPendingDues || hasPendingFromPlayers) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    if (hasPendingDues)
                      _buildDuesBadge(
                        'You owe ₹${(group.pendingDuesPaise / 100).toStringAsFixed(0)}',
                        Colors.red,
                      ),
                    if (hasPendingFromPlayers)
                      _buildDuesBadge(
                        'To collect ₹${(group.pendingFromPlayersPaise / 100).toStringAsFixed(0)}',
                        Colors.blue,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDuesBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}