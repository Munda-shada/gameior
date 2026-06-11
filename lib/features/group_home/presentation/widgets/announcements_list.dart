import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/group_home/application/group_home_providers.dart';
import 'package:gameior/shared/widgets/app_dialog.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/core/utils/app_toast.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class AnnouncementsList extends ConsumerWidget {
  final String groupId;
  final bool isAdmin;
  final VoidCallback onPostAnnouncement;

  const AnnouncementsList({
    required this.groupId,
    required this.isAdmin,
    required this.onPostAnnouncement,
    super.key,
  });

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
          showToast(context, 'Announcement deleted!');
        }
      } catch (e) {
        if (context.mounted) {
          showToast(context, 'Failed to delete announcement.', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final announcementsAsync = ref.watch(groupAnnouncementsProvider(groupId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                onPressed: onPostAnnouncement,
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
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    'No announcements posted yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
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
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(emoji, style: const TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    senderName,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formattedTime,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isAdmin)
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: theme.colorScheme.error,
                                  size: 20,
                                ),
                                onPressed: () => _deleteAnnouncement(context, ref, item['id'] as String),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          message,
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (linkedGameId != null && linkedGameId.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ActionChip(
                              avatar: Icon(
                                Icons.calendar_month,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              label: Text(
                                'View Game Session',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () => context.push('/group/$groupId/game/$linkedGameId'),
                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                              side: BorderSide(
                                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              ),
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
      ],
    );
  }
}
