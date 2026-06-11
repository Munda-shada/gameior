import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/group_home/application/group_home_providers.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/section_header.dart';
import 'package:gameior/features/sessions/application/rsvp_notifier.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/core/utils/app_toast.dart';

class NextGamePreview extends ConsumerWidget {
  final String groupId;
  final bool isAdmin;

  const NextGamePreview({
    required this.groupId,
    required this.isAdmin,
    super.key,
  });

  Future<void> _updateRsvp(
    BuildContext context,
    WidgetRef ref,
    String gameId,
    RsvpStatus status,
  ) async {
    try {
      await ref.read(myRsvpNotifierProvider(gameId).notifier).updateRsvp(status: status);
      if (context.mounted) {
        showToast(
          context,
          status == RsvpStatus.yes ? 'RSVP set to Going!' : 'RSVP set to Skip!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context, 'Failed to update RSVP: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final nextGameAsync = ref.watch(nextGroupGameProvider(groupId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'NEXT SESSION'),
        const SizedBox(height: AppSpacing.xs),
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
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 36,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No sessions scheduled yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
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

            final gameId = game['id'] as String;
            final rsvpStateAsync = ref.watch(myRsvpNotifierProvider(gameId));
            final scheduledAt = DateTime.parse(game['scheduled_at'] as String).toLocal();
            final formattedTime = DateFormat('EEE, MMM d • h:mm a').format(scheduledAt);
            final desc = game['description'] as String?;

            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.lg),
                      topRight: Radius.circular(AppRadius.lg),
                    ),
                    onTap: () => context.push('/group/$groupId/game/$gameId'),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('🏸', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      game['title'] as String? ?? 'Match Session',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formattedTime,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                          const Divider(height: AppSpacing.lg),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  game['venue'] as String? ?? 'Default venue',
                                  style: theme.textTheme.bodyMedium,
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
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // RSVP action buttons row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      0,
                      AppSpacing.base,
                      AppSpacing.base,
                    ),
                    child: rsvpStateAsync.when(
                      loading: () => const SizedBox(
                        height: 36,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      error: (err, _) => const Text('Could not load RSVP details'),
                      data: (rsvpState) {
                        final isGoing = rsvpState.status == RsvpStatus.yes || rsvpState.status == RsvpStatus.guest;
                        final isSkipped = rsvpState.status == RsvpStatus.no;
                        final isUpdating = rsvpState.isUpdating;

                        return Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isGoing
                                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                      : null,
                                  side: BorderSide(
                                    color: isGoing
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline.withValues(alpha: 0.5),
                                    width: isGoing ? 2.0 : 1.0,
                                  ),
                                ),
                                onPressed: isUpdating
                                    ? null
                                    : () => _updateRsvp(context, ref, gameId, RsvpStatus.yes),
                                icon: isUpdating && isGoing
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Icon(
                                        Icons.check_circle_outline,
                                        size: 16,
                                        color: isGoing
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                label: Text(
                                  'Going',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isGoing
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isSkipped
                                      ? theme.colorScheme.error.withValues(alpha: 0.1)
                                      : null,
                                  side: BorderSide(
                                    color: isSkipped
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.outline.withValues(alpha: 0.5),
                                    width: isSkipped ? 2.0 : 1.0,
                                  ),
                                ),
                                onPressed: isUpdating
                                    ? null
                                    : () => _updateRsvp(context, ref, gameId, RsvpStatus.no),
                                icon: isUpdating && isSkipped
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Icon(
                                        Icons.cancel_outlined,
                                        size: 16,
                                        color: isSkipped
                                            ? theme.colorScheme.error
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                label: Text(
                                  'Skip',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isSkipped
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
