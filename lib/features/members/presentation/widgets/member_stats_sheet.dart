import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/members/application/members_providers.dart';
import 'package:gameior/features/members/domain/member.dart';
import 'package:gameior/features/members/domain/member_stats.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_dialog.dart';

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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(supabaseClientProvider);
    final isMe = member.userId == client.auth.currentUser?.id;
    final statsAsync = ref.watch(memberStatsProvider(groupId: groupId, userId: member.userId));
    final isAdmin = currentUserRole == MemberRole.host || currentUserRole == MemberRole.coHost;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                '${member.displayName}\'s Profile',
                style: AppTextStyles.headlineLarge,
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
                  final List<FlSpot> spots = [];
                  if (monthlyData.isEmpty) {
                    spots.add(const FlSpot(0, 0));
                  } else {
                    for (int i = 0; i < monthlyData.length; i++) {
                      spots.add(FlSpot(i.toDouble(), monthlyData[i].gamesPlayed.toDouble()));
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // High-Level Overview
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(label: 'Games Played', value: gamesPlayed.toString()),
                          _StatItem(label: 'Attendance', value: '${attendancePct.toStringAsFixed(0)}%'),
                          _StatItem(label: 'Member Since', value: memberSince),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Overall Attendance Gauge
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
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Line chart for Monthly Participation
                      const Text('Monthly Participation', style: AppTextStyles.headlineMedium),
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
                                      return Text(monthStr, style: AppTextStyles.caption);
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
                                color: AppColors.primary,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Admin Fast Actions
              if (isAdmin && !isMe) ...[
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                const Text('Admin Actions', style: AppTextStyles.headlineMedium),
                const SizedBox(height: AppSpacing.base),
                if (member.phone.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'WhatsApp',
                          onPressed: () => _launchUrl('https://wa.me/${member.phone.replaceAll('+', '')}'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppButton(
                          label: 'Call',
                          onPressed: () => _launchUrl('tel:${member.phone}'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                ],
                _ActionTile(
                  icon: Icons.history_edu_outlined,
                  label: 'View Ledger History',
                  onTap: () {}, // NOTE: Add Navigation to ledger view
                ),
                _ActionTile(
                  icon: Icons.security_outlined,
                  label: 'View Audit History',
                  onTap: () {}, // NOTE: Add Navigation to audit view
                ),
                
                // Role Management Actions
                if (currentUserRole == MemberRole.host) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  if (member.role == MemberRole.player)
                    _ActionTile(
                      icon: Icons.verified_user_outlined,
                      label: 'Promote to Co-Host',
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.read(groupMembersProvider(groupId).notifier).updateRole(
                              userId: member.userId,
                              role: MemberRole.coHost,
                            );
                        _showSnackBar(context, '${member.displayName} promoted to Co-Host');
                      },
                    ),
                  if (member.role == MemberRole.coHost)
                    _ActionTile(
                      icon: Icons.remove_moderator_outlined,
                      label: 'Demote to Player',
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.read(groupMembersProvider(groupId).notifier).updateRole(
                              userId: member.userId,
                              role: MemberRole.player,
                            );
                        _showSnackBar(context, '${member.displayName} demoted to Player');
                      },
                    ),
                  _ActionTile(
                    icon: Icons.swap_horiz,
                    label: 'Transfer Group Ownership',
                    onTap: () {
                      Navigator.pop(context);
                      _confirmOwnershipTransfer(context, ref);
                    },
                  ),
                ],

                if (currentUserRole == MemberRole.host ||
                    (currentUserRole == MemberRole.coHost && member.role == MemberRole.player))
                  _ActionTile(
                    icon: Icons.person_remove_outlined,
                    label: 'Remove from Group',
                    isDestructive: true,
                    onTap: () async {
                      Navigator.pop(context);
                      final confirm = await showAppDialog(
                        context: context,
                        title: 'Remove Member?',
                        message: 'Are you sure you want to remove ${member.displayName} from this group?',
                        confirmLabel: 'Remove',
                        isDestructive: true,
                      );
                      if (confirm == true) {
                        await ref.read(groupMembersProvider(groupId).notifier).removeMember(
                              userId: member.userId,
                            );
                        _showSnackBar(context, '${member.displayName} removed from the group');
                      }
                    },
                  ),
                const SizedBox(height: AppSpacing.base),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmOwnershipTransfer(BuildContext context, WidgetRef ref) async {
    final client = ref.read(supabaseClientProvider);
    final myUserId = client.auth.currentUser?.id;
    if (myUserId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Transfer Ownership?'),
          content: Text(
            'Are you sure you want to transfer group ownership to ${member.displayName}? '
            'You will be demoted to Co-Host and lose ownership privileges. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Transfer'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await ref.read(groupMembersProvider(groupId).notifier).transferOwnership(
              oldHostId: myUserId,
              newHostId: member.userId,
            );
        if (context.mounted) {
          _showSnackBar(context, 'Ownership transferred to ${member.displayName} successfully!');
        }
      } catch (e) {
        if (context.mounted) {
          _showSnackBar(context, 'Failed to transfer ownership: $e');
        }
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.destructive : AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: color,
          fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.displayMedium.copyWith(color: AppColors.primaryDark)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}