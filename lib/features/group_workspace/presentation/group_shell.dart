import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
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
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.name, style: AppTextStyles.headlineMedium),
                Text(
                  '${group.sport.name.toUpperCase()} • ${groupContext.inviteCode}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home/groups'),
            ),
            actions: [
              _buildRoleBadge(myRole),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          body: tabs[currentIndex],
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textDisabled,
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

  Widget _buildRoleBadge(MemberRole role) {
    Color color = Colors.grey;
    String label = 'Player';
    if (role == MemberRole.host) {
      color = AppColors.waitlist; // Orange
      label = 'Host';
    } else if (role == MemberRole.coHost) {
      color = Colors.blue;
      label = 'Co-Host';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPlaceholderTab(String name) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction, size: 64, color: AppColors.textDisabled),
          const SizedBox(height: AppSpacing.base),
          Text(name, style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          const Text('Coming in the next sprint!', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}