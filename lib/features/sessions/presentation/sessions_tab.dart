import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:gameior/core/constants/app_constants.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/sessions/application/sessions_providers.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_empty_state.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';

class SessionsTab extends ConsumerStatefulWidget {
  final String groupId;
  const SessionsTab({required this.groupId, super.key});

  @override
  ConsumerState<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends ConsumerState<SessionsTab> {
  int _pastGamesLimit = AppConstants.pastGamesInitialLimit;

  @override
  Widget build(BuildContext context) {
    final contextAsync = ref.watch(groupContextProvider(widget.groupId));

    return contextAsync.when(
      loading: () => const Scaffold(body: AppLoadingShimmer(type: ShimmerType.listTile)),
      error: (e, _) => Scaffold(
        body: AppErrorState(
          message: 'Failed to load group sessions context',
          onRetry: () => ref.invalidate(groupContextProvider(widget.groupId)),
        ),
      ),
      data: (groupContext) {
        final myRole = groupContext.myRole;
        final isAdmin = myRole == MemberRole.host || myRole == MemberRole.coHost;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: AppColors.surface,
                child: const TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: [
                    Tab(text: 'Upcoming Games'),
                    Tab(text: 'Past Games'),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                _UpcomingGamesList(groupId: widget.groupId, isAdmin: isAdmin),
                _PastGamesList(
                  groupId: widget.groupId,
                  isAdmin: isAdmin,
                  limit: _pastGamesLimit,
                  onLoadMore: () {
                    setState(() {
                      _pastGamesLimit += AppConstants.pastGamesLoadMoreStep;
                    });
                  },
                ),
              ],
            ),
            floatingActionButton: isAdmin
                ? FloatingActionButton(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    onPressed: () => context.push('/group/${widget.groupId}/create-game'),
                    child: const Icon(Icons.add),
                  )
                : null,
          ),
        );
      },
    );
  }
}

class _UpcomingGamesList extends ConsumerWidget {
  final String groupId;
  final bool isAdmin;
  const _UpcomingGamesList({required this.groupId, required this.isAdmin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(upcomingGamesProvider(groupId));
    final client = ref.watch(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;

    return gamesAsync.when(
      loading: () => const AppLoadingShimmer(type: ShimmerType.card),
      error: (e, _) => AppErrorState(
        message: 'Failed to load upcoming games',
        onRetry: () => ref.invalidate(upcomingGamesProvider(groupId)),
      ),
      data: (games) {
        if (games.isEmpty) {
          if (isAdmin) {
            return AppEmptyState(
              icon: Icons.sports_outlined,
              message: 'Ready to schedule? Tap + to create your first session.',
              ctaLabel: 'Create Game',
              onCtaTap: () => context.push('/group/$groupId/create-game'),
            );
          } else {
            return const AppEmptyState(
              icon: Icons.sports_outlined,
              message: 'No sessions scheduled yet. Check back soon.',
            );
          }
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(upcomingGamesProvider(groupId)),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: games.length,
            itemBuilder: (ctx, index) {
              final game = games[index];
              return _GameSessionCard(groupId: groupId, game: game, userId: userId);
            },
          ),
        );
      },
    );
  }
}

class _PastGamesList extends ConsumerWidget {
  final String groupId;
  final bool isAdmin;
  final int limit;
  final VoidCallback onLoadMore;

