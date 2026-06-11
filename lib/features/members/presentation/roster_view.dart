import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/members/application/members_providers.dart';
import 'package:gameior/features/members/domain/member.dart';
import 'package:gameior/features/payments/application/payments_providers.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_empty_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/core/utils/app_toast.dart';
import 'package:gameior/features/members/presentation/widgets/member_row.dart';

class MembersRosterView extends ConsumerStatefulWidget {
  final String groupId;
  final MemberRole currentRole;

  const MembersRosterView({
    required this.groupId,
    required this.currentRole,
    super.key,
  });

  @override
  ConsumerState<MembersRosterView> createState() => _MembersRosterViewState();
}

class _MembersRosterViewState extends ConsumerState<MembersRosterView> {
  bool _isReminding = false;
  String _searchQuery = '';
  String _sortBy = 'role'; // 'role' | 'name' | 'dues'
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(groupMembersProvider(widget.groupId));
    final hasDuesAsync = ref.watch(groupHasUnpaidDuesProvider(widget.groupId));
    final duesAsync = ref.watch(adminDuesByPlayerProvider(widget.groupId));

    return membersAsync.when(
      loading: () => const SingleChildScrollView(
        child: Column(
          children: [
            AppLoadingShimmer(type: ShimmerType.memberRow),
            AppLoadingShimmer(type: ShimmerType.memberRow),
            AppLoadingShimmer(type: ShimmerType.memberRow),
          ],
        ),
      ),
      error: (e, _) => AppErrorState(
        message: 'Failed to load roster: $e',
        onRetry: () => ref.invalidate(groupMembersProvider(widget.groupId)),
      ),
      data: (members) {
        if (members.isEmpty) {
          return const AppEmptyState(
            message: 'No members in this group yet. Share the invite code to add players!',
          );
        }

        final duesList = duesAsync.valueOrNull ?? [];
        final duesMap = {
          for (final summary in duesList) summary.playerId: summary.totalPendingPaise
        };

        // Apply local search filtering
        final filteredMembers = members.where((m) {
          return m.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        // Apply sorting state
        if (_sortBy == 'name') {
          filteredMembers.sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
        } else if (_sortBy == 'dues') {
          filteredMembers.sort((a, b) {
            final dueA = duesMap[a.userId] ?? 0;
            final dueB = duesMap[b.userId] ?? 0;
            final dueCompare = dueB.compareTo(dueA); // Descending dues
            if (dueCompare != 0) return dueCompare;
            return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
          });
        } else {
          // Default role sort
          filteredMembers.sort((a, b) {
            final roleCompare = a.role.index.compareTo(b.role.index);
            if (roleCompare != 0) return roleCompare;
            return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
          });
        }

        final hosts = filteredMembers.where((m) => m.role == MemberRole.host).toList();
        final coHosts = filteredMembers.where((m) => m.role == MemberRole.coHost).toList();
        final players = filteredMembers.where((m) => m.role == MemberRole.player).toList();

        final isAdmin = widget.currentRole == MemberRole.host || widget.currentRole == MemberRole.coHost;
        final hasDues = hasDuesAsync.valueOrNull ?? false;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(groupMembersProvider(widget.groupId));
            ref.invalidate(groupHasUnpaidDuesProvider(widget.groupId));
            ref.invalidate(adminDuesByPlayerProvider(widget.groupId));
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search roster...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val.trim());
                  },
                ),
              ),

              // Sort Chips
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.base),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('Sort by: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(width: AppSpacing.xs),
                      ChoiceChip(
                        label: const Text('Role'),
                        selected: _sortBy == 'role',
                        onSelected: (selected) {
                          if (selected) setState(() => _sortBy = 'role');
                        },
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      ChoiceChip(
                        label: const Text('Name'),
                        selected: _sortBy == 'name',
                        onSelected: (selected) {
                          if (selected) setState(() => _sortBy = 'name');
                        },
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: AppSpacing.xs),
                        ChoiceChip(
                          label: const Text('Dues'),
                          selected: _sortBy == 'dues',
                          onSelected: (selected) {
                            if (selected) setState(() => _sortBy = 'dues');
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (isAdmin && hasDues)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.base),
                  child: AppButton(
                    label: 'Remind Pending Dues',
                    leadingIcon: Icons.notifications_active_outlined,
                    variant: AppButtonVariant.secondary,
                    isLoading: _isReminding,
                    onPressed: _isReminding
                        ? null
                        : () async {
                            setState(() => _isReminding = true);
                            try {
                              await ref
                                  .read(adminDuesNotifierProvider(widget.groupId).notifier)
                                  .triggerReminders();
                              if (mounted) {
                                showToast(context, 'Reminders sent to all members with pending dues!');
                              }
                            } catch (e) {
                              if (mounted) {
                                showToast(context, 'Failed to send reminders: $e', isError: true);
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isReminding = false);
                              }
                            }
                          },
                  ),
                ),

              if (_sortBy == 'role') ...[
                if (hosts.isNotEmpty) ...[
                  const _RosterSectionHeader(title: 'HOST'),
                  ...hosts.map((m) => MemberRow(groupId: widget.groupId, member: m, currentRole: widget.currentRole)),
                  const SizedBox(height: AppSpacing.base),
                ],
                if (coHosts.isNotEmpty) ...[
                  const _RosterSectionHeader(title: 'CO-HOSTS'),
                  ...coHosts.map((m) => MemberRow(groupId: widget.groupId, member: m, currentRole: widget.currentRole)),
                  const SizedBox(height: AppSpacing.base),
                ],
                if (players.isNotEmpty) ...[
                  const _RosterSectionHeader(title: 'PLAYERS'),
                  ...players.map((m) => MemberRow(groupId: widget.groupId, member: m, currentRole: widget.currentRole)),
                ],
              ] else ...[
                ...filteredMembers.map((m) => MemberRow(groupId: widget.groupId, member: m, currentRole: widget.currentRole)),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}

class _RosterSectionHeader extends StatelessWidget {
  final String title;
  const _RosterSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs),
      child: Text(
        title,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
