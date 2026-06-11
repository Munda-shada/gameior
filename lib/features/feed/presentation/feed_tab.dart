import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/constants/app_constants.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/feed/application/feed_providers.dart';
import 'package:gameior/features/payments/application/feed_dues_provider.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/section_header.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';

// Split widgets imports
import 'package:gameior/features/feed/presentation/widgets/greeting_header.dart';
import 'package:gameior/features/feed/presentation/widgets/feed_dues_section.dart';
import 'package:gameior/features/feed/presentation/widgets/feed_upcoming_sessions.dart';
import 'package:gameior/features/feed/presentation/widgets/feed_announcements.dart';
import 'package:gameior/features/feed/presentation/widgets/announcement_card.dart';

class FeedTab extends ConsumerStatefulWidget {
  const FeedTab({super.key});

  @override
  ConsumerState<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<FeedTab> {
  bool _showAllSessions = false;
  bool _showAllAnnouncements = false;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProvider);
    final upcomingGamesAsync = ref.watch(feedUpcomingGamesProvider);
    final announcementsAsync = ref.watch(feedAnnouncementsProvider);
    final userId = ref.watch(supabaseClientProvider).auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(feedDuesSummaryProvider);
          ref.invalidate(feedUpcomingGamesProvider);
          ref.invalidate(feedAnnouncementsProvider);
          ref.invalidate(currentUserProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── App Bar with greeting ──────────────────────────
            SliverToBoxAdapter(
              child: GreetingHeader(
                profileAsync: profileAsync,
                getGreeting: _getGreeting,
              ),
            ),

            // ── Outstanding Dues Hero ──────────────────────────
            const SliverToBoxAdapter(
              child: FeedDuesSection(),
            ),

            // ── Upcoming Sessions ──────────────────────────────
            SliverToBoxAdapter(
              child: upcomingGamesAsync.when(
                loading: () => const SectionSkeleton(
                  label: 'UPCOMING SESSIONS',
                  shimmerType: ShimmerType.gameCard,
                ),
                error: (e, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                  child: AppErrorState(
                    message: 'Failed to load upcoming sessions',
                    onRetry: () => ref.invalidate(feedUpcomingGamesProvider),
                  ),
                ),
                data: (games) {
                  if (games.isEmpty) return const SizedBox.shrink();

                  final displayCount =
                      _showAllSessions ? games.length : AppConstants.feedUpcomingGamesLimit;
                  final displayGames = games.take(displayCount).toList();
                  final hasMore = games.length > AppConstants.feedUpcomingGamesLimit;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SectionHeader(title: 'UPCOMING SESSIONS'),
                            if (hasMore)
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  setState(() => _showAllSessions = !_showAllSessions);
                                },
                                child: Text(
                                  _showAllSessions
                                      ? 'Show Less'
                                      : 'See All (${games.length})',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...displayGames.map(
                          (game) => UpcomingSessionTile(
                            game: game,
                            userId: userId,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Empty state when no sessions and no groups ─────
            SliverToBoxAdapter(
              child: upcomingGamesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (games) {
                  if (games.isNotEmpty) return const SizedBox.shrink();
                  return const _EmptyFeedState();
                },
              ),
            ),

            // ── Announcements ──────────────────────────────────
            SliverToBoxAdapter(
              child: announcementsAsync.when(
                loading: () => const SectionSkeleton(
                  label: 'ANNOUNCEMENTS',
                  shimmerType: ShimmerType.card,
                ),
                error: (e, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                  child: AppErrorState(
                    message: 'Failed to load announcements',
                    onRetry: () => ref.invalidate(feedAnnouncementsProvider),
                  ),
                ),
                data: (announcements) {
                  if (announcements.isEmpty) return const SizedBox.shrink();

                  final displayCount =
                      _showAllAnnouncements ? announcements.length : 1;
                  final displayItems = announcements.take(displayCount).toList();
                  final hasMore = announcements.length > 1;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SectionHeader(title: 'ANNOUNCEMENTS'),
                            if (hasMore)
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showAllAnnouncements = !_showAllAnnouncements;
                                  });
                                },
                                child: Text(
                                  _showAllAnnouncements
                                      ? 'Show Less'
                                      : 'View All (${announcements.length})',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...displayItems.map(
                          (item) => AnnouncementCard(item: item),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty Feed State ─────────────────────────────────────────────────────────

class _EmptyFeedState extends StatelessWidget {
  const _EmptyFeedState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxxl,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryMuted,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🏸', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          const Text(
            'Your court is empty',
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Join a group or create one to start scheduling games with your crew.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                label: 'Browse Groups',
                variant: AppButtonVariant.secondary,
                isFullWidth: false,
                onPressed: () => context.go('/home/groups'),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: 'Create Group',
                isFullWidth: false,
                onPressed: () => context.push('/home/groups/create'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}