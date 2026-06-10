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
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load groups'),
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
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(group.name),
        subtitle: Text('Members: ${group.memberCount}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/group/${group.id}'),
      ),
    );
  }
}