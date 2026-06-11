import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gameior/core/theme/app_spacing.dart';

class AttendanceGauge extends StatelessWidget {
  final double attendancePct;

  const AttendanceGauge({
    required this.attendancePct,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overall Attendance', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.base),
        SizedBox(
          height: 150,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 50,
              startDegreeOffset: -90,
              sections: [
                PieChartSectionData(
                  color: theme.colorScheme.primary,
                  value: attendancePct,
                  title: '${attendancePct.toStringAsFixed(0)}%',
                  radius: 20,
                  titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                PieChartSectionData(
                  color: theme.colorScheme.outlineVariant,
                  value: (100 - attendancePct).clamp(0, 100),
                  title: '',
                  radius: 15,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
