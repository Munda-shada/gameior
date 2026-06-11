import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/members/application/members_providers.dart';
import 'package:gameior/features/members/domain/member.dart';
import 'package:gameior/shared/models/enums.dart';

import 'package:gameior/features/members/presentation/widgets/stats_overview_row.dart';
import 'package:gameior/features/members/presentation/widgets/attendance_gauge.dart';
import 'package:gameior/features/members/presentation/widgets/monthly_participation_chart.dart';
import 'package:gameior/features/members/presentation/widgets/admin_actions_section.dart';

class MemberStatsSheet extends ConsumerWidget {
  final String groupId;
  final GroupMember member;
  final MemberRole currentUserRole;

  const MemberStatsSheet({
    super.key,
    required this.groupId,
    required this.member,
    required this.currentUserRole,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(memberStatsProvider(groupId: groupId, userId: member.userId));
    final isAdmin = currentUserRole == MemberRole.host || currentUserRole == MemberRole.coHost;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.base),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                '${member.displayName}\'s Profile',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: AppSpacing.lg),

              statsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(child: Text('Error loading stats: $e')),
                data: (stats) {
                  final gamesPlayed = stats.gamesPlayed;
                  final attendancePct = stats.attendancePct;
                  final joinedAt = stats.joinedAt;
                  final memberSince = joinedAt != null ? DateFormat('MMM yyyy').format(joinedAt) : 'Unknown';
                  final monthlyData = stats.monthlyData;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // High-Level Overview
                      StatsOverviewRow(
                        gamesPlayed: gamesPlayed,
                        attendancePct: attendancePct,
                        memberSince: memberSince,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Overall Attendance Gauge
                      AttendanceGauge(attendancePct: attendancePct),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Line chart for Monthly Participation
                      MonthlyParticipationChart(monthlyData: monthlyData),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Admin Fast Actions
              if (isAdmin)
                AdminActionsSection(
                  groupId: groupId,
                  member: member,
                  currentUserRole: currentUserRole,
                ),
            ],
          ),
        ),
      ),
    );
  }
}