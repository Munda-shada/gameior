import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/group_home/application/group_home_providers.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_dialog.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/shared/widgets/dues_hero_card.dart';
import 'package:gameior/shared/widgets/section_header.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';

class GroupHomeTab extends ConsumerWidget {
  final String groupId;
  const GroupHomeTab({required this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

        final nextGameAsync = ref.watch(nextGroupGameProvider(groupId));
        final announcementsAsync = ref.watch(groupAnnouncementsProvider(groupId));
        
        final duesAsync = isAdmin 
            ? ref.watch(adminDuesProvider(groupId))
            : ref.watch(playerDuesProvider(groupId));

        return RefreshIndicator(
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
                  if (amount <= 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.base),
                    child: DuesHeroCard(
                      amountPaise: amount,
                      label: isAdmin ? 'Pending from players' : 'You owe',
                      ctaLabel: isAdmin ? 'Collect' : 'Pay',
                      isAdminView: isAdmin,
                      onTap: () {
                        // Switch to Payments tab (index 3)
                        ref.read(groupWorkspaceTabProvider(groupId).notifier).state = 3;
                      },
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // 2. Next Session Card
              const SectionHeader(title: 'NEXT SESSION'),
              nextGameAsync.when(
                loading: () => const SizedBox(
                  height: 120,
                  child: AppLoadingShimmer(type: ShimmerType.card),
                ),
                error: (err, _) => const AppErrorState(
                  message: 'Failed to load next session',
                ),
                data: (game) {
                  if (game == null) {
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 36, color: AppColors.textDisabled),
                          const SizedBox(height: AppSpacing.sm),
                          const Text('No sessions scheduled yet', style: AppTextStyles.bodyMedium),
                          if (isAdmin) ...[
                            const SizedBox(height: AppSpacing.sm),
                            AppButton(
                              label: 'Schedule a Game',
                              variant: AppButtonVariant.secondary,
                              isFullWidth: false,
                              onPressed: () {
                                // Switch to Sessions tab (index 1)
                                ref.read(groupWorkspaceTabProvider(groupId).notifier).state = 1;
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  final scheduledAt = DateTime.parse(game['scheduled_at'] as String).toLocal();
                  final formattedTime = DateFormat('EEE, MMM d • h:mm a').format(scheduledAt);
                  final desc = game['description'] as String?;

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      onTap: () => context.push('/group/$groupId/game/${game['id']}'),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.base),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('🏸', style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        game['title'] as String? ?? 'Match Session',
                                        style: AppTextStyles.headlineMedium,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        formattedTime,
                                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                              ],
                            ),
                            const Divider(height: AppSpacing.lg),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    game['venue'] as String? ?? 'Default venue',
                                    style: AppTextStyles.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (desc != null && desc.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                desc,
                                style: AppTextStyles.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.base),

              // 3. Pinned Club Rules Card
              const SectionHeader(title: 'CLUB RULES'),
              PinnedRulesCard(rules: group.clubRules ?? ''),
              const SizedBox(height: AppSpacing.base),

              // 4. Announcements List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionHeader(title: 'ANNOUNCEMENTS'),
                  if (isAdmin)
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Post'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _showPostAnnouncementSheet(context, groupId),
                    ),
                ],
              ),
              announcementsAsync.when(
                loading: () => const SizedBox(
                  height: 100,
                  child: AppLoadingShimmer(type: ShimmerType.listTile),
                ),
                error: (err, _) => const AppErrorState(
                  message: 'Failed to load announcements',
                ),
                data: (announcements) {
                  if (announcements.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          'No announcements posted yet',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: announcements.map((item) {
                      final profile = item['profiles'] as Map<String, dynamic>? ?? {};
                      final senderName = profile['display_name'] as String? ?? 'Organiser';
                      final emoji = profile['emoji'] as String? ?? '🏸';
                      final message = item['message'] as String? ?? '';
                      final createdAt = DateTime.parse(item['created_at'] as String).toLocal();
                      final formattedTime = DateFormat('MMM d, h:mm a').format(createdAt);
                      final linkedGameId = item['linked_game_id'] as String?;

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(emoji, style: const TextStyle(fontSize: 16)),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(senderName, style: AppTextStyles.labelLarge),
                                        Text(formattedTime, style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ),
                                  if (isAdmin)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.destructive, size: 20),
                                      onPressed: () => _deleteAnnouncement(context, ref, item['id'] as String),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                              if (linkedGameId != null && linkedGameId.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: ActionChip(
                                    avatar: const Icon(Icons.calendar_month, size: 14, color: AppColors.primary),
                                    label: const Text('View Game Session', style: TextStyle(fontSize: 12)),
                                    onPressed: () => context.push('/group/$groupId/game/$linkedGameId'),
                                    backgroundColor: AppColors.primaryMuted,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.base),

              // 5. Invite Members Card
              const SectionHeader(title: 'INVITE MEMBERS'),
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Group Invite Code', style: AppTextStyles.bodySmall),
                            const SizedBox(height: 2),
                            SelectableText(
                              groupContext.inviteCode,
                              style: AppTextStyles.displayMedium.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, color: AppColors.textSecondary),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: groupContext.inviteCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Invite code copied to clipboard!')),
                                );
                              },
                            ),
                            if (isAdmin)
                              IconButton(
                                icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                                onPressed: () => _regenerateInviteCode(context, ref, groupId),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: AppSpacing.lg),
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

  Future<void> _deleteAnnouncement(BuildContext context, WidgetRef ref, String announcementId) async {
    final confirm = await showAppDialog(
      context: context,
      title: 'Delete Announcement?',
      message: 'This announcement will be permanently removed. This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirm == true) {
      final client = ref.read(supabaseClientProvider);
      try {
        await client.from('announcements').delete().eq('id', announcementId);
        ref.invalidate(groupAnnouncementsProvider(groupId));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement deleted!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete announcement.')),
          );
        }
      }
    }
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
        final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
        final rand = DateTime.now().microsecondsSinceEpoch;
        var code = '';
        for (var i = 0; i < 6; i++) {
          final charIndex = (rand ~/ (i + 1) * 31) % chars.length;
          code += chars[charIndex];
        }
        try {
          await client.from('group_invites').delete().eq('group_id', groupId);
          await client.from('group_invites').insert({
            'group_id': groupId,
            'code': code,
            'created_by': client.auth.currentUser!.id,
          });
        } catch (err) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to regenerate code.')),
            );
          }
          return;
        }
      }
      ref.invalidate(groupContextProvider(groupId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite code regenerated successfully!')),
        );
      }
    }
  }
}

