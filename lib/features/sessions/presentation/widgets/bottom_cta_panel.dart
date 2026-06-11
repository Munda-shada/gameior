import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';

class BottomCtaPanel extends StatelessWidget {
  final String groupId;
  final String gameId;
  final String gameStatus;
  final String paymentModel;
  final bool isRsvpClosed;
  final RsvpStatus myStatus;
  final List<dynamic> dues;
  final String? currentUserId;
  final VoidCallback onJoinGame;

  const BottomCtaPanel({
    required this.groupId,
    required this.gameId,
    required this.gameStatus,
    required this.paymentModel,
    required this.isRsvpClosed,
    required this.myStatus,
    required this.dues,
    required this.currentUserId,
    required this.onJoinGame,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (gameStatus != 'upcoming') return const SizedBox.shrink();

    final myDue = dues.firstWhere(
      (d) => d['player_id'] == currentUserId && d['status'] != 'paid',
      orElse: () => null,
    );

    // If RSVP closed
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
            onPressed: () => context.push('/group/$groupId/game/$gameId/payment'),
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

    // If WAITLIST
    if (myStatus == RsvpStatus.waitlist) {
      return Container(
        width: double.infinity,
        color: AppColors.surface,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, color: AppColors.waitlist),
            SizedBox(width: AppSpacing.sm),
            Text('You\'re on the waitlist for this session', style: AppTextStyles.bodyMedium),
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
          onPressed: () => context.push('/group/$groupId/game/$gameId/payment'),
        ),
      );
    } else if (paymentModel == 'postpaid') {
      return Container(
        color: AppColors.surface,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: AppButton(
          label: 'Join Game',
          onPressed: onJoinGame,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
