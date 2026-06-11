import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/widgets/dues_hero_card.dart';

class PlayerLedgerHero extends StatelessWidget {
  final int amountPaise;
  final VoidCallback onTap;

  const PlayerLedgerHero({
    required this.amountPaise,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (amountPaise <= 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: DuesHeroCard(
        amountPaise: amountPaise,
        label: 'You owe',
        ctaLabel: 'Pay',
        isAdminView: false,
        onTap: onTap,
      ),
    );
  }
}
