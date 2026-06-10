import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/sessions/application/sessions_providers.dart';
import 'package:gameior/features/sessions/data/sessions_repository.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/shared/widgets/section_header.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No UPI apps found. Please pay manually using the UPI ID.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch UPI app. Please pay manually.')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment submitted! Waiting for host verification.')),
        );
        context.pop(); // Back to Game Details
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit payment: $e')),
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

        return Scaffold(
          backgroundColor: AppColors.background,
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
                  // 1. Cost summary card
                  const SectionHeader(title: 'COST SUMMARY'),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Base Cost per person', '₹${(costPaise / 100.0).toStringAsFixed(0)}'),
                        const Divider(height: AppSpacing.lg),
                        _buildSummaryRow('Attending Slots', '$neededSlots slot${neededSlots > 1 ? 's' : ''}'),
                        const Divider(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Dues Payable', style: AppTextStyles.headlineSmall),
                            Text(
                              '₹${(totalCostPaise / 100.0).toStringAsFixed(0)}',
                              style: AppTextStyles.displayMedium.copyWith(color: AppColors.primaryDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // 2. Guest stepper adjustments (if allowed)
                  if (allowGuests) ...[
                    const SectionHeader(title: 'ADJUST SLOTS'),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          CheckboxListTile.adaptive(
                            title: const Text('I am playing', style: AppTextStyles.headlineSmall),
                            value: _userIsPlaying,
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _userIsPlaying = val);
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Extra Guests', style: AppTextStyles.headlineSmall),
                                  Text('Add friends to play along', style: AppTextStyles.bodySmall),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.textSecondary),
                                    onPressed: _guestCount > 0 ? () => setState(() => _guestCount--) : null,
                                  ),
                                  Text('$_guestCount', style: AppTextStyles.headlineMedium),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                    onPressed: _guestCount < 5 ? () => setState(() => _guestCount++) : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (exceedsSpots) ...[
                            const SizedBox(height: AppSpacing.base),
                            Text(
                              'Warning: Session is full. Submitting payment will request slot verification from the organizer.',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.destructive, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                  ],

                  // 3. Payment Instructions & UPI launcher
                  const SectionHeader(title: 'PAYMENT DETAILS'),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Scan or transfer to organizer\'s UPI ID below:',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SelectableText(
                          upiId,
                          style: AppTextStyles.displayMedium.copyWith(color: AppColors.primary, fontSize: 22),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Open UPI App'),
                              onPressed: () => _launchUpiApp(upiId, totalCostPaise, title),
                            ),
                            const SizedBox(width: AppSpacing.base),
                            IconButton(
                              icon: const Icon(Icons.copy, color: AppColors.textSecondary),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: upiId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('UPI ID copied to clipboard!')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // 4. UTR confirmation input
                  const SectionHeader(title: 'UTR TRANSACTION ID'),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _utrController,
                          label: '12-digit UPI Transaction Ref (UTR)',
                          hint: 'E.g. 408712345678',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                          ],
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'UTR number is required to confirm payment.';
                            if (v.length != 12) return 'UTR must be exactly 12 digits.';
                            if (!RegExp(r'^[0-9]{12}$').hasMatch(v)) return 'UTR must be numbers only.';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.base),
                        AppButton(
                          label: 'Submit Payment & Join',
                          isLoading: _isSubmitting,
                          onPressed: () => _submitPayment(
                            dueId,
                            totalCostPaise,
                            game['payment_owner_id'] as String,
                            game['group_id'] as String,
                          ),
                        ),
                      ],
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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value, style: AppTextStyles.headlineSmall),
      ],
    );
  }
}