import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/profile/data/profile_repository.dart';
import 'package:gameior/features/auth/data/auth_repository.dart';
import 'package:gameior/features/members/data/members_repository.dart';
import 'package:gameior/shared/widgets/app_dialog.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/features/settings/presentation/widgets/delete_group_dialog.dart';
import 'package:gameior/core/utils/app_toast.dart';

import 'package:gameior/features/profile/presentation/widgets/hosted_groups_section.dart';
import 'package:gameior/features/profile/presentation/widgets/delete_confirmation_form.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  AsyncValue<List<Map<String, dynamic>>>? _hostedGroupsState;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadHostedGroups();
  }

  Future<void> _loadHostedGroups() async {
    if (!mounted) return;
    setState(() {
      _hostedGroupsState = const AsyncValue.loading();
    });
    try {
      final user = ref.read(supabaseClientProvider).auth.currentUser;
      if (user != null) {
        final groups = await ref.read(profileRepositoryProvider).fetchHostedGroupsWithCoHosts(user.id);
        if (mounted) {
          setState(() {
            _hostedGroupsState = AsyncValue.data(groups);
          });
        }
      }
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _hostedGroupsState = AsyncValue.error(e, st);
        });
      }
    }
  }

  Future<void> _transferOwnership(Map<String, dynamic> group, Map<String, dynamic> coHost) async {
    final confirm = await showAppDialog(
      context: context,
      title: 'Transfer Group Ownership',
      message: "You will become a Co-Host. ${coHost['display_name']} will become the new Host of '${group['name']}'. Do you wish to proceed?",
      confirmLabel: 'Transfer',
      isDestructive: true,
    );
    
    if (confirm == true) {
      if (!mounted) return;
      final textConfirm = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) {
          final textController = TextEditingController();
          bool isValid = false;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Confirm Transfer'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Type 'TRANSFER' to authorize this action:"),
                    const SizedBox(height: 12),
                    TextField(
                      controller: textController,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'TRANSFER'),
                      onChanged: (val) {
                        setDialogState(() {
                          isValid = val.trim().toUpperCase() == 'TRANSFER';
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(dialogCtx).colorScheme.error,
                      foregroundColor: Theme.of(dialogCtx).colorScheme.onError,
                    ),
                    onPressed: isValid ? () => Navigator.pop(dialogCtx, true) : null,
                    child: const Text('Confirm'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (textConfirm == true) {
        setState(() => _isDeleting = true);
        try {
          final currentUserId = ref.read(supabaseClientProvider).auth.currentUser!.id;
          await ref.read(membersRepositoryProvider).transferOwnership(
            groupId: group['id'],
            oldHostId: currentUserId,
            newHostId: coHost['user_id'],
          );
          if (mounted) {
            showToast(context, "Ownership of '${group['name']}' transferred successfully");
          }
          await _loadHostedGroups();
        } catch (e) {
          if (mounted) {
            showToast(context, "Failed to transfer ownership: $e", isError: true);
          }
        } finally {
          if (mounted) setState(() => _isDeleting = false);
        }
      }
    }
  }

  Future<void> _deleteGroup(Map<String, dynamic> group) async {
    try {
      final hasDues = await ref.read(membersRepositoryProvider).hasGroupUnpaidDues(groupId: group['id']);
      if (hasDues) {
        if (!mounted) return;
        final proceed = await showAppDialog(
          context: context,
          title: 'Outstanding Dues Remain',
          message: 'There are players with outstanding unpaid dues in this group. Deleting the group will erase all transaction records and cancel all debts permanently. Do you wish to proceed?',
          confirmLabel: 'Proceed',
          cancelLabel: 'Cancel',
          isDestructive: true,
        );
        if (proceed != true) return;
      }

      if (!mounted) return;
      await showDialog<bool>(
        context: context,
        builder: (dialogCtx) {
          return DeleteGroupDialog(
            groupName: group['name'],
            onConfirm: () async {
              setState(() => _isDeleting = true);
              try {
                final client = ref.read(supabaseClientProvider);
                await client.from('groups').delete().eq('id', group['id']);
                 if (mounted) {
                   showToast(context, 'Group "${group['name']}" deleted permanently.');
                 }
                await _loadHostedGroups();
              } catch (e) {
                 if (mounted) {
                   showToast(context, 'Failed to delete group: $e', isError: true);
                 }
              } finally {
                if (mounted) setState(() => _isDeleting = false);
              }
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        showToast(context, 'Failed to perform dues check: $e', isError: true);
      }
    }
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);

    try {
      await ref.read(profileRepositoryProvider).deleteAccount();
      
      // Sign the user out locally which triggers app_router to redirect to /login
      await ref.read(authRepositoryProvider).signOut();
      
    } catch (e) {
      if (mounted) {
        showToast(context, 'Failed to delete account: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _showTransferBottomSheet(Map<String, dynamic> group, List<Map<String, dynamic>> coHosts) {
    showAppBottomSheet(
      context: context,
      title: 'Select New Host',
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: coHosts.length,
        itemBuilder: (context, index) {
          final coHost = coHosts[index];
          return ListTile(
            title: Text(coHost['display_name']),
            leading: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            onTap: () {
              Navigator.pop(context);
              _transferOwnership(group, coHost);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_hostedGroupsState == null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(title: const Text('Delete Account')),
        body: const Padding(
          padding: EdgeInsets.all(AppSpacing.base),
          child: Column(
            children: [
              AppLoadingShimmer(type: ShimmerType.listTile),
              SizedBox(height: AppSpacing.base),
              AppLoadingShimmer(type: ShimmerType.listTile),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Delete Account'),
      ),
      body: _hostedGroupsState!.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.base),
          child: Column(
            children: [
              AppLoadingShimmer(type: ShimmerType.listTile),
              SizedBox(height: AppSpacing.base),
              AppLoadingShimmer(type: ShimmerType.listTile),
            ],
          ),
        ),
        error: (err, _) => AppErrorState(
          message: 'Error loading groups: $err',
          onRetry: _loadHostedGroups,
        ),
        data: (groups) {
          if (groups.isNotEmpty) {
            return HostedGroupsSection(
              groups: groups,
              onTransferOwnership: _showTransferBottomSheet,
              onDeleteGroup: _deleteGroup,
              onPromoteMember: (group) {
                context.push('/group/${group['id']}?tab=2');
              },
            );
          }
          return DeleteConfirmationForm(
            isDeleting: _isDeleting,
            onDeleteAccount: _deleteAccount,
          );
        },
      ),
    );
  }
}