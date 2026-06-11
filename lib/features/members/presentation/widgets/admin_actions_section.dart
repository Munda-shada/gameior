import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/members/application/members_providers.dart';
import 'package:gameior/features/members/domain/member.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_dialog.dart';
import 'package:gameior/core/utils/app_toast.dart';
import 'package:gameior/features/payments/application/payments_providers.dart';
import 'package:gameior/features/payments/domain/payment_due.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';

class AdminActionsSection extends ConsumerWidget {
  final String groupId;
  final GroupMember member;
  final MemberRole currentUserRole;

  const AdminActionsSection({
    required this.groupId,
    required this.member,
    required this.currentUserRole,
    super.key,
  });

  Future<void> _launchUrl(String url, {String? fallback}) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (fallback != null) {
      final fallbackUri = Uri.parse(fallback);
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _confirmOwnershipTransfer(BuildContext context, WidgetRef ref) async {
    final client = ref.read(supabaseClientProvider);
    final myUserId = client.auth.currentUser?.id;
    if (myUserId == null) return;

    await showDialog(
      context: context,
      builder: (dialogCtx) => TransferOwnershipDialog(
        memberName: member.displayName,
        onConfirm: () async {
          try {
            await ref.read(groupMembersProvider(groupId).notifier).transferOwnership(
                  oldHostId: myUserId,
                  newHostId: member.userId,
                );
            if (context.mounted) {
              showToast(context, 'Ownership transferred to ${member.displayName} successfully!');
            }
          } catch (e) {
            if (context.mounted) {
              showToast(context, 'Failed to transfer ownership: $e', isError: true);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(supabaseClientProvider);
    final isMe = member.userId == client.auth.currentUser?.id;
    if (isMe) return const SizedBox.shrink();

    final adminDuesByPlayerAsync = ref.watch(adminDuesByPlayerProvider(groupId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: AppSpacing.sm),
        Text('Admin Actions', style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.base),
        adminDuesByPlayerAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SizedBox.shrink(),
          data: (summaries) {
            final summary = summaries.firstWhere(
              (s) => s.playerId == member.userId,
              orElse: () => PlayerDuesSummary(
                playerId: member.userId,
                playerName: member.displayName,
                playerEmoji: member.emoji,
                totalPendingPaise: 0,
                gameCount: 0,
                dues: [],
              ),
            );

            final amountText = '₹${(summary.totalPendingPaise / 100.0).toStringAsFixed(0)}';

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: AppSpacing.base),
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: summary.totalPendingPaise > 0 
                    ? theme.colorScheme.error.withValues(alpha: 0.1) 
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: (summary.totalPendingPaise > 0 
                      ? theme.colorScheme.error 
                      : theme.colorScheme.primary).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    summary.totalPendingPaise > 0 
                        ? Icons.warning_amber_rounded 
                        : Icons.check_circle_outline,
                    color: summary.totalPendingPaise > 0 
                        ? theme.colorScheme.error 
                        : theme.colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.totalPendingPaise > 0 ? 'Pending Dues' : 'No Pending Dues',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: summary.totalPendingPaise > 0 
                                ? theme.colorScheme.error 
                                : theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (summary.totalPendingPaise > 0)
                          Text(
                            'Outstanding from ${summary.gameCount} session(s)',
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    amountText,
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: summary.totalPendingPaise > 0 
                          ? theme.colorScheme.error 
                          : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (member.phone.isNotEmpty) ...[
          Builder(
            builder: (context) {
              final cs = Theme.of(context).colorScheme;
              final phone = member.phone.replaceAll('+', '');
              return Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'WhatsApp',
                      variant: AppButtonVariant.custom,
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      onPressed: () => _launchUrl(
                        'whatsapp://send?phone=$phone',
                        fallback: 'https://wa.me/$phone',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: 'Call',
                      variant: AppButtonVariant.custom,
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      onPressed: () => _launchUrl('tel:${member.phone}'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.base),
        ],
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Mark Paid',
                leadingIcon: Icons.price_check,
                onPressed: () async {
                  final confirm = await showAppDialog(
                    context: context,
                    title: 'Mark all dues paid?',
                    message: 'Are you sure you want to mark all outstanding dues for ${member.displayName} as paid?',
                    confirmLabel: 'Mark Paid',
                  );
                  if (confirm == true) {
                    try {
                      await ref
                          .read(adminDuesNotifierProvider(groupId).notifier)
                          .markAllPaid(member.userId);
                      if (context.mounted) {
                        showToast(context, 'All dues for ${member.displayName} marked as paid.');
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showToast(context, 'Failed to mark dues as paid: $e', isError: true);
                      }
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: 'Remind Dues',
                variant: AppButtonVariant.secondary,
                leadingIcon: Icons.notifications_active_outlined,
                onPressed: () async {
                  try {
                    await ref
                        .read(adminDuesNotifierProvider(groupId).notifier)
                        .triggerReminders(userId: member.userId);
                    if (context.mounted) {
                      showToast(context, 'Dues reminder sent to ${member.displayName}.');
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showToast(context, 'Failed to send reminder: $e', isError: true);
                    }
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.base),
        _ActionTile(
          icon: Icons.history_edu_outlined,
          label: 'View Ledger History',
          onTap: () {
            ref.read(paymentsPlayerFilterProvider(groupId).notifier).set(member.userId);
            ref.read(groupWorkspaceTabProvider(groupId).notifier).state = 3;
            Navigator.pop(context);
          },
        ),
        _ActionTile(
          icon: Icons.security_outlined,
          label: 'View Audit History',
          onTap: () {
            context.push('/group/$groupId/audit-logs?targetId=${member.userId}');
            Navigator.pop(context);
          },
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
                if (context.mounted) {
                  showToast(context, '${member.displayName} promoted to Co-Host');
                }
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
                if (context.mounted) {
                  showToast(context, '${member.displayName} demoted to Player');
                }
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
                if (context.mounted) {
                  showToast(context, '${member.displayName} removed from the group');
                }
              }
            },
          ),
        const SizedBox(height: AppSpacing.base),
      ],
    );
  }
}

class TransferOwnershipDialog extends StatefulWidget {
  final String memberName;
  final VoidCallback onConfirm;
  const TransferOwnershipDialog({required this.memberName, required this.onConfirm, super.key});

  @override
  State<TransferOwnershipDialog> createState() => _TransferOwnershipDialogState();
}

class _TransferOwnershipDialogState extends State<TransferOwnershipDialog> {
  final _controller = TextEditingController();
  bool _isValid = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Transfer Group Ownership?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This action CANNOT be undone. You will be demoted to Co-Host and ${widget.memberName} will become the new Host of the group.',
            style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Type "TRANSFER" to authorize this action:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'TRANSFER',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            onChanged: (text) {
              setState(() {
                _isValid = text.trim().toUpperCase() == 'TRANSFER';
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: (_isValid && !_isSubmitting)
              ? () async {
                  setState(() => _isSubmitting = true);
                  try {
                    widget.onConfirm();
                    Navigator.of(context).pop();
                  } catch (e) {
                    setState(() => _isSubmitting = false);
                  }
                }
              : null,
          child: _isSubmitting
              ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onError))
              : const Text('Confirm Transfer'),
        ),
      ],
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
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: isDestructive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}