class PinnedRulesCard extends StatefulWidget {
  final String rules;
  const PinnedRulesCard({required this.rules, super.key});

  @override
  State<PinnedRulesCard> createState() => _PinnedRulesCardState();
}

class _PinnedRulesCardState extends State<PinnedRulesCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasRules = widget.rules.trim().isNotEmpty;
    final displayRules = hasRules ? widget.rules : 'No club rules defined yet.';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.push_pin, color: AppColors.waitlist),
            title: const Text('Pinned Rules & Guidelines', style: AppTextStyles.headlineSmall),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Divider(height: 1),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  displayRules,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PostAnnouncementBottomSheet extends ConsumerStatefulWidget {
  final String groupId;
  const PostAnnouncementBottomSheet({required this.groupId, super.key});

  @override
  ConsumerState<PostAnnouncementBottomSheet> createState() => _PostAnnouncementBottomSheetState();
}

class _PostAnnouncementBottomSheetState extends ConsumerState<PostAnnouncementBottomSheet> {
  final _controller = TextEditingController();
  String? _selectedGameId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(groupAnnouncementsProvider(widget.groupId));
    final gamesAsync = ref.watch(groupUpcomingGamesProvider(widget.groupId));

    return announcementsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.base),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.all(AppSpacing.base),
        child: Center(child: Text('Failed to load announcements limit check')),
      ),
      data: (announcements) {
        if (announcements.length >= 5) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.destructive, size: 48),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Limit Reached',
                  style: AppTextStyles.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  '5/5 Announcements — delete an old one to post a new announcement.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.base,
            right: AppSpacing.base,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.base,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _controller,
                label: 'Announcement Message',
                maxLines: 4,
                maxLength: 500,
                hint: 'Share updates or news with your group members...',
              ),
              const SizedBox(height: AppSpacing.base),
              const Text('Link to an upcoming Game (Optional)', style: AppTextStyles.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              gamesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Failed to load upcoming games'),
                data: (games) {
                  return DropdownButtonFormField<String?>(
                    value: _selectedGameId,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('None (no link)'),
                      ),
                      ...games.map((g) {
                        final sched = DateTime.parse(g['scheduled_at'] as String).toLocal();
                        final fmt = DateFormat('MMM d').format(sched);
                        return DropdownMenuItem<String?>(
                          value: g['id'] as String,
                          child: Text('${g['title']} ($fmt)'),
                        );
                      }),
                    ],
                    onChanged: (val) => setState(() => _selectedGameId = val),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Post Announcement',
                isLoading: _isSubmitting,
                onPressed: () => _submit(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    final msg = _controller.text.trim();
    if (msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final client = ref.read(supabaseClientProvider);

    try {
      await client.from('announcements').insert({
        'group_id': widget.groupId,
        'created_by': client.auth.currentUser!.id,
        'message': msg,
        'linked_game_id': _selectedGameId,
      });

      ref.invalidate(groupAnnouncementsProvider(widget.groupId));
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement posted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post announcement: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
