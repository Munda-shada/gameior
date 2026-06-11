import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/groups/application/groups_provider.dart';
import 'package:gameior/features/groups/domain/group.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/router/route_names.dart';
import 'package:gameior/features/groups/presentation/widgets/join_group_bottom_sheet.dart';
import 'package:gameior/features/groups/presentation/widgets/group_card.dart';

import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/notification_bell.dart';

class GroupsTab extends ConsumerStatefulWidget {
  const GroupsTab({super.key});

  @override
  ConsumerState<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends ConsumerState<GroupsTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groupsAsync = ref.watch(myGroupsNotifierProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          const NotificationBell(),
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
          if (groups.isEmpty) return _buildEmptyState(context, theme);

          final filteredGroups = groups.where((g) {
            final query = _searchQuery.toLowerCase().trim();
            if (query.isEmpty) return true;
            return g.name.toLowerCase().contains(query) ||
                g.sport.name.toLowerCase().contains(query);
          }).toList();

          return _buildGroupList(context, ref, filteredGroups, theme);
        },
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search groups or sports...',
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              "You're not in any groups yet",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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

  Widget _buildGroupList(
    BuildContext context,
    WidgetRef ref,
    List<GroupSummary> groups,
    ThemeData theme,
  ) {
    if (groups.isEmpty) {
      return RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: () async => ref.invalidate(myGroupsNotifierProvider),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.base),
          children: [
            _buildSearchBar(theme),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    'No groups match "$_searchQuery"',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Try checking your spelling or search for another sport.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final pending = groups.where((g) => g.myStatus.name == 'pendingApproval').toList();
    final active = groups.where((g) => g.myStatus.name == 'active' && g.hasUpcomingSessions).toList();
    final quiet = groups.where((g) => g.myStatus.name == 'active' && !g.hasUpcomingSessions).toList();

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      onRefresh: () async => ref.invalidate(myGroupsNotifierProvider),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.base),
        children: [
          _buildSearchBar(theme),
          if (pending.isNotEmpty) ...[
            _buildSectionHeader('PENDING APPROVAL', theme),
            ...pending.map((g) => GroupCard(group: g)),
            const SizedBox(height: AppSpacing.base),
          ],
          if (active.isNotEmpty) ...[
            _buildSectionHeader('ACTIVE GROUPS', theme),
            ...active.map((g) => GroupCard(group: g)),
            const SizedBox(height: AppSpacing.base),
          ],
          if (quiet.isNotEmpty) ...[
            _buildSectionHeader('QUIET GROUPS', theme),
            ...quiet.map((g) => GroupCard(group: g)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}