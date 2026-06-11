import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/groups/domain/group.dart';
import 'package:gameior/shared/models/enums.dart';

class GroupCard extends StatelessWidget {
  final GroupSummary group;

  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final isAdmin = group.myRole == MemberRole.host || group.myRole == MemberRole.coHost;
    final hasPendingDues = group.pendingDuesPaise > 0;
    final hasPendingFromPlayers = group.pendingFromPlayersPaise > 0 && isAdmin;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/group/${group.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: AppTextStyles.headlineSmall,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Members: ${group.memberCount}',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  _buildRoleBadge(group.myRole),
                ],
              ),
              if (hasPendingDues || hasPendingFromPlayers) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    if (hasPendingDues)
                      _buildDuesBadge(
                        'You owe ₹${(group.pendingDuesPaise / 100).toStringAsFixed(0)}',
                        AppColors.destructive,
                      ),
                    if (hasPendingFromPlayers)
                      _buildDuesBadge(
                        'To collect ₹${(group.pendingFromPlayersPaise / 100).toStringAsFixed(0)}',
                        AppColors.primary,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(MemberRole role) {
    final String label;
    final Color color;
    switch (role) {
      case MemberRole.host:
        label = 'Host';
        color = Colors.purple;
        break;
      case MemberRole.coHost:
        label = 'Co-Host';
        color = Colors.blue;
        break;
      case MemberRole.player:
        label = 'Player';
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDuesBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
