import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/utils/app_toast.dart';

import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/settings/application/group_settings_providers.dart';
import 'package:gameior/features/sessions/application/sessions_providers.dart';
import 'package:gameior/features/sessions/data/sessions_repository.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_dialog.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';

// Split widgets imports
import 'package:gameior/features/sessions/presentation/widgets/guest_dialog.dart';
import 'package:gameior/features/sessions/presentation/widgets/game_header_card.dart';
import 'package:gameior/features/sessions/presentation/widgets/cost_details_card.dart';
import 'package:gameior/features/sessions/presentation/widgets/rsvp_section.dart';
import 'package:gameior/features/sessions/presentation/widgets/roster_section.dart';
import 'package:gameior/features/sessions/presentation/widgets/waitlist_section.dart';
import 'package:gameior/features/sessions/presentation/widgets/organizer_contact_card.dart';
import 'package:gameior/features/sessions/presentation/widgets/bottom_cta_panel.dart';

class GameDetailScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String gameId;
  const GameDetailScreen({required this.groupId, required this.gameId, super.key});

  @override
  ConsumerState<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends ConsumerState<GameDetailScreen> {
  bool _isRsvpUpdating = false;

  Future<void> _handleRsvpChanged(
    RsvpStatus newStatus,
    Map<String, dynamic> game,
    int confirmedCount,
    RsvpStatus? oldStatus,
  ) async {
    final maxCapacity = (game['max_capacity'] as num).toInt();

    // 1. Waitlist check for YES
    if (newStatus == RsvpStatus.yes) {
      if (confirmedCount >= maxCapacity && oldStatus != RsvpStatus.yes) {
        final confirmWaitlist = await showAppDialog(
          context: context,
          title: 'Session Full',
          message: 'This session is currently full. Would you like to join the waitlist?',
          confirmLabel: 'Join Waitlist',
        );
        if (confirmWaitlist != true) return;
      }
      await _submitRsvp(newStatus);
    } 
    // 2. Guest config modal for GUEST
    else if (newStatus == RsvpStatus.guest) {
      final guestConfig = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => GuestDialog(
          maxGuests: 5,
          remainingSpots: maxCapacity - confirmedCount,
        ),
      );
      if (guestConfig == null) return;
      await _submitRsvp(
        newStatus,
        guestCount: guestConfig['guestCount'] as int,
        userIsPlaying: guestConfig['userIsPlaying'] as bool,
      );
    } 
    // 3. NO / MAYBE
    else {
      await _submitRsvp(newStatus);
    }
  }

  Future<void> _submitRsvp(RsvpStatus status, {int guestCount = 0, bool userIsPlaying = true}) async {
    setState(() => _isRsvpUpdating = true);
    final repo = ref.read(sessionsRepositoryProvider);
    try {
      final result = await repo.submitRsvp(
        gameId: widget.gameId,
        status: status,
        guestCount: guestCount,
        userIsPlaying: userIsPlaying,
      );

      ref.invalidate(gameDetailProvider(widget.gameId));
      ref.invalidate(upcomingGamesProvider(widget.groupId));

      if (mounted) {
        final finalStatus = result['status'] as String?;
        if (finalStatus == 'waitlist') {
          final pos = result['waitlist_position'] != null ? '#${result['waitlist_position']}' : '';
          showToast(context, 'Session full — you\'re on the waitlist at $pos');
        } else {
          showToast(context, 'RSVP submitted successfully!');
        }
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Failed to update RSVP: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isRsvpUpdating = false);
      }
    }
  }

  Future<void> _toggleLock(bool isLocked) async {
    final repo = ref.read(sessionsRepositoryProvider);
    try {
      await repo.lockRsvp(widget.gameId, isLocked);
      ref.invalidate(gameDetailProvider(widget.gameId));
      if (mounted) {
        showToast(context, isLocked ? 'RSVPs Locked!' : 'RSVPs Unlocked!');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Failed to lock/unlock RSVPs.', isError: true);
      }
    }
  }

  Future<void> _cancelGame() async {
    final confirm = await showAppDialog(
      context: context,
      title: 'Cancel Game Session?',
      message: 'Are you sure you want to cancel this match? Players will be notified and unpaid dues will be deleted.',
      confirmLabel: 'Cancel Match',
      isDestructive: true,
    );

    if (confirm == true) {
      final repo = ref.read(sessionsRepositoryProvider);
      try {
        await repo.cancelGame(widget.gameId);
        ref.invalidate(gameDetailProvider(widget.gameId));
        ref.invalidate(upcomingGamesProvider(widget.groupId));
        if (mounted) {
          showToast(context, 'Game session cancelled.');
        }
      } catch (e) {
        if (mounted) {
          showToast(context, 'Failed to cancel game.', isError: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(gameDetailProvider(widget.gameId));
    final groupCtxAsync = ref.watch(groupContextProvider(widget.groupId));
    final currentUserId = ref.watch(supabaseClientProvider).auth.currentUser?.id;

    return detailAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Game Details')),
        body: AppErrorState(
          message: 'Failed to load game details',
          onRetry: () => ref.invalidate(gameDetailProvider(widget.gameId)),
        ),
      ),
      data: (game) {
        final title = game['title'] as String? ?? 'Match Session';
        final status = game['status'] as String? ?? 'upcoming';
        final venue = game['venue'] as String? ?? 'Venue';
        final desc = game['description'] as String?;
        final scheduledAt = DateTime.parse(game['scheduled_at'] as String).toLocal();
        final duration = (game['duration_minutes'] as num?)?.toInt() ?? 90;
        final capacity = (game['max_capacity'] as num?)?.toInt() ?? 20;
        final costPaise = (game['cost_paise'] as num?)?.toInt() ?? 0;
        final paymentModel = game['payment_model'] as String? ?? 'prepaid';
        final isLocked = game['rsvp_locked'] as bool? ?? false;
        final showBreakdown = game['show_cost_breakdown'] as bool? ?? false;
        final costItems = game['game_cost_items'] as List? ?? [];
        final rsvps = game['rsvps'] as List? ?? [];
        final dues = game['payment_dues'] as List? ?? [];

        final deadlineStr = game['rsvp_deadline'] != null
            ? DateFormat('MMM d, h:mm a').format(DateTime.parse(game['rsvp_deadline'] as String).toLocal())
            : null;

        // Calculate confirmed count
        final confirmedPlayers = rsvps.where((r) {
          final rStatus = r['status'] as String;
          return rStatus == 'yes' || rStatus == 'guest';
        }).toList();

        final confirmedCount = confirmedPlayers.fold<int>(0, (sum, r) {
          final isPlaying = r['user_is_playing'] as bool? ?? true;
          final guests = (r['guest_count'] as num?)?.toInt() ?? 0;
          return sum + (isPlaying ? 1 : 0) + guests;
        });

        // Calculate waitlisted players
        final waitlistedPlayers = rsvps.where((r) => r['status'] == 'waitlist').toList()
          ..sort((a, b) => (a['waitlist_position'] as int? ?? 999).compareTo(b['waitlist_position'] as int? ?? 999));

        // Find caller's RSVP
        final myRsvp = rsvps.firstWhere((r) => r['user_id'] == currentUserId, orElse: () => null);
        final RsvpStatus myStatus = myRsvp != null
            ? RsvpStatus.values.firstWhere((e) => e.name == myRsvp['status'], orElse: () => RsvpStatus.unanswered)
            : RsvpStatus.unanswered;

        return groupCtxAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, __) => const Scaffold(body: Center(child: Text('Failed to load group details'))),
          data: (groupContext) {
            final myRole = groupContext.myRole;
            final isAdmin = myRole == MemberRole.host || myRole == MemberRole.coHost;

            final isPast = status != 'upcoming';
            final deadlinePassed = game['rsvp_deadline'] != null &&
                DateTime.now().toUtc().isAfter(DateTime.parse(game['rsvp_deadline'] as String));
            final isRsvpClosed = isLocked || deadlinePassed || isPast;

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: const Text('Match Details'),
                actions: [
                  if (isAdmin)
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') {
                          context.push('/group/${widget.groupId}/create-game?edit=${widget.gameId}');
                        } else if (val == 'lock') {
                          _toggleLock(!isLocked);
                        } else if (val == 'cancel') {
                          _cancelGame();
                        } else if (val == 'complete') {
                          context.push('/group/${widget.groupId}/game/${widget.gameId}/complete');
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit Game')),
                        PopupMenuItem(value: 'lock', child: Text(isLocked ? 'Unlock RSVP' : 'Lock RSVP')),
                        if (status == 'upcoming')
                          const PopupMenuItem(value: 'cancel', child: Text('Cancel Game', style: TextStyle(color: AppColors.destructive))),
                        if (status == 'upcoming' && paymentModel == 'postpaid' && DateTime.now().isAfter(scheduledAt.add(Duration(minutes: duration))))
                          const PopupMenuItem(value: 'complete', child: Text('Mark as Completed')),
                      ],
                    ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      children: [
                        GameHeaderCard(
                          game: game,
                          status: status,
                          title: title,
                          venue: venue,
                          desc: desc,
                          duration: duration,
                        ),
                        const SizedBox(height: AppSpacing.base),

                        CostDetailsCard(
                          paymentModel: paymentModel,
                          costPaise: costPaise,
                          showBreakdown: showBreakdown,
                          costItems: costItems,
                        ),
                        const SizedBox(height: AppSpacing.base),

                        RsvpSection(
                          myStatus: myStatus,
                          isRsvpClosed: isRsvpClosed,
                          isRsvpUpdating: _isRsvpUpdating,
                          onRsvpChanged: (status) => _handleRsvpChanged(status, game, confirmedCount, myStatus),
                          deadlineStr: deadlineStr,
                        ),
                        const SizedBox(height: AppSpacing.base),

                        RosterSection(
                          confirmedCount: confirmedCount,
                          capacity: capacity,
                          confirmedPlayers: confirmedPlayers,
                        ),
                        const SizedBox(height: AppSpacing.base),

                        WaitlistSection(
                          waitlistedPlayers: waitlistedPlayers,
                        ),
                        const SizedBox(height: AppSpacing.base),

                        OrganizerContactCard(
                          hostId: game['payment_owner_id'] as String,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),

                  BottomCtaPanel(
                    groupId: widget.groupId,
                    gameId: widget.gameId,
                    gameStatus: status,
                    paymentModel: paymentModel,
                    isRsvpClosed: isRsvpClosed,
                    myStatus: myStatus,
                    dues: dues,
                    currentUserId: currentUserId,
                    onJoinGame: () => _handleRsvpChanged(RsvpStatus.yes, game, confirmedCount, myStatus),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}