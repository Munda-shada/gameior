import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/settings/application/group_settings_providers.dart';
import 'package:gameior/features/sessions/application/sessions_providers.dart';
import 'package:gameior/features/sessions/data/sessions_repository.dart';
import 'package:gameior/features/sessions/widgets/rsvp_buttons.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_dialog.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/section_header.dart';

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
        builder: (ctx) => _GuestDialog(
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Session full — you\'re on the waitlist at $pos')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('RSVP submitted successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update RSVP: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isLocked ? 'RSVPs Locked!' : 'RSVPs Unlocked!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to lock/unlock RSVPs.')),
        );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Game session cancelled.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to cancel game.')),
          );
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
        final formattedTime = DateFormat('EEEE, MMMM d • h:mm a').format(scheduledAt);
        final duration = (game['duration_minutes'] as num?)?.toInt() ?? 90;
        final capacity = (game['max_capacity'] as num?)?.toInt() ?? 20;
        final costPaise = (game['cost_paise'] as num?)?.toInt() ?? 0;
        final paymentModel = game['payment_model'] as String? ?? 'prepaid';
        final upiId = game['upi_id'] as String? ?? '';
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

        // Organizer Details
        final hostProfileAsync = ref.watch(hostProfileProvider(game['payment_owner_id'] as String));

        return groupCtxAsync.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, __) => const Scaffold(body: Center(child: Text('Failed to load group details'))),
          data: (groupContext) {
            final myRole = groupContext.myRole;
            final isAdmin = myRole == MemberRole.host || myRole == MemberRole.coHost;
            final isHost = myRole == MemberRole.host;

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
                        if (status == 'upcoming' && paymentModel == 'postpaid' && DateTime.now().isAfter(scheduledAt))
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
                        // Header info card
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    game['sport'].toString().toUpperCase(),
                                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: status == 'upcoming'
                                          ? AppColors.primaryMuted
                                          : (status == 'completed' ? Colors.blue[50] : Colors.grey[100]),
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        color: status == 'upcoming'
                                            ? AppColors.primaryDark
                                            : (status == 'completed' ? Colors.blue[800] : AppColors.textDisabled),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(title, style: AppTextStyles.displayMedium),
                              const SizedBox(height: AppSpacing.xs),
                              Text(formattedTime, style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                              Text('$duration mins session', style: AppTextStyles.bodySmall),
                              const Divider(height: AppSpacing.lg),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(venue, style: AppTextStyles.headlineSmall),
                                        if (game['maps_link'] != null && (game['maps_link'] as String).isNotEmpty)
                                          TextButton.icon(
                                            icon: const Icon(Icons.map_outlined, size: 16),
                                            label: const Text('Open in Google Maps', style: TextStyle(fontSize: 12)),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            onPressed: () => ref.read(supabaseClientProvider).functions.invoke(
                                                  'open_maps',
                                                  body: {'url': game['maps_link']},
                                                ), // Fallback handled by GoRouter or url_launcher
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (desc != null && desc.isNotEmpty) ...[
                                const Divider(height: AppSpacing.lg),
                                Text('Organizer Notes:', style: AppTextStyles.labelSmall),
                                const SizedBox(height: 4),
                                Text(desc, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),

                        // Cost details card
                        const SectionHeader(title: 'FEES & BREAKDOWN'),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Payment Model:', style: AppTextStyles.bodyMedium),
                                  Text(
                                    paymentModel == 'prepaid' ? 'PRE-PAID' : 'POST-PAID',
                                    style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                  ),
                                ],
                              ),
                              const Divider(height: AppSpacing.base),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    paymentModel == 'prepaid' ? 'Match Fee:' : 'Estimated Fee:',
                                    style: AppTextStyles.headlineSmall,
                                  ),
                                  Text(
                                    '₹${(costPaise / 100).toStringAsFixed(0)}',
                                    style: AppTextStyles.displayMedium.copyWith(color: AppColors.primaryDark),
                                  ),
                                ],
                              ),
                              if (showBreakdown && costItems.isNotEmpty) ...[
                                const Divider(height: AppSpacing.base),
                                const Text('Cost Breakdown:', style: AppTextStyles.labelSmall),
                                const SizedBox(height: AppSpacing.xs),
                                ...costItems.map((item) {
                                  final label = item['label'] as String? ?? 'Item';
                                  final amt = (item['amount_paise'] as num?)?.toInt() ?? 0;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(label, style: AppTextStyles.bodyMedium),
                                        Text('₹${(amt / 100).toStringAsFixed(0)}', style: AppTextStyles.bodySmall),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),

                        // RSVP Flow
                        const SectionHeader(title: 'YOUR RSVP'),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              RsvpButtons(
                                currentStatus: myStatus,
                                isLocked: _isRsvpUpdating || isRsvpClosed,
                                isLoading: _isRsvpUpdating,
                                onChanged: (status) => _handleRsvpChanged(status, game, confirmedCount, myStatus),
                              ),
                              if (deadlineStr != null && !isRsvpClosed) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'RSVP Deadline: $deadlineStr',
                                  style: AppTextStyles.caption.copyWith(color: AppColors.destructive, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),

                        // Roster Section
                        SectionHeader(title: 'PLAYERS CONFIRMED ($confirmedCount / $capacity)'),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (confirmedPlayers.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                                    child: Text('No players confirmed yet.', style: AppTextStyles.bodyMedium),
                                  ),
                                )
                              else
                                ...confirmedPlayers.map((r) {
                                  final prof = r['profiles'] as Map<String, dynamic>? ?? {};
                                  final name = prof['display_name'] as String? ?? 'Player';
                                  final emoji = prof['emoji'] as String? ?? '🏸';
                                  final guestCount = (r['guest_count'] as num?)?.toInt() ?? 0;
                                  final isPlaying = r['user_is_playing'] as bool? ?? true;

                                  final String guestLabel = guestCount > 0
                                      ? ' + $guestCount guest${guestCount > 1 ? 's' : ''}'
                                      : '';
                                  final String playingLabel = isPlaying ? '' : ' (guest only)';

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Text(emoji, style: const TextStyle(fontSize: 20)),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(
                                            '$name$guestLabel$playingLabel',
                                            style: AppTextStyles.bodyLarge,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),

                        // Waitlist Section
                        if (waitlistedPlayers.isNotEmpty) ...[
                          SectionHeader(title: 'WAITLIST (${waitlistedPlayers.length})'),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.base),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...waitlistedPlayers.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final r = entry.value;
                                  final prof = r['profiles'] as Map<String, dynamic>? ?? {};
                                  final name = prof['display_name'] as String? ?? 'Player';
                                  final emoji = prof['emoji'] as String? ?? '🏸';

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Text(emoji, style: const TextStyle(fontSize: 20)),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(name, style: AppTextStyles.bodyLarge),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.waitlistMuted,
                                            borderRadius: BorderRadius.circular(AppRadius.sm),
                                          ),
                                          child: Text(
                                            'W${idx + 1}',
                                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.waitlist, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.base),
                        ],

                        // Organizer details card
                        const SectionHeader(title: 'ORGANIZER CONTACT'),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: hostProfileAsync.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const Text('Could not fetch host profile'),
                            data: (host) {
                              final name = host?['display_name'] as String? ?? 'Organizer';
                              final phone = host?['phone'] as String? ?? 'No contact info';

                              return Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 24, color: AppColors.primary),
                                  const SizedBox(width: AppSpacing.sm),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: AppTextStyles.headlineSmall),
                                      Text('Contact: $phone', style: AppTextStyles.bodySmall),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),

                  // Bottom CTA Panel
                  _buildBottomCta(context, status, paymentModel, isRsvpClosed, myStatus, dues),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomCta(
    BuildContext context,
    String gameStatus,
    String paymentModel,
    bool isRsvpClosed,
    RsvpStatus myStatus,
    List<dynamic> dues,
  ) {
    if (gameStatus != 'upcoming') return const SizedBox.shrink();

    final currentUserId = ref.read(supabaseClientProvider).auth.currentUser?.id;
    final myDue = dues.firstWhere(
      (d) => d['player_id'] == currentUserId && d['status'] != 'paid',
      orElse: () => null,
    );

    // If locked / deadline passed
    if (isRsvpClosed) {
      return Container(
        width: double.infinity,
        color: AppColors.surface,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, color: AppColors.textDisabled),
            SizedBox(width: AppSpacing.sm),
            Text('RSVP window is closed', style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    // If YES/GUEST
    if (myStatus == RsvpStatus.yes || myStatus == RsvpStatus.guest) {
      if (paymentModel == 'prepaid' && myDue != null) {
        final amountPaise = (myDue['amount_paise'] as num).toInt();
        final dueStatus = myDue['status'] as String;

        if (dueStatus == 'pending_verification') {
          return Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.all(AppSpacing.base),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty, color: AppColors.waitlist),
                SizedBox(width: AppSpacing.sm),
                Text('Payment pending verification...', style: AppTextStyles.bodyMedium),
              ],
            ),
          );
        }

        return Container(
          color: AppColors.surface,
          padding: const EdgeInsets.all(AppSpacing.base),
          child: AppButton(
            label: 'Complete Your Payment (₹${(amountPaise / 100.0).toStringAsFixed(0)})',
            onPressed: () => context.push('/group/${widget.groupId}/game/${widget.gameId}/payment'),
          ),
        );
      }

      return Container(
        width: double.infinity,
        color: AppColors.surface,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm),
            Text('You\'re confirmed for this session!', style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    // Default Join CTA
    if (paymentModel == 'prepaid') {
      return Container(
        color: AppColors.surface,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: AppButton(
          label: 'Join Game & Pay',
          onPressed: () => context.push('/group/${widget.groupId}/game/${widget.gameId}/payment'),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _GuestDialog extends StatefulWidget {
  final int maxGuests;
  final int remainingSpots;
  const _GuestDialog({required this.maxGuests, required this.remainingSpots});

  @override
  State<_GuestDialog> createState() => _GuestDialogState();
}

class _GuestDialogState extends State<_GuestDialog> {
  bool _userIsPlaying = true;
  int _guestCount = 1;

  @override
  Widget build(BuildContext context) {
    final neededSlots = (_userIsPlaying ? 1 : 0) + _guestCount;
    final exceedsSpots = neededSlots > widget.remainingSpots;

    return AlertDialog(
      title: const Text('Add Guests RSVP'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile.adaptive(
            title: const Text('I am also playing myself', style: AppTextStyles.headlineSmall),
            value: _userIsPlaying,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              if (val != null) setState(() => _userIsPlaying = val);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text('Extra Guests Count:', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _guestCount > 0 ? () => setState(() => _guestCount--) : null,
              ),
              Text('$_guestCount', style: AppTextStyles.displayMedium),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _guestCount < widget.maxGuests ? () => setState(() => _guestCount++) : null,
              ),
            ],
          ),
          if (exceedsSpots) ...[
            const SizedBox(height: AppSpacing.base),
            Text(
              'Warning: Exceeds remaining confirmed spots (${widget.remainingSpots}). If you proceed, you may be waitlisted.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.destructive, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          onPressed: () {
            Navigator.of(context).pop({
              'guestCount': _guestCount,
              'userIsPlaying': _userIsPlaying,
            });
          },
          child: const Text('Confirm RSVP'),
        ),
      ],
    );
  }
}