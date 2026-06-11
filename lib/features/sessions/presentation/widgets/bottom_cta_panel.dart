import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_spacing.dart';
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

    final theme = Theme.of(context);

    final myDue = dues.firstWhere(
      (d) => d['player_id'] == currentUserId && d['status'] != 'paid',
      orElse: () => null,
    );

    // If RSVP closed
    if (isRsvpClosed) {
      return Container(
        width: double.infinity,
        color: theme.colorScheme.surfaceContainer,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'RSVP window is closed',
              style: theme.textTheme.bodyMedium,
            ),
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
            color: theme.colorScheme.surfaceContainer,
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty, color: theme.colorScheme.tertiary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Payment pending verification...',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return Container(
          color: theme.colorScheme.surfaceContainer,
          padding: const EdgeInsets.all(AppSpacing.base),
          child: AppButton(
            label: 'Complete Your Payment (₹${(amountPaise / 100.0).toStringAsFixed(0)})',
            onPressed: () => context.push('/group/$groupId/game/$gameId/payment'),
          ),
        );
      }

      return Container(
        width: double.infinity,
        color: theme.colorScheme.surfaceContainer,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'You\'re confirmed for this session!',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // If WAITLIST
    if (myStatus == RsvpStatus.waitlist) {
      return Container(
        width: double.infinity,
        color: theme.colorScheme.surfaceContainer,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, color: theme.colorScheme.tertiary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'You\'re on the waitlist for this session',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Default Join CTA
    if (paymentModel == 'prepaid') {
      return Container(
        color: theme.colorScheme.surfaceContainer,
        padding: const EdgeInsets.all(AppSpacing.base),
        child: AppButton(
          label: 'Join Game & Pay',
          onPressed: () => context.push('/group/$groupId/game/$gameId/payment'),
        ),
      );
    } else if (paymentModel == 'postpaid') {
      return Container(
        color: theme.colorScheme.surfaceContainer,
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
