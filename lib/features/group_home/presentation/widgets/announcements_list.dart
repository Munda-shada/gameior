import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
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
                              decoration: const BoxDecoration(
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
      ],
    );
  }
}
