import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:gameior/core/constants/app_constants.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/sessions/application/sessions_providers.dart';
import 'package:gameior/features/sessions/data/sessions_repository.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/section_header.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid total cost.')),
      );
      return;
    }

    final totalCostPaise = (totalCostDouble * 100).round();

    // Attended list can't be empty if chargeAllRsvped is false
    if (!_chargeAllRsvped && _attendedPlayerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one attendee to bill.')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCompleted
                  ? 'Game completion updated successfully!'
                  : 'Game completed. Dues sent to players.',
            ),
          ),
        );
        context.pop(); // Go back to Game Detail
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
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
          _initializeState(game);
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
                          border: Border.all(color: AppColors.waitlist.withValues(alpha: 0.5)),
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

                    // Game info card
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
                          Text(
                            game['sport'].toString().toUpperCase(),
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(title, style: AppTextStyles.headlineLarge),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: AppSpacing.xs),
                              Text(formattedTime, style: AppTextStyles.bodySmall),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: AppSpacing.xs),
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
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // Cost Section Header
                    const SectionHeader(title: 'EXPENSES & BILLING MODEL'),

                    // Cost card
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
                          TextField(
                            controller: _costController,
                            enabled: !allDuesSettled,
                            decoration: const InputDecoration(
                              labelText: 'Total Cost (₹)',
                              prefixText: '₹ ',
                              hintText: '0.00',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            onChanged: (val) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: AppSpacing.base),

                          // Cost items accordion
                          ExpansionTile(
                            leading: const Icon(Icons.calculate_outlined, color: AppColors.primary),
                            title: const Text('Add Cost Breakdown', style: AppTextStyles.headlineSmall),
                            subtitle: const Text('Sum elements to calculate total cost', style: AppTextStyles.bodySmall),
                            initiallyExpanded: _showCostBreakdown,
                            onExpansionChanged: allDuesSettled ? null : (expanded) {
                              setState(() {
                                _showCostBreakdown = expanded;
                                if (expanded) _updateCostFromBreakdown();
                              });
                            },
                            children: [
                              ..._costItems.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final item = entry.value;
                                final labelController = TextEditingController(text: item['label'] as String);
                                final valController = TextEditingController(text: (item['costRupees'] as double).toStringAsFixed(0));

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextField(
                                          controller: labelController,
                                          enabled: !allDuesSettled,
                                          decoration: const InputDecoration(labelText: 'Item Label', hintText: 'Court fee'),
                                          onChanged: (val) {
                                            _costItems[idx]['label'] = val;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: valController,
                                          enabled: !allDuesSettled,
                                          decoration: const InputDecoration(labelText: 'Amount (₹)'),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          onChanged: (val) {
                                            _costItems[idx]['costRupees'] = double.tryParse(val) ?? 0.0;
                                            _updateCostFromBreakdown();
                                          },
                                        ),
                                      ),
                                      if (!allDuesSettled)
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.destructive),
                                          onPressed: () {
                                            setState(() {
                                              _costItems.removeAt(idx);
                                              _updateCostFromBreakdown();
                                            });
                                          },
                                        ),
                                    ],
                                  ),
                                );
                              }),
                              if (!allDuesSettled && _costItems.length < 5)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Line Item'),
                                    onPressed: () {
                                      setState(() {
                                        _costItems.add({'label': '', 'costRupees': 0.0});
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                          const Divider(height: AppSpacing.lg),

                          SwitchListTile.adaptive(
                            activeTrackColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Charge all RSVPed players', style: AppTextStyles.headlineSmall),
                            subtitle: const Text('If off, only checked attendees below will be charged', style: AppTextStyles.bodySmall),
                            value: _chargeAllRsvped,
                            onChanged: allDuesSettled
                                ? null
                                : (val) {
                                    setState(() {
                                      _chargeAllRsvped = val;
                                    });
                                  },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // Live preview billing summary card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Per-head Cost:',
                                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primaryDark),
                              ),
                              Text(
                                '₹${perHeadRupees.toStringAsFixed(2)}',
                                style: AppTextStyles.displayLarge.copyWith(color: AppColors.primaryDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Divisor:',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryDark),
                              ),
                              Text(
                                '$chargedCount players billed',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // Attendance Checklist section
                    SectionHeader(
                      title: _chargeAllRsvped
                          ? 'ATTENDANCE LIST (ALL RSVPS CHARGED)'
                          : 'ATTENDANCE SHEET (ONLY CHECKED CHARGED)',
                    ),

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
                          if (eligiblePlayers.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: AppSpacing.base),
                                child: Text('No players confirmed (YES/Guest) for this session.', style: AppTextStyles.bodyMedium),
                              ),
                            )
                          else ...[
                            if (!allDuesSettled)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_attendedPlayerIds.length} of ${eligiblePlayers.length} attended',
                                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 30)),
                                        onPressed: () {
                                          setState(() {
                                            for (var r in eligiblePlayers) {
                                              _attendedPlayerIds.add(r['user_id'] as String);
                                            }
                                          });
                                        },
                                        child: const Text('Select All', style: TextStyle(fontSize: 12)),
                                      ),
                                      const VerticalDivider(),
                                      TextButton(
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 30)),
                                        onPressed: () {
                                          setState(() {
                                            _attendedPlayerIds.clear();
                                          });
                                        },
                                        child: const Text('Clear All', style: TextStyle(fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            const Divider(),
                            ...eligiblePlayers.map((r) {
                              final profile = r['profiles'] as Map<String, dynamic>? ?? {};
                              final name = profile['display_name'] as String? ?? 'Player';
                              final emoji = profile['emoji'] as String? ?? '🏸';
                              final userId = r['user_id'] as String;

                              final isAttending = _attendedPlayerIds.contains(userId);

                              return CheckboxListTile.adaptive(
                                activeColor: AppColors.primary,
                                contentPadding: EdgeInsets.zero,
                                enabled: !allDuesSettled,
                                title: Row(
                                  children: [
                                    Text(emoji, style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: isAttending ? FontWeight.bold : FontWeight.normal,
                                          color: isAttending ? AppColors.textPrimary : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                value: isAttending,
                                onChanged: (val) {
                                  if (val == null) return;
                                  setState(() {
                                    if (val) {
                                      _attendedPlayerIds.add(userId);
                                    } else {
                                      _attendedPlayerIds.remove(userId);
                                    }
                                  });
                                },
                              );
                            }),
                          ],
                        ],
                      ),
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