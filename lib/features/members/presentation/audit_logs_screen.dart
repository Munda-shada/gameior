import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/members/application/members_providers.dart';
import 'package:gameior/features/members/domain/audit_log.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_empty_state.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';

enum LogFilter { all, joins, leaves, roles }

class AuditLogsScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String? filterTargetId;

  const AuditLogsScreen({
    required this.groupId,
    this.filterTargetId,
    super.key,
  });

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  LogFilter _selectedFilter = LogFilter.all;

  bool _matchesFilter(AuditLog log, LogFilter filter) {
    switch (filter) {
      case LogFilter.all:
        return true;
      case LogFilter.joins:
        return log.action == AuditAction.memberJoined ||
            log.action == AuditAction.joinRequestAccepted;
      case LogFilter.leaves:
        return log.action == AuditAction.memberLeft ||
            log.action == AuditAction.memberRemoved ||
            log.action == AuditAction.joinRequestRejected;
      case LogFilter.roles:
        return log.action == AuditAction.rolePromoted ||
            log.action == AuditAction.roleDemoted ||
            log.action == AuditAction.ownershipTransferred;
    }
  }

  String _getLogDescription(AuditLog log) {
    final actor = log.actorDisplayName;
    final target = log.targetDisplayName;
    switch (log.action) {
      case AuditAction.memberJoined:
        return '$target joined the group';
      case AuditAction.memberLeft:
        return '$target left the group';
      case AuditAction.memberRemoved:
        return '$target was removed by $actor';
      case AuditAction.rolePromoted:
        return '$actor promoted $target to Co-Host';
      case AuditAction.roleDemoted:
        return '$actor demoted $target to Player';
      case AuditAction.ownershipTransferred:
        return '$actor transferred ownership to $target';
      case AuditAction.joinRequestAccepted:
        return '$actor approved $target\'s request';
      case AuditAction.joinRequestRejected:
        return '$actor rejected $target\'s request';
    }
  }

  IconData _getLogIcon(AuditLog log) {
    switch (log.action) {
      case AuditAction.memberJoined:
      case AuditAction.joinRequestAccepted:
        return Icons.person_add_alt_1_outlined;
      case AuditAction.memberLeft:
      case AuditAction.memberRemoved:
      case AuditAction.joinRequestRejected:
        return Icons.person_remove_outlined;
      case AuditAction.rolePromoted:
      case AuditAction.roleDemoted:
      case AuditAction.ownershipTransferred:
        return Icons.shield_outlined;
    }
  }

  Color _getLogIconColor(BuildContext context, AuditLog log) {
    final theme = Theme.of(context);
    switch (log.action) {
      case AuditAction.memberJoined:
      case AuditAction.joinRequestAccepted:
        return theme.colorScheme.primary;
      case AuditAction.memberLeft:
      case AuditAction.memberRemoved:
      case AuditAction.joinRequestRejected:
        return theme.colorScheme.error;
      case AuditAction.rolePromoted:
      case AuditAction.roleDemoted:
      case AuditAction.ownershipTransferred:
        return theme.colorScheme.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(groupAuditLogsProvider(widget.groupId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Admin Logs'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: LogFilter.values.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  String label = 'All';
                  if (filter == LogFilter.joins) label = 'Joins';
                  if (filter == LogFilter.leaves) label = 'Leaves';
                  if (filter == LogFilter.roles) label = 'Role Changes';

                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          Expanded(
            child: logsAsync.when(
              loading: () => const AppLoadingShimmer(type: ShimmerType.listTile),
              error: (e, _) => AppErrorState(
                message: 'Failed to load audit logs: $e',
                onRetry: () => ref.invalidate(groupAuditLogsProvider(widget.groupId)),
              ),
              data: (logs) {
                // Apply filterTargetId first if present
                var filtered = logs;
                if (widget.filterTargetId != null) {
                  filtered = filtered.where((log) => log.targetId == widget.filterTargetId || log.actorId == widget.filterTargetId).toList();
                }

                // Apply selected filter category
                filtered = filtered.where((log) => _matchesFilter(log, _selectedFilter)).toList();

                if (filtered.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.list_alt_outlined,
                    message: 'No admin logs match the selected filter.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(groupAuditLogsProvider(widget.groupId)),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final log = filtered[index];
                      final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(log.createdAt.toLocal());
                      final icon = _getLogIcon(log);
                      final iconColor = _getLogIconColor(context, log);
                      final desc = _getLogDescription(log);

                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                        elevation: 0,
                        color: theme.colorScheme.surfaceContainer,
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: iconColor),
                          ),
                          title: Text(desc, style: theme.textTheme.bodyMedium),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(dateStr, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5))),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
