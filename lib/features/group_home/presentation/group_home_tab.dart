import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/group_home/application/group_home_providers.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_dialog.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/core/utils/app_toast.dart';
import 'package:gameior/shared/widgets/section_header.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';

import 'package:gameior/features/group_home/presentation/widgets/admin_ledger_hero.dart';
import 'package:gameior/features/group_home/presentation/widgets/player_ledger_hero.dart';
import 'package:gameior/features/group_home/presentation/widgets/next_game_preview.dart';
import 'package:gameior/features/group_home/presentation/widgets/club_rules_card.dart';
import 'package:gameior/features/group_home/presentation/widgets/announcements_list.dart';
import 'package:gameior/features/group_home/presentation/widgets/post_announcement_sheet.dart';

class GroupHomeTab extends ConsumerWidget {
  final String groupId;
  const GroupHomeTab({required this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final contextAsync = ref.watch(groupContextProvider(groupId));

    return contextAsync.when(
      loading: () => const AppLoadingShimmer(type: ShimmerType.card),
      error: (e, _) => AppErrorState(
        message: 'Failed to load group home details',
        onRetry: () => ref.invalidate(groupContextProvider(groupId)),
      ),
      data: (groupContext) {
        final group = groupContext.group;
        final myRole = groupContext.myRole;
        final isAdmin = myRole == MemberRole.host || myRole == MemberRole.coHost;

        final duesAsync = isAdmin
            ? ref.watch(adminDuesProvider(groupId))
            : ref.watch(playerDuesProvider(groupId));

        return RefreshIndicator(
          color: theme.colorScheme.primary,
          onRefresh: () async {
            ref.invalidate(groupContextProvider(groupId));
            ref.invalidate(nextGroupGameProvider(groupId));
            ref.invalidate(groupAnnouncementsProvider(groupId));
            ref.invalidate(adminDuesProvider(groupId));
            ref.invalidate(playerDuesProvider(groupId));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.base),
            children: [
              // 1. Ledger Hero Card
              duesAsync.when(
                data: (amount) {
                  if (isAdmin) {
                    return AdminLedgerHero(
                      amountPaise: amount,
                      onTap: () {
                        // Switch to Payments tab (index 3)
                        ref.read(groupWorkspaceTabProvider(groupId).notifier).state = 3;
                      },
                    );
                  } else {
                    return PlayerLedgerHero(
                      amountPaise: amount,
                      onTap: () {
                        // Switch to Payments tab (index 3)
                        ref.read(groupWorkspaceTabProvider(groupId).notifier).state = 3;
                      },
                    );
                  }
                },
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
              ),

              // 2. Next Session Card
              NextGamePreview(groupId: groupId, isAdmin: isAdmin),
              const SizedBox(height: AppSpacing.base),

              // 3. Pinned Club Rules Card
              ClubRulesCard(
                groupId: groupId,
                rules: group.clubRules ?? '',
                isAdmin: isAdmin,
              ),
              const SizedBox(height: AppSpacing.base),

              // 4. Announcements List
              AnnouncementsList(
                groupId: groupId,
                isAdmin: isAdmin,
                onPostAnnouncement: () => _showPostAnnouncementSheet(context, groupId),
              ),
              const SizedBox(height: AppSpacing.base),

              // 5. Invite Members Card
              const SectionHeader(title: 'INVITE MEMBERS'),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Group Invite Code',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            SelectableText(
                              groupContext.inviteCode,
                              style: theme.textTheme.displayMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.copy,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: groupContext.inviteCode));
                                showToast(context, 'Invite code copied to clipboard!');
                              },
                            ),
                            if (isAdmin)
                              IconButton(
                                icon: Icon(
                                  Icons.refresh,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () => _regenerateInviteCode(context, ref, groupId),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      height: AppSpacing.lg,
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                    AppButton(
                      label: 'Share Invite Code',
                      variant: AppButtonVariant.primary,
                      leadingIcon: Icons.share,
                      onPressed: () {
                        Share.share(
                          'Join our sports club "${group.name}" on Gameior!\n'
                          'Use my invite code: ${groupContext.inviteCode} to join.\n\n'
                          'Get the app and search for code in Groups tab.',
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }

  void _showPostAnnouncementSheet(BuildContext context, String groupId) {
    showAppBottomSheet(
      context: context,
      title: 'Post Announcement',
      initialChildSizeRatio: 0.65,
      child: PostAnnouncementBottomSheet(groupId: groupId),
    );
  }

  Future<void> _regenerateInviteCode(BuildContext context, WidgetRef ref, String groupId) async {
    final confirm = await showAppDialog(
      context: context,
      title: 'Regenerate Invite Code?',
      message: 'Any players with the old code will no longer be able to join using it. A new code will be generated immediately.',
      confirmLabel: 'Regenerate',
      isDestructive: true,
    );
    if (confirm == true) {
      final client = ref.read(supabaseClientProvider);
      try {
        await client.functions.invoke('regenerate_invite_code', body: {'group_id': groupId});
      } catch (e) {
        if (context.mounted) {
          showToast(context, 'Failed to regenerate invite code: $e. Please retry.', isError: true);
        }
        return;
      }
      ref.invalidate(groupContextProvider(groupId));
      if (context.mounted) {
        showToast(context, 'Invite code regenerated successfully!');
      }
    }
  }
}
