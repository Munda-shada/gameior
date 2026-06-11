import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/utils/app_toast.dart';

import 'package:gameior/core/constants/app_constants.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/sessions/application/sessions_providers.dart';
import 'package:gameior/features/sessions/data/sessions_repository.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';

// Split widgets imports
import 'package:gameior/features/sessions/presentation/widgets/game_info_banner.dart';
import 'package:gameior/features/sessions/presentation/widgets/cost_form_section.dart';
import 'package:gameior/features/sessions/presentation/widgets/billing_preview_card.dart';
import 'package:gameior/features/sessions/presentation/widgets/attendance_checklist.dart';

class CompleteGameScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String gameId;
  const CompleteGameScreen({super.key, required this.groupId, required this.gameId});

  @override
  ConsumerState<CompleteGameScreen> createState() => _CompleteGameScreenState();
}

class _CompleteGameScreenState extends ConsumerState<CompleteGameScreen> {
  bool _initialized = false;
  final _costController = TextEditingController();
  final List<Map<String, dynamic>> _costItems = []; // label: string, costRupees: double
  bool _showCostBreakdown = false;
  bool _chargeAllRsvped = false;
  final Set<String> _attendedPlayerIds = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final cached = ref.read(gameDetailProvider(widget.gameId)).valueOrNull;
    if (cached != null) {
      _initializeState(cached);
    }
  }

  @override
  void dispose() {
    _costController.dispose();
    super.dispose();
  }

  void _initializeState(Map<String, dynamic> game) {
    _initialized = true;
    final status = game['status'] as String? ?? 'upcoming';
    final isCompleted = status == 'completed';
    final completion = game['game_completion'] as Map<String, dynamic>?;

    if (isCompleted && completion != null) {
      final totalCostPaise = (completion['total_cost_paise'] as num?)?.toInt() ?? 0;
      _costController.text = (totalCostPaise / 100.0).toStringAsFixed(0);
      _chargeAllRsvped = completion['charge_all_rsvped'] as bool? ?? false;
      
      final attendedIds = completion['attended_player_ids'] as List? ?? [];
      _attendedPlayerIds.addAll(attendedIds.map((id) => id.toString()));

      _showCostBreakdown = game['show_cost_breakdown'] as bool? ?? false;
      final items = game['game_cost_items'] as List? ?? [];
      for (var item in items) {
        _costItems.add({
          'label': item['label'] as String? ?? '',
          'costRupees': ((item['amount_paise'] as num?)?.toDouble() ?? 0.0) / 100.0,
        });
      }
    } else {
      // Upcoming postpaid game
      final estimatedCostPaise = (game['cost_paise'] as num?)?.toInt() ?? 0;
      _costController.text = estimatedCostPaise > 0 ? (estimatedCostPaise / 100.0).toStringAsFixed(0) : '';
      _chargeAllRsvped = false;

      // Default all confirmed players as attended
      final rsvps = game['rsvps'] as List? ?? [];
      final confirmedIds = rsvps
          .where((r) => r['status'] == 'yes' || r['status'] == 'guest')
          .map((r) => r['user_id'] as String);
      _attendedPlayerIds.addAll(confirmedIds);

      _showCostBreakdown = game['show_cost_breakdown'] as bool? ?? false;
      final items = game['game_cost_items'] as List? ?? [];
      for (var item in items) {
        _costItems.add({
          'label': item['label'] as String? ?? '',
          'costRupees': ((item['amount_paise'] as num?)?.toDouble() ?? 0.0) / 100.0,
        });
      }
    }
  }

  void _updateCostFromBreakdown() {
    double sum = 0.0;
    for (var item in _costItems) {
      sum += (item['costRupees'] as double? ?? 0.0);
    }
    setState(() {
      _costController.text = sum.toStringAsFixed(0);
    });
  }

  Future<void> _submitCompletion(Map<String, dynamic> game) async {
    final status = game['status'] as String? ?? 'upcoming';
    final isCompleted = status == 'completed';

    final totalCostDouble = double.tryParse(_costController.text) ?? 0.0;
    if (totalCostDouble <= 0.0) {
      showToast(context, 'Please enter a valid total cost.', isError: true);
      return;
    }

    final totalCostPaise = (totalCostDouble * 100).round();

    // Attended list can't be empty if chargeAllRsvped is false
    if (!_chargeAllRsvped && _attendedPlayerIds.isEmpty) {
      showToast(context, 'Please select at least one attendee to bill.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    final repo = ref.read(sessionsRepositoryProvider);

    try {
      final Map<String, dynamic> result;
      if (isCompleted) {
        result = await repo.updateGameCompletion(
          gameId: widget.gameId,
          totalCostPaise: totalCostPaise,
          chargeAllRsvped: _chargeAllRsvped,
          attendedPlayerIds: _attendedPlayerIds.toList(),
        );
      } else {
        result = await repo.completeGame(
          gameId: widget.gameId,
          totalCostPaise: totalCostPaise,
          chargeAllRsvped: _chargeAllRsvped,
          attendedPlayerIds: _attendedPlayerIds.toList(),
        );
      }

      if (result.containsKey('error')) {
        throw Exception(result['message'] ?? 'Failed to submit completion.');
      }

      // Invalidate providers to refresh UI
      ref.invalidate(gameDetailProvider(widget.gameId));
      ref.invalidate(pastGamesProvider(groupId: widget.groupId, limit: AppConstants.pastGamesInitialLimit));
      ref.invalidate(upcomingGamesProvider(widget.groupId));

      if (mounted) {
        showToast(
          context,
          isCompleted
              ? 'Game completion updated successfully!'
              : 'Game completed. Dues sent to players.',
        );
        context.pop(); // Go back to Game Detail
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Submission failed: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(gameDetailProvider(widget.gameId));

    return gameAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Complete Game')),
        body: AppErrorState(
          message: 'Failed to load game details',
          onRetry: () => ref.invalidate(gameDetailProvider(widget.gameId)),
        ),
      ),
      data: (game) {
        if (!_initialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _initializeState(game);
              });
            }
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final status = game['status'] as String? ?? 'upcoming';
        final isCompleted = status == 'completed';
        final title = game['title'] as String? ?? 'Match Session';
        final venue = game['venue'] as String? ?? 'Venue';
        final scheduledAt = DateTime.parse(game['scheduled_at'] as String).toLocal();
        final formattedTime = DateFormat('EEEE, MMMM d • h:mm a').format(scheduledAt);
        final rsvps = game['rsvps'] as List? ?? [];
        final dues = game['payment_dues'] as List? ?? [];

        final eligiblePlayers = rsvps
            .where((r) => r['status'] == 'yes' || r['status'] == 'guest')
            .toList();

        // Check if all dues are already paid (Edit Mode Lock check)
        final allDuesSettled = isCompleted &&
            dues.isNotEmpty &&
            dues.every((d) => d['status'] == 'paid');

        // Live calculations
        final totalCostDouble = double.tryParse(_costController.text) ?? 0.0;
        final totalCostPaise = (totalCostDouble * 100).round();
        final chargedCount = _chargeAllRsvped ? eligiblePlayers.length : _attendedPlayerIds.length;
        final perHeadPaise = chargedCount > 0 ? (totalCostPaise / chargedCount).ceil() : 0;
        final perHeadRupees = perHeadPaise / 100.0;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(isCompleted ? 'Edit Game Completion' : 'Complete Game Session'),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  children: [
                    // Warning Banners
                    if (allDuesSettled)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.base),
                        padding: const EdgeInsets.all(AppSpacing.base),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline, color: AppColors.textDisabled),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                "This game's completion is locked because all dues have been settled.",
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isCompleted)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.base),
                        padding: const EdgeInsets.all(AppSpacing.base),
                        decoration: BoxDecoration(
                          color: AppColors.waitlistMuted,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.waitlist.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.waitlist),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                "Unpaid dues will be recalculated based on new values.",
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.waitlist, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                    GameInfoBanner(
                      sport: game['sport'].toString(),
                      title: title,
                      formattedTime: formattedTime,
                      venue: venue,
                    ),
                    const SizedBox(height: AppSpacing.base),

                    CostFormSection(
                      costController: _costController,
                      allDuesSettled: allDuesSettled,
                      showCostBreakdown: _showCostBreakdown,
                      onCostBreakdownExpanded: (expanded) {
                        setState(() {
                          _showCostBreakdown = expanded;
                          if (expanded) _updateCostFromBreakdown();
                        });
                      },
                      costItems: _costItems,
                      onAddCostItem: () {
                        setState(() {
                          _costItems.add({'label': '', 'costRupees': 0.0});
                        });
                      },
                      onRemoveCostItem: (idx) {
                        setState(() {
                          _costItems.removeAt(idx);
                          _updateCostFromBreakdown();
                        });
                      },
                      onCostItemLabelChanged: (idx, val) {
                        _costItems[idx]['label'] = val;
                      },
                      onCostItemAmountChanged: (idx, val) {
                        _costItems[idx]['costRupees'] = val;
                        _updateCostFromBreakdown();
                      },
                      chargeAllRsvped: _chargeAllRsvped,
                      onChargeAllRsvpedChanged: (val) {
                        setState(() {
                          _chargeAllRsvped = val;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.base),

                    BillingPreviewCard(
                      perHeadRupees: perHeadRupees,
                      chargedCount: chargedCount,
                    ),
                    const SizedBox(height: AppSpacing.base),

                    AttendanceChecklist(
                      chargeAllRsvped: _chargeAllRsvped,
                      eligiblePlayers: eligiblePlayers,
                      attendedPlayerIds: _attendedPlayerIds,
                      allDuesSettled: allDuesSettled,
                      onAttendanceChanged: (userId, val) {
                        setState(() {
                          if (val) {
                            _attendedPlayerIds.add(userId);
                          } else {
                            _attendedPlayerIds.remove(userId);
                          }
                        });
                      },
                      onSelectAll: () {
                        setState(() {
                          for (var r in eligiblePlayers) {
                            _attendedPlayerIds.add(r['user_id'] as String);
                          }
                        });
                      },
                      onClearAll: () {
                        setState(() {
                          _attendedPlayerIds.clear();
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),

              // Bottom CTA
              if (!allDuesSettled)
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: SafeArea(
                    top: false,
                    child: AppButton(
                      label: isCompleted ? 'Update Completion Details' : 'Complete Game Session',
                      isLoading: _isSubmitting,
                      onPressed: () => _submitCompletion(game),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}