  const _PastGamesList({
    required this.groupId,
    required this.isAdmin,
    required this.limit,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(pastGamesProvider(groupId: groupId, limit: limit));
    final hasPastAsync = ref.watch(hasPastGamesProvider(groupId));
    final client = ref.watch(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;

    return gamesAsync.when(
      loading: () => const AppLoadingShimmer(type: ShimmerType.listTile),
      error: (e, _) => AppErrorState(
        message: 'Failed to load past games',
        onRetry: () => ref.invalidate(pastGamesProvider(groupId: groupId, limit: limit)),
      ),
      data: (games) {
        if (games.isEmpty) {
          return const AppEmptyState(
            icon: Icons.history_outlined,
            message: 'No past sessions yet.',
          );
        }

        final showLoadMore = games.length >= limit;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pastGamesProvider(groupId: groupId, limit: limit));
            ref.invalidate(hasPastGamesProvider(groupId));
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (isAdmin)
                hasPastAsync.when(
                  data: (hasPast) {
                    if (!hasPast) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.base),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMuted,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Reuse settings from past games:', style: AppTextStyles.bodySmall),
                            TextButton.icon(
                              icon: const Icon(Icons.copy_all, size: 16),
                              label: const Text('Schedule from Template'),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              onPressed: () => context.push('/group/$groupId/create-game?template=true'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ...games.map((game) => _GameSessionCard(groupId: groupId, game: game, userId: userId)),
              if (showLoadMore) ...[
                const SizedBox(height: AppSpacing.base),
                OutlinedButton(
                  onPressed: onLoadMore,
                  child: const Text('Load Older Games'),
                ),
                const SizedBox(height: AppSpacing.xl),
              ]
            ],
          ),
        );
      },
    );
  }
}

class _GameSessionCard extends StatelessWidget {
  final String groupId;
  final Map<String, dynamic> game;
  final String? userId;

  const _GameSessionCard({
    required this.groupId,
    required this.game,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final gameId = game['id'] as String;
    final title = game['title'] as String? ?? 'Match Session';
    final scheduledAt = DateTime.parse(game['scheduled_at'] as String).toLocal();
    final formattedTime = DateFormat('EEE, MMM d • h:mm a').format(scheduledAt);
    final venue = game['venue'] as String? ?? 'Venue';
    final capacity = (game['max_capacity'] as num?)?.toInt() ?? 20;
    final costPaise = (game['cost_paise'] as num?)?.toInt() ?? 0;
    final paymentModel = game['payment_model'] as String? ?? 'prepaid';
    final status = game['status'] as String? ?? 'upcoming';

    final rsvps = game['rsvps'] as List? ?? [];
    
    // Calculate confirmed slots
    final confirmedCount = rsvps.fold<int>(0, (sum, r) {
      final rStatus = r['status'] as String? ?? 'unanswered';
      if (rStatus == 'yes' || rStatus == 'guest') {
        final isPlaying = r['user_is_playing'] as bool? ?? true;
        final guests = (r['guest_count'] as num?)?.toInt() ?? 0;
        return sum + (isPlaying ? 1 : 0) + guests;
      }
      return sum;
    });

    // Find current user's RSVP status
    String myRsvpStatusLabel = '';
    Color myRsvpColor = AppColors.textDisabled;
    final myRsvp = rsvps.firstWhere((r) => r['user_id'] == userId, orElse: () => null);
    if (myRsvp != null) {
      final rStatus = myRsvp['status'] as String? ?? 'unanswered';
      if (rStatus == 'yes') {
        myRsvpStatusLabel = 'Playing ✓';
        myRsvpColor = AppColors.primary;
      } else if (rStatus == 'no') {
        myRsvpStatusLabel = 'Not attending';
        myRsvpColor = AppColors.destructive;
      } else if (rStatus == 'maybe') {
        myRsvpStatusLabel = 'Maybe';
        myRsvpColor = AppColors.waitlist;
      } else if (rStatus == 'waitlist') {
        final pos = myRsvp['waitlist_position'] != null ? '#${myRsvp['waitlist_position']}' : '';
        myRsvpStatusLabel = 'Waitlist $pos';
        myRsvpColor = AppColors.waitlist;
      } else if (rStatus == 'guest') {
        myRsvpStatusLabel = 'Guest Added';
        myRsvpColor = AppColors.primary;
      }
    }

    final String costLabel = paymentModel == 'prepaid'
        ? '₹${(costPaise / 100).toStringAsFixed(0)}'
        : 'Post-paid (Split)';

    final Color statusColor = status == 'upcoming'
        ? AppColors.primary
        : (status == 'completed' ? Colors.blue : AppColors.textDisabled);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => context.push('/group/$groupId/game/$gameId'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(formattedTime, style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      venue,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$confirmedCount / $capacity players',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(costLabel, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (myRsvpStatusLabel.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: myRsvpColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: myRsvpColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        myRsvpStatusLabel,
                        style: AppTextStyles.labelSmall.copyWith(color: myRsvpColor, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    Text(
                      'Unanswered',
                      style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
