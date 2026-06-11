import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/group_home/application/group_home_providers.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/core/utils/app_toast.dart';

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
                onPressed: _submit,
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
      showToast(context, 'Please enter a message.', isError: true);
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
        showToast(context, 'Announcement posted successfully!');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Failed to post announcement: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
