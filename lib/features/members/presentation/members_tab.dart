import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/members/application/members_providers.dart';
import 'package:gameior/features/members/domain/member.dart';
import 'package:gameior/features/members/data/members_repository.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_dialog.dart';
import 'package:gameior/shared/widgets/app_empty_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/features/members/presentation/widgets/member_stats_sheet.dart';

final groupHasUnpaidDuesProvider = FutureProvider.family<bool, String>((ref, groupId) async {
  final repo = ref.read(membersRepositoryProvider);
  return repo.hasGroupUnpaidDues(groupId: groupId);
});

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
                        child: _SegmentButton(
                          label: 'Roster',
                          isActive: _activeSegment == 0,
                          onPressed: () => setState(() => _activeSegment = 0),
                        ),
                      ),
                      Expanded(
                        child: _SegmentButton(
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

class _SegmentButton extends StatelessWidget {
  final String label;
  final int? badgeCount;
  final bool isActive;
  final VoidCallback onPressed;

  const _SegmentButton({
    required this.label,
    this.badgeCount,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.waitlist, // Orange badge for pending requests
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MembersRosterView extends ConsumerWidget {
  final String groupId;
  final MemberRole currentRole;

  const MembersRosterView({
    required this.groupId,
    required this.currentRole,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(groupMembersProvider(groupId));

    return membersAsync.when(
      loading: () => const AppLoadingShimmer(type: ShimmerType.card),
      error: (e, _) => Center(
        child: Text('Failed to load roster', style: AppTextStyles.bodyMedium),
      ),
      data: (members) {
        if (members.isEmpty) {
          return const AppEmptyState(
            message: 'No members in this group yet. Share the invite code to add players!',
          );
        }

        final hosts = members.where((m) => m.role == MemberRole.host).toList();
        final coHosts = members.where((m) => m.role == MemberRole.coHost).toList();
        final players = members.where((m) => m.role == MemberRole.player).toList();

        final isAdmin = currentRole == MemberRole.host || currentRole == MemberRole.coHost;
        final hasDuesAsync = ref.watch(groupHasUnpaidDuesProvider(groupId));
        final hasDues = hasDuesAsync.valueOrNull ?? false;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.base),
          children: [
            if (isAdmin && hasDues)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.base),
                child: AppButton(
                  label: 'Remind Pending Dues',
                  leadingIcon: Icons.notifications_active_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    // TODO: Call an Edge Function to dispatch actual push notifications
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reminders sent to all members with pending dues!')),
                    );
                  },
                ),
              ),
            if (hosts.isNotEmpty) ...[
              const _SectionHeader(title: 'HOST'),
              ...hosts.map((m) => _MemberRow(groupId: groupId, member: m, currentRole: currentRole)),
              const SizedBox(height: AppSpacing.base),
            ],
            if (coHosts.isNotEmpty) ...[
              const _SectionHeader(title: 'CO-HOSTS'),
              ...coHosts.map((m) => _MemberRow(groupId: groupId, member: m, currentRole: currentRole)),
              const SizedBox(height: AppSpacing.base),
            ],
            if (players.isNotEmpty) ...[
              const _SectionHeader(title: 'PLAYERS'),
              ...players.map((m) => _MemberRow(groupId: groupId, member: m, currentRole: currentRole)),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
      child: Text(
        title,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MemberRow extends ConsumerWidget {
  final String groupId;
  final GroupMember member;
  final MemberRole currentRole;

  const _MemberRow({
    required this.groupId,
    required this.member,
    required this.currentRole,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(supabaseClientProvider);
    final isMe = member.userId == client.auth.currentUser?.id;
    final isAdmin = currentRole == MemberRole.host || currentRole == MemberRole.coHost;

    Color roleColor = Colors.grey;
    String roleLabel = 'Player';
    if (member.role == MemberRole.host) {
      roleColor = AppColors.waitlist;
      roleLabel = 'Host';
    } else if (member.role == MemberRole.coHost) {
      roleColor = Colors.blue;
      roleLabel = 'Co-Host';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: 4,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(color: roleColor.withOpacity(0.3), width: 1.5),
          ),
          child: Center(
            child: Text(
              member.emoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.displayName + (isMe ? ' (You)' : ''),
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                roleLabel,
                style: AppTextStyles.labelSmall.copyWith(
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          member.phone,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () => _showMemberProfileSheet(context, ref),
      ),
    );
  }

  void _showMemberProfileSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MemberStatsSheet(
        groupId: groupId,
        member: member,
        currentUserRole: currentRole,
      ),
    );
  }
}

class JoinRequestsView extends ConsumerWidget {
  final String groupId;
  const JoinRequestsView({required this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(groupJoinRequestsProvider(groupId));

    return requestsAsync.when(
      loading: () => const AppLoadingShimmer(type: ShimmerType.card),
      error: (e, _) => Center(
        child: Text('Failed to load join requests', style: AppTextStyles.bodyMedium),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return const AppEmptyState(
            message: 'No pending join requests.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.base),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(color: AppColors.border.withOpacity(0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.border.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(req.emoji, style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(req.displayName, style: AppTextStyles.headlineSmall),
                              const SizedBox(height: 2),
                              Text(req.phone, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Reject',
                            variant: AppButtonVariant.ghost,
                            onPressed: () async {
                              await ref
                                  .read(groupJoinRequestsProvider(groupId).notifier)
                                  .reject(userId: req.userId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Join request for ${req.displayName} rejected.')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: AppButton(
                            label: 'Approve',
                            onPressed: () async {
                              await ref
                                  .read(groupJoinRequestsProvider(groupId).notifier)
                                  .approve(userId: req.userId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Join request for ${req.displayName} approved!')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
