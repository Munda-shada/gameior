import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gameior/core/utils/app_toast.dart';

import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/sessions/application/sessions_providers.dart';
import 'package:gameior/features/sessions/data/sessions_repository.dart';
import 'package:gameior/shared/models/enums.dart';

import 'package:gameior/features/sessions/presentation/widgets/cost_summary_card.dart';
import 'package:gameior/features/sessions/presentation/widgets/guest_adjustment_section.dart';
import 'package:gameior/features/sessions/presentation/widgets/payment_details_section.dart';
import 'package:gameior/features/sessions/presentation/widgets/utr_submission_section.dart';

class GamePaymentScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String gameId;
  const GamePaymentScreen({required this.groupId, required this.gameId, super.key});

  @override
  ConsumerState<GamePaymentScreen> createState() => _GamePaymentScreenState();
}

class _GamePaymentScreenState extends ConsumerState<GamePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _utrController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Guest settings state
  bool _userIsPlaying = true;
  int _guestCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  @override
  void dispose() {
    _utrController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialState() async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;

    try {
      final game = await ref.read(gameDetailProvider(widget.gameId).future);
      final rsvps = game['rsvps'] as List? ?? [];
      
      final myRsvp = rsvps.firstWhere((r) => r['user_id'] == userId, orElse: () => null);
      if (myRsvp != null) {
        setState(() {
          _userIsPlaying = myRsvp['user_is_playing'] as bool? ?? true;
          _guestCount = (myRsvp['guest_count'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (e) {
      // Fail silently
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _launchUpiApp(String upiId, int amountPaise, String title) async {
    final formattedAmount = (amountPaise / 100.0).toStringAsFixed(2);
    final upiUrl = 'upi://pay?'
        'pa=$upiId'
        '&am=$formattedAmount'
        '&tn=${Uri.encodeComponent(title)}'
        '&cu=INR';

    final uri = Uri.parse(upiUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          showToast(context, 'No UPI apps found. Please pay manually using the UPI ID.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Could not launch UPI app. Please pay manually.', isError: true);
      }
    }
  }

  Future<void> _submitPayment(
    String? dueId,
    int amountPaise,
    String paymentOwnerId,
    String groupId,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final repo = ref.read(sessionsRepositoryProvider);
    final utr = _utrController.text.trim();

    final rsvpStatus = _guestCount > 0 ? RsvpStatus.guest : RsvpStatus.yes;

    try {
      await repo.submitPayment(
        gameId: widget.gameId,
        dueId: dueId,
        utr: utr,
        rsvpStatus: rsvpStatus,
        guestCount: _guestCount,
        userIsPlaying: _userIsPlaying,
        amountPaise: amountPaise,
        paymentOwnerId: paymentOwnerId,
        groupId: groupId,
      );

      ref.invalidate(gameDetailProvider(widget.gameId));
      ref.invalidate(upcomingGamesProvider(widget.groupId));

      if (mounted) {
        showToast(context, 'Payment submitted! Waiting for host verification.');
        context.pop(); // Back to Game Details
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Failed to submit payment: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final detailAsync = ref.watch(gameDetailProvider(widget.gameId));
    final currentUserId = ref.watch(supabaseClientProvider).auth.currentUser?.id;

    return detailAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(body: Center(child: Text('Failed to load payment details'))),
      data: (game) {
        final title = game['title'] as String? ?? 'Match Session';
        final costPaise = (game['cost_paise'] as num?)?.toInt() ?? 0;
        final upiId = game['upi_id'] as String? ?? '';
        final allowGuests = game['allow_guests'] as bool? ?? true;
        final capacity = (game['max_capacity'] as num?)?.toInt() ?? 20;
        
        final rsvps = game['rsvps'] as List? ?? [];
        final dues = game['payment_dues'] as List? ?? [];

        // Calculate slots and total amount
        final neededSlots = (_userIsPlaying ? 1 : 0) + _guestCount;
        final totalCostPaise = costPaise * neededSlots;

        // Current confirmed slots excluding caller
        var confirmedExcludingCaller = 0;
        for (var r in rsvps) {
          if (r['user_id'] == currentUserId) continue;
          final rStatus = r['status'] as String;
          if (rStatus == 'yes' || rStatus == 'guest') {
            final isPlaying = r['user_is_playing'] as bool? ?? true;
            final guests = (r['guest_count'] as num?)?.toInt() ?? 0;
            confirmedExcludingCaller += (isPlaying ? 1 : 0) + guests;
          }
        }
        final exceedsSpots = confirmedExcludingCaller + neededSlots > capacity;

        // Find existing due
        final myDue = dues.firstWhere(
          (d) => d['player_id'] == currentUserId && d['status'] != 'paid',
          orElse: () => null,
        );
        final String? dueId = myDue?['id'] as String?;

        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: const Text('Complete Payment'),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CostSummaryCard(
                    costPaise: costPaise,
                    neededSlots: neededSlots,
                    totalCostPaise: totalCostPaise,
                  ),
                  const SizedBox(height: AppSpacing.base),

                  if (allowGuests) ...[
                    GuestAdjustmentSection(
                      userIsPlaying: _userIsPlaying,
                      onUserIsPlayingChanged: (val) {
                        if (val != null) {
                          setState(() => _userIsPlaying = val);
                        }
                      },
                      guestCount: _guestCount,
                      onDecrementGuests: _guestCount > 0 ? () => setState(() => _guestCount--) : () {},
                      onIncrementGuests: _guestCount < 5 ? () => setState(() => _guestCount++) : () {},
                      exceedsSpots: exceedsSpots,
                    ),
                    const SizedBox(height: AppSpacing.base),
                  ],

                  PaymentDetailsSection(
                    upiId: upiId,
                    onOpenUpiApp: () => _launchUpiApp(upiId, totalCostPaise, title),
                    onCopied: () => showToast(context, 'UPI ID copied to clipboard!'),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  UtrSubmissionSection(
                    controller: _utrController,
                    isLoading: _isSubmitting,
                    onSubmit: () => _submitPayment(
                      dueId,
                      totalCostPaise,
                      game['payment_owner_id'] as String,
                      game['group_id'] as String,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}