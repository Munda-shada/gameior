import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/features/group_home/presentation/group_home_tab.dart';
import 'package:gameior/features/sessions/presentation/sessions_tab.dart';
import 'package:gameior/features/members/presentation/members_tab.dart';
import 'package:gameior/features/payments/presentation/payments_tab.dart';
import 'package:gameior/features/settings/presentation/group_settings_tab.dart';

class GroupShell extends ConsumerStatefulWidget {
  final String groupId;
  final int? initialTab;
  const GroupShell({required this.groupId, this.initialTab, super.key});

  @override
  ConsumerState<GroupShell> createState() => _GroupShellState();
}

class _GroupShellState extends ConsumerState<GroupShell> {
  @override
  void initState() {
    super.initState();
    if (widget.initialTab != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(groupWorkspaceTabProvider(widget.groupId).notifier).state = widget.initialTab!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contextAsync = ref.watch(groupContextProvider(widget.groupId));

    return contextAsync.when(
      loading: () => const Scaffold(body: AppLoadingShimmer(type: ShimmerType.card)),
      error: (e, _) => Scaffold(
        body: AppErrorState(
          message: 'Failed to load group details',
          onRetry: () => ref.invalidate(groupContextProvider(widget.groupId)),
        ),
      ),
      data: (groupContext) {
        final group = groupContext.group;
        final myRole = groupContext.myRole;
        final myStatus = groupContext.myStatus;

        if (myStatus != MembershipStatus.active) {
          return const Scaffold(
            body: Center(child: Text("You are not an active member of this group.")),
          );
        }

        final tabs = [
          GroupHomeTab(groupId: widget.groupId),
          SessionsTab(groupId: widget.groupId),
          MembersTab(groupId: widget.groupId),
          PaymentsTab(groupId: widget.groupId),
          GroupSettingsTab(groupId: widget.groupId),
        ];

        final currentIndex = ref.watch(groupWorkspaceTabProvider(widget.groupId));

        return Scaffold(
          backgroundColor: theme.colorScheme.surfaceContainerLowest,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${group.sport.name.toUpperCase()} • ${groupContext.inviteCode}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home/groups'),
            ),
            actions: [
              _buildRoleBadge(myRole, theme),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          body: tabs[currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor: theme.colorScheme.outline,
              type: BottomNavigationBarType.fixed,
              onTap: (index) => ref.read(groupWorkspaceTabProvider(widget.groupId).notifier).state = index,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_outlined),
                  activeIcon: Icon(Icons.sports),
                  label: 'Sessions',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Members',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  label: 'Payments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(MemberRole role, ThemeData theme) {
    Color color = theme.colorScheme.outline;
    String label = 'Player';
    if (role == MemberRole.host) {
      color = Colors.orange;
      label = 'Host';
    } else if (role == MemberRole.coHost) {
      color = theme.colorScheme.secondary;
      label = 'Co-Host';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}