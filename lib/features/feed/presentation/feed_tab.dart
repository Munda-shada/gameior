import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gameior/core/constants/app_constants.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/feed/application/feed_providers.dart';
import 'package:gameior/features/payments/application/feed_dues_provider.dart';
import 'package:gameior/features/payments/data/payments_repository.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/shared/widgets/capacity_progress_bar.dart';
import 'package:gameior/shared/widgets/dues_hero_card.dart';
import 'package:gameior/shared/widgets/section_header.dart';

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
    final duesSummaryAsync = ref.watch(feedDuesSummaryProvider);
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
              child: _GreetingHeader(
                profileAsync: profileAsync,
                getGreeting: _getGreeting,
              ),
            ),

            // ── Outstanding Dues Hero ──────────────────────────
            SliverToBoxAdapter(
              child: duesSummaryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (summary) {
                  if (summary.totalPaise <= 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base, 0, AppSpacing.base, AppSpacing.base,
                    ),
                    child: DuesHeroCard(
                      amountPaise: summary.totalPaise,
                      label:
                          'You owe across ${summary.groupCount} group${summary.groupCount > 1 ? 's' : ''}',
                      ctaLabel: 'Pay',
                      onTap: () {
                        showAppBottomSheet(
                          context: context,
                          title: 'Outstanding Dues',
                          initialChildSizeRatio: 0.7,
                          child: _FeedDuesSheet(summary: summary),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // ── Upcoming Sessions ──────────────────────────────
            SliverToBoxAdapter(
              child: upcomingGamesAsync.when(
                loading: () => _SectionSkeleton(label: 'UPCOMING SESSIONS'),
                error: (_, __) => const SizedBox.shrink(),
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
                          (game) => _UpcomingSessionTile(
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
                  return _EmptyFeedState();
                },
              ),
            ),

            // ── Announcements ──────────────────────────────────
            SliverToBoxAdapter(
              child: announcementsAsync.when(
                loading: () => _SectionSkeleton(label: 'ANNOUNCEMENTS'),
                error: (_, __) => const SizedBox.shrink(),
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
                          (item) => _AnnouncementTile(item: item),
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

// ─────────────────────────────────────────────────────────────────────────────
// Greeting Header
// ─────────────────────────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  final AsyncValue<dynamic> profileAsync;
  final String Function() getGreeting;

  const _GreetingHeader({required this.profileAsync, required this.getGreeting});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.base,
        left: AppSpacing.base,
        right: AppSpacing.base,
        bottom: AppSpacing.base,
      ),
      child: profileAsync.when(
        loading: () => const SizedBox(height: 56),
        error: (_, __) => const SizedBox(height: 56),
        data: (profile) {
          final name = profile?.displayName ?? '';
          final emoji = profile?.emoji ?? '🏸';
          final greeting = getGreeting();

          return Row(
            children: [
              // Emoji avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      name.isEmpty ? 'Welcome back!' : name,
                      style: AppTextStyles.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming Session Tile
// ─────────────────────────────────────────────────────────────────────────────

class _UpcomingSessionTile extends StatelessWidget {
  final Map<String, dynamic> game;
  final String? userId;

  const _UpcomingSessionTile({required this.game, required this.userId});

  @override
  Widget build(BuildContext context) {
    final gameId = game['id'] as String;
    final groupId = game['group_id'] as String;
    final title = game['title'] as String? ?? 'Match Session';
    final venue = game['venue'] as String? ?? '';
    final scheduledAt = DateTime.parse(game['scheduled_at'] as String).toLocal();
    final capacity = (game['max_capacity'] as num?)?.toInt() ?? 20;
    final costPaise = (game['cost_paise'] as num?)?.toInt() ?? 0;
    final paymentModel = game['payment_model'] as String? ?? 'prepaid';
    final isLocked = game['rsvp_locked'] as bool? ?? false;
    final rsvpDeadline = game['rsvp_deadline'] != null
        ? DateTime.parse(game['rsvp_deadline'] as String)
        : null;
    final deadlinePassed =
        rsvpDeadline != null && DateTime.now().toUtc().isAfter(rsvpDeadline);

    final groupInfo = game['groups'] as Map<String, dynamic>? ?? {};
    final groupName = groupInfo['name'] as String? ?? '';

    final rsvps = game['rsvps'] as List? ?? [];

    // Calculate confirmed count
    final confirmedCount = rsvps.fold<int>(0, (sum, r) {
      final s = r['status'] as String? ?? '';
      if (s == 'yes' || s == 'guest') {
        final isPlaying = r['user_is_playing'] as bool? ?? true;
        final guests = (r['guest_count'] as num?)?.toInt() ?? 0;
        return sum + (isPlaying ? 1 : 0) + guests;
      }
      return sum;
    });

    // Find my RSVP
    final myRsvp = rsvps.firstWhere(
      (r) => r['user_id'] == userId,
      orElse: () => null,
    );
    final myStatus = myRsvp != null ? myRsvp['status'] as String? ?? 'unanswered' : 'unanswered';
    final myWaitlistPos = myRsvp != null ? myRsvp['waitlist_position'] as int? : null;

    // Format time
    final now = DateTime.now();
    final isToday = scheduledAt.day == now.day &&
        scheduledAt.month == now.month &&
        scheduledAt.year == now.year;
    final isTomorrow = scheduledAt.day == now.add(const Duration(days: 1)).day &&
        scheduledAt.month == now.add(const Duration(days: 1)).month &&
        scheduledAt.year == now.add(const Duration(days: 1)).year;

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today, ${DateFormat('h:mm a').format(scheduledAt)}';
    } else if (isTomorrow) {
      dateLabel = 'Tomorrow, ${DateFormat('h:mm a').format(scheduledAt)}';
    } else {
      dateLabel = DateFormat('EEE d MMM, h:mm a').format(scheduledAt);
    }

    // RSVP badge config
    _RsvpBadgeConfig badgeConfig = _rsvpBadge(myStatus, myWaitlistPos);

    // Cost label
    final costLabel = paymentModel == 'prepaid' && costPaise > 0
        ? '₹${(costPaise / 100).toStringAsFixed(0)}'
        : paymentModel == 'postpaid'
            ? 'Split after'
            : 'Free';

    return GestureDetector(
      onTap: () => context.push('/group/$groupId/game/$gameId'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Top: colored status strip
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: badgeConfig.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group name + lock icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          groupName.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      if (isLocked || deadlinePassed)
                        const Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: AppColors.textDisabled,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Title
                  Text(
                    title,
                    style: AppTextStyles.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Date + venue row
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(dateLabel,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                  if (venue.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            venue,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  // Capacity bar
                  CapacityProgressBar(
                    confirmed: confirmedCount,
                    capacity: capacity,
                    showLabel: false,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Bottom row: cost + RSVP badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cost chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          costLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      // RSVP status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeConfig.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: badgeConfig.color.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              badgeConfig.icon,
                              size: 11,
                              color: badgeConfig.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              badgeConfig.label,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: badgeConfig.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RsvpBadgeConfig {
  final String label;
  final Color color;
  final IconData icon;
  const _RsvpBadgeConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}

_RsvpBadgeConfig _rsvpBadge(String status, int? waitlistPos) {
  switch (status) {
    case 'yes':
    case 'guest':
      return _RsvpBadgeConfig(
        label: 'Confirmed',
        color: AppColors.primary,
        icon: Icons.check_circle_outline,
      );
    case 'waitlist':
      final pos = waitlistPos != null ? ' #$waitlistPos' : '';
      return _RsvpBadgeConfig(
        label: 'Waitlist$pos',
        color: AppColors.waitlist,
        icon: Icons.hourglass_top_outlined,
      );
    case 'maybe':
      return _RsvpBadgeConfig(
        label: 'Maybe',
        color: AppColors.waitlist,
        icon: Icons.help_outline,
      );
    case 'no':
      return _RsvpBadgeConfig(
        label: 'Not Going',
        color: AppColors.textDisabled,
        icon: Icons.cancel_outlined,
      );
    default:
      return _RsvpBadgeConfig(
        label: "Not RSVP'd yet",
        color: AppColors.unanswered,
        icon: Icons.radio_button_unchecked,
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Announcement Tile
// ─────────────────────────────────────────────────────────────────────────────

class _AnnouncementTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _AnnouncementTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final message = item['message'] as String? ?? '';
    final groupInfo = item['groups'] as Map<String, dynamic>? ?? {};
    final groupName = groupInfo['name'] as String? ?? 'Group';
    final profile = item['profiles'] as Map<String, dynamic>? ?? {};
    final senderName = profile['display_name'] as String? ?? 'Organizer';
    final emoji = profile['emoji'] as String? ?? '📣';
    final createdAt = DateTime.parse(item['created_at'] as String).toLocal();
    final linkedGameId = item['linked_game_id'] as String?;
    final groupId = item['group_id'] as String?;

    // Relative time
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    String timeLabel;
    if (diff.inMinutes < 60) {
      timeLabel = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      timeLabel = '${diff.inHours}h ago';
    } else {
      timeLabel = DateFormat('d MMM').format(createdAt);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: emoji + name + group + time
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(senderName, style: AppTextStyles.labelLarge),
                    Text(
                      '$groupName · $timeLabel',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Message
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          // Deep link to game if present
          if (linkedGameId != null && groupId != null) ...[
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => context.push('/group/$groupId/game/$linkedGameId'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sports_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'View Game Session →',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Feed State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyFeedState extends StatelessWidget {
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
            decoration: BoxDecoration(
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
          Text(
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

// ─────────────────────────────────────────────────────────────────────────────
// Loading skeleton for sections
// ─────────────────────────────────────────────────────────────────────────────

class _SectionSkeleton extends StatelessWidget {
  final String label;
  const _SectionSkeleton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: label),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.border.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dues Payment Bottom Sheet (from Feed hero tap)
// ─────────────────────────────────────────────────────────────────────────────

class _FeedDuesSheet extends ConsumerStatefulWidget {
  final FeedDuesSummary summary;
  const _FeedDuesSheet({required this.summary});

  @override
  ConsumerState<_FeedDuesSheet> createState() => _FeedDuesSheetState();
}

class _FeedDuesSheetState extends ConsumerState<_FeedDuesSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        0,
        AppSpacing.base,
        AppSpacing.base,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pay dues across ${widget.summary.groupCount} group${widget.summary.groupCount > 1 ? 's' : ''}',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.base),
          ...widget.summary.groupBreakdown.map(
            (breakdown) => _GroupDuesCard(breakdown: breakdown),
          ),
        ],
      ),
    );
  }
}

class _GroupDuesCard extends ConsumerStatefulWidget {
  final GroupDueSummary breakdown;
  const _GroupDuesCard({required this.breakdown});

  @override
  ConsumerState<_GroupDuesCard> createState() => _GroupDuesCardState();
}

class _GroupDuesCardState extends ConsumerState<_GroupDuesCard> {
  final _formKey = GlobalKey<FormState>();
  final _utrController = TextEditingController();
  bool _isSubmitting = false;
  String _upiId = '';

  @override
  void initState() {
    super.initState();
    _loadUpi();
  }

  @override
  void dispose() {
    _utrController.dispose();
    super.dispose();
  }

  Future<void> _loadUpi() async {
    final client = ref.read(supabaseClientProvider);
    try {
      final res = await client
          .from('groups')
          .select('default_upi_id')
          .eq('id', widget.breakdown.groupId)
          .single();
      if (mounted) {
        setState(() => _upiId = res['default_upi_id'] as String? ?? '');
      }
    } catch (_) {}
  }

  Future<void> _launchUpi() async {
    if (_upiId.isEmpty) return;
    final amount = (widget.breakdown.pendingPaise / 100.0).toStringAsFixed(2);
    final uri = Uri.parse(
      'upi://pay?pa=$_upiId&am=$amount&tn=${Uri.encodeComponent(widget.breakdown.groupName)}&cu=INR',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No UPI app found. Copy the UPI ID and pay manually.')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final client = ref.read(supabaseClientProvider);
    final repo = ref.read(paymentsRepositoryProvider);
    final utr = _utrController.text.trim();

    try {
      final userId = client.auth.currentUser!.id;
      final response = await client
          .from('payment_dues')
          .select('id')
          .eq('group_id', widget.breakdown.groupId)
          .eq('player_id', userId)
          .eq('status', 'unpaid')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) throw Exception('No pending dues found.');

      await repo.submitUtr(
        dueId: response['id'] as String,
        utrReference: utr,
      );

      ref.invalidate(feedDuesSummaryProvider);

      if (mounted) {
        _utrController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment submitted — awaiting host verification.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rupees = (widget.breakdown.pendingPaise / 100.0).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group name + amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.breakdown.groupName,
                    style: AppTextStyles.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '₹$rupees',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.destructive,
                  ),
                ),
              ],
            ),
            Text(
              '${widget.breakdown.unpaidCount} unpaid game${widget.breakdown.unpaidCount > 1 ? 's' : ''}',
              style: AppTextStyles.caption,
            ),
            const Divider(height: AppSpacing.lg),
            // UPI row
            if (_upiId.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _upiId,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: AppColors.textSecondary),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _upiId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('UPI ID copied')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text('Open UPI App · ₹$rupees'),
                  onPressed: _launchUpi,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
            ],
            // UTR field
            AppTextField(
              controller: _utrController,
              label: '12-digit UTR reference',
              hint: '408712345678',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'UTR is required';
                if (v.length != 12) return 'Must be exactly 12 digits';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Confirm Payment',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}