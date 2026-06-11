import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/widgets/app_button.dart';

class HostedGroupsSection extends StatelessWidget {
  final List<Map<String, dynamic>> groups;
  final Function(Map<String, dynamic> group, List<Map<String, dynamic>> coHosts) onTransferOwnership;
  final Function(Map<String, dynamic> group) onDeleteGroup;
  final Function(Map<String, dynamic> group) onPromoteMember;

  const HostedGroupsSection({
    required this.groups,
    required this.onTransferOwnership,
    required this.onDeleteGroup,
    required this.onPromoteMember,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: colorScheme.tertiary,
          size: 48,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Unresolved Groups',
          style: textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'You are currently hosting ${groups.length} group(s). Before you can delete your account, you must transfer ownership to a Co-Host or delete the groups.',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xl),
        ...groups.map((group) {
          final coHosts = List<Map<String, dynamic>>.from(group['co_hosts'] ?? []);
          final hasCoHosts = coHosts.isNotEmpty;

          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.base),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group['name'], style: textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  if (hasCoHosts) ...[
                    Text(
                      'Co-Hosts available: ${coHosts.length}',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Transfer Ownership',
                        onPressed: () => onTransferOwnership(group, coHosts),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'No Co-Hosts are in this group. You must promote a member to Co-Host or delete the group.',
                      style: TextStyle(color: colorScheme.tertiary, fontSize: 13),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Promote Member',
                            variant: AppButtonVariant.secondary,
                            onPressed: () => onPromoteMember(group),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppButton(
                            label: 'Delete Group',
                            variant: AppButtonVariant.destructive,
                            onPressed: () => onDeleteGroup(group),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
