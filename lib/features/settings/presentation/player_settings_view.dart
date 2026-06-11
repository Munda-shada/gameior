import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/settings/application/group_settings_providers.dart';
import 'package:gameior/features/groups/application/groups_provider.dart';
import 'package:gameior/features/groups/domain/group.dart';
import 'package:gameior/features/members/data/members_repository.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_dialog.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/section_header.dart';
import 'package:gameior/core/utils/app_toast.dart';

class PlayerSettingsView extends ConsumerStatefulWidget {
  final Group group;
  final String groupId;

  const PlayerSettingsView({
    required this.group,
    required this.groupId,
    super.key,
  });

  @override
  ConsumerState<PlayerSettingsView> createState() => _PlayerSettingsViewState();
}

class _PlayerSettingsViewState extends ConsumerState<PlayerSettingsView> {
  bool _notificationsEnabled = true; // Local UI preference setting
  bool _isInit = true;

  Future<void> _leaveGroup() async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    // 1. Check for unpaid dues first
    final repository = ref.read(membersRepositoryProvider);
    final hasDues = await repository.hasUnpaidDues(
      groupId: widget.groupId,
      userId: userId,
    );

    if (hasDues) {
      if (context.mounted) {
        showAppDialog(
          context: context,
          title: 'Unpaid Dues Pending',
          message: 'You cannot leave this group because you have outstanding unpaid or pending verification dues. Please settle them in the Payments tab first.',
          confirmLabel: 'OK',
        );
      }
      return;
    }

    // 2. Propose confirmation dialog to leave
    if (!context.mounted) return;
    final confirm = await showAppDialog(
      context: context,
      title: 'Leave Group?',
      message: 'Are you sure you want to leave this group? You will need an invite code to join again.',
      confirmLabel: 'Leave',
      isDestructive: true,
    );

    if (confirm == true) {
      try {
        await client
            .from('group_members')
            .update({'status': 'left'})
            .eq('group_id', widget.groupId)
            .eq('user_id', userId);

        ref.invalidate(myGroupsNotifierProvider);
        if (context.mounted) {
          context.go('/home/groups');
          showToast(context, 'You have left the group.');
        }
      } catch (e) {
        if (context.mounted) {
          showToast(context, 'Failed to leave the group.', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostProfileAsync = ref.watch(hostProfileProvider(widget.group.hostId));
    final matchesPlayedAsync = ref.watch(matchesPlayedProvider(widget.groupId));
    final groupCtx = ref.watch(groupContextProvider(widget.groupId)).valueOrNull;
    if (groupCtx != null && _isInit) {
      _notificationsEnabled = groupCtx.notificationsEnabled;
      _isInit = false;
    }

    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Stats Hero
          matchesPlayedAsync.when(
            loading: () => const SizedBox(
              height: 80,
              child: AppLoadingShimmer(type: ShimmerType.card),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (count) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.base),
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events_outlined, color: theme.colorScheme.onPrimary, size: 40),
                    const SizedBox(width: AppSpacing.base),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count',
                          style: theme.textTheme.displayLarge?.copyWith(color: theme.colorScheme.onPrimary),
                        ),
                        Text(
                          'Matches Played in Club',
                          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimary.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // 2. Preferences
          const SectionHeader(title: 'PREFERENCES'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: SwitchListTile.adaptive(
              title: Text('Group Notifications', style: theme.textTheme.headlineSmall),
              subtitle: Text('Get push notifications for this group\'s games', style: theme.textTheme.bodySmall),
              value: _notificationsEnabled,
              activeThumbColor: theme.colorScheme.primary,
              onChanged: (val) async {
                setState(() => _notificationsEnabled = val);
                final client = ref.read(supabaseClientProvider);
                final userId = client.auth.currentUser?.id;
                if (userId != null) {
                  try {
                    await client
                        .from('group_members')
                        .update({'notifications_enabled': val})
                        .eq('group_id', widget.groupId)
                        .eq('user_id', userId);
                    ref.invalidate(groupContextProvider(widget.groupId));
                    if (context.mounted) {
                      showToast(context, 'Notifications ${val ? 'enabled' : 'disabled'} for this group.');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showToast(context, 'Failed to update preferences: $e', isError: true);
                    }
                  }
                }
              },
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // 3. Read-Only Info
          const SectionHeader(title: 'CLUB INFORMATION'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: hostProfileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Could not fetch organizer contact details'),
              data: (host) {
                final orgName = host?['display_name'] as String? ?? 'Organizer';
                final orgPhone = host?['phone'] as String? ?? 'No contact number';
                final hasUpi = widget.group.defaultUpiId != null && widget.group.defaultUpiId!.isNotEmpty;

                return Column(
                  children: [
                    _buildInfoRow('Sport Type', widget.group.sport.name.toUpperCase()),
                    const Divider(height: AppSpacing.base),
                    _buildInfoRow('Organizer Name', orgName),
                    const Divider(height: AppSpacing.base),
                    _buildInfoRow('Organizer Contact', orgPhone),
                    const Divider(height: AppSpacing.base),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Default UPI ID', style: theme.textTheme.bodySmall),
                              const SizedBox(height: 2),
                              Text(widget.group.defaultUpiId ?? 'None', style: theme.textTheme.headlineSmall),
                            ],
                          ),
                        ),
                        if (hasUpi)
                          IconButton(
                            icon: Icon(Icons.copy, color: theme.colorScheme.primary),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: widget.group.defaultUpiId!));
                              showToast(context, 'UPI ID copied to clipboard!');
                            },
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // 4. Club Rules
          const SectionHeader(title: 'CLUB RULES & GUIDELINES'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Text(
              widget.group.clubRules?.isNotEmpty == true
                  ? widget.group.clubRules!
                  : 'No rules set by organizer yet.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // 5. Danger Zone (Player)
          const SectionHeader(title: 'DANGER ZONE'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leave Group', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.error)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Leaving the group removes your access to the game calendar, announcements, and match history.',
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.error),
                ),
                const SizedBox(height: AppSpacing.base),
                AppButton(
                  label: 'Leave Group',
                  variant: AppButtonVariant.destructive,
                  onPressed: _leaveGroup,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: theme.textTheme.headlineSmall),
        ],
      ),
    );
  }
}
