import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';

class AttendanceGauge extends StatelessWidget {
  final double attendancePct;

  const AttendanceGauge({
    required this.attendancePct,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overall Attendance', style: AppTextStyles.headlineMedium),
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
                  color: AppColors.primary,
                  value: attendancePct,
                  title: '${attendancePct.toStringAsFixed(0)}%',
                  radius: 20,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: AppColors.border,
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
