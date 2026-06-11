import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/members/domain/member_stats.dart';

class MonthlyParticipationChart extends StatelessWidget {
  final List<MonthlyParticipation> monthlyData;

  const MonthlyParticipationChart({
    required this.monthlyData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = [];
    if (monthlyData.isEmpty) {
      spots.add(const FlSpot(0, 0));
    } else {
      for (int i = 0; i < monthlyData.length; i++) {
        spots.add(FlSpot(i.toDouble(), monthlyData[i].gamesPlayed.toDouble()));
      }
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly Participation', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.base),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < monthlyData.length) {
                        final item = monthlyData[index];
                        final monthStr = DateFormat('MMM').format(DateTime(item.year, item.month));
                        return Text(monthStr, style: theme.textTheme.labelSmall);
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
