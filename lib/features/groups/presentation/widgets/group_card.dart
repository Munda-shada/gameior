import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/groups/domain/group.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/core/constants/sports_config.dart';

class GroupCard extends StatelessWidget {
  final GroupSummary group;

  const GroupCard({super.key, required this.group});

  String _formatSportName(SportType sport) {
    final name = sport.name;
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = group.myRole == MemberRole.host || group.myRole == MemberRole.coHost;
    final hasPendingDues = group.pendingDuesPaise > 0;
    final hasPendingFromPlayers = group.pendingFromPlayersPaise > 0 && isAdmin;
    final sportEmoji = sportEmojis[group.sport] ?? '🏆';
    final sportLabel = _formatSportName(group.sport);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/group/${group.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sport Emoji Container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        sportEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  // Group Name & Sport/Members Label
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              sportLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              ' • ${group.memberCount} members',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Role Badge & Chevron Row
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildRoleBadge(group.myRole, theme),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
              if (hasPendingDues || hasPendingFromPlayers) ...[
                const SizedBox(height: AppSpacing.sm),
                Divider(
                  height: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    if (hasPendingDues)
                      _buildDuesBadge(
                        'You owe ₹${(group.pendingDuesPaise / 100).toStringAsFixed(0)}',
                        theme.colorScheme.error,
                        theme,
                      ),
                    if (hasPendingFromPlayers)
                      _buildDuesBadge(
                        'To collect ₹${(group.pendingFromPlayersPaise / 100).toStringAsFixed(0)}',
                        theme.colorScheme.primary,
                        theme,
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

  Widget _buildRoleBadge(MemberRole role, ThemeData theme) {
    final String label;
    final Color color;
    switch (role) {
      case MemberRole.host:
        label = 'Host';
        color = theme.colorScheme.primary;
        break;
      case MemberRole.coHost:
        label = 'Co-Host';
        color = theme.colorScheme.secondary;
        break;
      case MemberRole.player:
        label = 'Player';
        color = theme.colorScheme.outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDuesBadge(String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
