import 'package:flutter/material.dart';
class StatsOverviewRow extends StatelessWidget {
  final int gamesPlayed;
  final double attendancePct;
  final String memberSince;

  const StatsOverviewRow({
    required this.gamesPlayed,
    required this.attendancePct,
    required this.memberSince,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(label: 'Games Played', value: gamesPlayed.toString()),
        _StatItem(label: 'Attendance', value: '${attendancePct.toStringAsFixed(0)}%'),
        _StatItem(label: 'Member Since', value: memberSince),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.displayMedium?.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
