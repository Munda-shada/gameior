import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/settings/application/group_settings_providers.dart';
import 'package:gameior/features/groups/application/groups_provider.dart';
import 'package:gameior/features/groups/domain/group.dart';
import 'package:gameior/features/members/data/members_repository.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_dialog.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class GroupSettingsTab extends ConsumerWidget {
  final String groupId;
  const GroupSettingsTab({required this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(groupContextProvider(groupId));

    return contextAsync.when(
      loading: () => const Scaffold(body: AppLoadingShimmer(type: ShimmerType.card)),
      error: (e, _) => Scaffold(
        body: Center(
          child: Text('Failed to load settings', style: AppTextStyles.bodyMedium),
        ),
      ),
      data: (groupContext) {
        final group = groupContext.group;
        final myRole = groupContext.myRole;
        final isAdmin = myRole == MemberRole.host || myRole == MemberRole.coHost;

        if (isAdmin) {
          return AdminSettingsView(
            group: group,
            groupId: groupId,
            myRole: myRole,
          );
        } else {
          return PlayerSettingsView(
            group: group,
            groupId: groupId,
          );
        }
      },
    );
  }
}

class AdminSettingsView extends ConsumerStatefulWidget {
  final Group group;
  final String groupId;
  final MemberRole myRole;

  const AdminSettingsView({
    required this.group,
    required this.groupId,
    required this.myRole,
    super.key,
  });

  @override
  ConsumerState<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends ConsumerState<AdminSettingsView> {
  // General Info
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late SportType _sport;
  bool _isSavingGeneral = false;

  // Access Control
  late bool _requireApproval;
  late bool _allowMemberInvites;
  late bool _allowGuests;
  bool _isSavingAccess = false;

  // Payment Settings
  late PaymentModel _paymentModel;
  late final TextEditingController _costController;
  late final TextEditingController _upiController;
  late bool _showCostBreakdown;
  late bool _autoApprovePayments;
  bool _isSavingPayments = false;

  // Club Rules
  late final TextEditingController _rulesController;
  bool _isSavingRules = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _descController = TextEditingController(text: widget.group.description ?? '');
    _sport = widget.group.sport;

    _requireApproval = widget.group.autoApproveJoins == false;
    _allowMemberInvites = widget.group.allowMemberInvites;
    _allowGuests = widget.group.allowGuests;

    _paymentModel = widget.group.paymentModel;
    _costController = TextEditingController(text: (widget.group.defaultCostPaise / 100.0).toStringAsFixed(0));
    _upiController = TextEditingController(text: widget.group.defaultUpiId ?? '');
    _showCostBreakdown = widget.group.showCostBreakdown;
    _autoApprovePayments = widget.group.autoApprovePayments;

    _rulesController = TextEditingController(text: widget.group.clubRules ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _costController.dispose();
    _upiController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _saveGeneralInfo() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group name cannot be empty.')),
      );
      return;
    }

    setState(() => _isSavingGeneral = true);
    final client = ref.read(supabaseClientProvider);
    try {
      await client.from('groups').update({
        'name': name,
        'description': _descController.text.trim(),
        'sport': _sport.name,
      }).eq('id', widget.groupId);

      ref.invalidate(groupContextProvider(widget.groupId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('General settings saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingGeneral = false);
      }
    }
  }

  Future<void> _saveAccessSettings() async {
    setState(() => _isSavingAccess = true);
    final client = ref.read(supabaseClientProvider);
    try {
      await client.from('groups').update({
        'auto_approve_joins': !_requireApproval,
        'allow_member_invites': _allowMemberInvites,
        'allow_guests': _allowGuests,
      }).eq('id', widget.groupId);

      ref.invalidate(groupContextProvider(widget.groupId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access control settings saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingAccess = false);
      }
    }
  }

  Future<void> _savePaymentSettings() async {
    final costText = _costController.text.trim();
    final costDouble = double.tryParse(costText) ?? 0.0;
    final costPaise = (costDouble * 100.0).round();

    setState(() => _isSavingPayments = true);
    final client = ref.read(supabaseClientProvider);
    try {
      await client.from('groups').update({
        'payment_model': _paymentModel.name,
        'default_cost_paise': costPaise,
        'default_upi_id': _upiController.text.trim(),
        'show_cost_breakdown': _showCostBreakdown,
        'auto_approve_payments': _autoApprovePayments,
      }).eq('id', widget.groupId);

      ref.invalidate(groupContextProvider(widget.groupId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment settings saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingPayments = false);
      }
    }
  }

  Future<void> _saveClubRules() async {
    setState(() => _isSavingRules = true);
    final client = ref.read(supabaseClientProvider);
    try {
      await client.from('groups').update({
        'club_rules': _rulesController.text.trim(),
      }).eq('id', widget.groupId);

      ref.invalidate(groupContextProvider(widget.groupId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Club rules updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingRules = false);
      }
    }
  }

  Future<void> _deleteGroup() async {
    final repository = ref.read(membersRepositoryProvider);
    final hasDues = await repository.hasGroupUnpaidDues(groupId: widget.groupId);

    if (!mounted) return;
    if (hasDues) {
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
          groupName: widget.group.name,
          onConfirm: () async {
            final client = ref.read(supabaseClientProvider);
            try {
              await client.from('groups').delete().eq('id', widget.groupId);
              ref.invalidate(myGroupsNotifierProvider);
              if (context.mounted) {
                context.go('/home/groups');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Group "${widget.group.name}" deleted permanently.')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete group: $e')),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHost = widget.myRole == MemberRole.host;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. General Section
          const SectionHeader(title: 'GENERAL SETTINGS'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Group Name',
                  hint: 'E.g. Smashers Club',
                  maxLength: 60,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _descController,
                  label: 'Description',
                  hint: 'E.g. Weekly badminton games...',
                  maxLength: 300,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<SportType>(
                  value: _sport,
                  decoration: const InputDecoration(
                    labelText: 'Sport Type',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: SportType.values.map((s) {
                    return DropdownMenuItem<SportType>(
                      value: s,
                      child: Text(s.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _sport = val);
                  },
                ),
                const SizedBox(height: AppSpacing.base),
                AppButton(
                  label: 'Save General Info',
                  isLoading: _isSavingGeneral,
                  onPressed: _saveGeneralInfo,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // 2. Access Section
          const SectionHeader(title: 'ACCESS CONTROL'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: const Text('Require Host Approval', style: AppTextStyles.headlineSmall),
                  subtitle: const Text('New players must be approved by host to join', style: AppTextStyles.bodySmall),
                  value: _requireApproval,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _requireApproval = val),
                ),
                SwitchListTile.adaptive(
                  title: const Text('Allow Member Invites', style: AppTextStyles.headlineSmall),
                  subtitle: const Text('Members can share the invite code with others', style: AppTextStyles.bodySmall),
                  value: _allowMemberInvites,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _allowMemberInvites = val),
                ),
                SwitchListTile.adaptive(
                  title: const Text('Allow Guests', style: AppTextStyles.headlineSmall),
                  subtitle: const Text('Members can add external guests when they RSVP', style: AppTextStyles.bodySmall),
                  value: _allowGuests,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _allowGuests = val),
                ),
                const SizedBox(height: AppSpacing.base),
                AppButton(
                  label: 'Save Access Controls',
                  isLoading: _isSavingAccess,
                  onPressed: _saveAccessSettings,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // 3. Payments Section
          const SectionHeader(title: 'PAYMENTS SETTINGS'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payment Model', style: AppTextStyles.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('PRE-PAID')),
                        selected: _paymentModel == PaymentModel.prepaid,
                        selectedColor: AppColors.primary.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: _paymentModel == PaymentModel.prepaid ? AppColors.primaryDark : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _paymentModel = PaymentModel.prepaid);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('POST-PAID')),
                        selected: _paymentModel == PaymentModel.postpaid,
                        selectedColor: AppColors.primary.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: _paymentModel == PaymentModel.postpaid ? AppColors.primaryDark : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _paymentModel = PaymentModel.postpaid);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _costController,
                  label: 'Default Cost (₹)',
                  hint: 'E.g. 150',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  controller: _upiController,
                  label: 'Default Organizer UPI ID',
                  hint: 'E.g. name@upi',
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile.adaptive(
                  title: const Text('Show Cost Breakdown', style: AppTextStyles.headlineSmall),
                  subtitle: const Text('Show total cost calculations to players', style: AppTextStyles.bodySmall),
                  value: _showCostBreakdown,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _showCostBreakdown = val),
                ),
                SwitchListTile.adaptive(
                  title: const Text('Auto-Approve Payments', style: AppTextStyles.headlineSmall),
                  subtitle: const Text('Automatically verify submitted UTR codes', style: AppTextStyles.bodySmall),
                  value: _autoApprovePayments,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _autoApprovePayments = val),
                ),
                const SizedBox(height: AppSpacing.base),
                AppButton(
                  label: 'Save Payment Settings',
                  isLoading: _isSavingPayments,
                  onPressed: _savePaymentSettings,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // 4. Club Rules Section
          const SectionHeader(title: 'CLUB RULES'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                AppTextField(
                  controller: _rulesController,
                  label: 'Rules & Regulations',
                  hint: 'Define guidelines, penalty rules, RSVP rules...',
                  maxLength: 1000,
                  maxLines: 5,
                ),
                const SizedBox(height: AppSpacing.base),
                AppButton(
                  label: 'Save Club Rules',
                  isLoading: _isSavingRules,
                  onPressed: _saveClubRules,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // 5. Danger Zone (Host only)
          if (isHost) ...[
            const SectionHeader(title: 'DANGER ZONE'),
            Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.destructiveMuted,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.destructive.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Permanent Actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.destructive)),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Deleting a group will permanently remove all matches, payment dues, and member records. This cannot be undone.',
                    style: TextStyle(fontSize: 12, color: AppColors.destructive),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  AppButton(
                    label: 'Delete Group Forever',
                    variant: AppButtonVariant.destructive,
                    onPressed: _deleteGroup,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class PlayerSettingsView extends ConsumerStatefulWidget {
  final Group group;
  final String groupId;

  const PlayerSettingsView({
    required this.group,
    required this.groupId,
    super.key,
  });

  @override
  ConsumerState<PlayerSettingsView> createState() => _PlayerSettingsViewState();
}

class _PlayerSettingsViewState extends ConsumerState<PlayerSettingsView> {
  bool _notificationsEnabled = true; // Local UI preference setting

  Future<void> _leaveGroup() async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    // 1. Check for unpaid dues first
    final repository = ref.read(membersRepositoryProvider);
    final hasDues = await repository.hasUnpaidDues(
      groupId: widget.groupId,
      userId: userId,
    );

    if (hasDues) {
      if (mounted) {
        showAppDialog(
          context: context,
          title: 'Unpaid Dues Pending',
          message: 'You cannot leave this group because you have outstanding unpaid or pending verification dues. Please settle them in the Payments tab first.',
          confirmLabel: 'OK',
        );
      }
      return;
    }

    // 2. Propose confirmation dialog to leave
    if (!mounted) return;
    final confirm = await showAppDialog(
      context: context,
      title: 'Leave Group?',
      message: 'Are you sure you want to leave this group? You will need an invite code to join again.',
      confirmLabel: 'Leave',
      isDestructive: true,
    );

    if (confirm == true) {
      try {
        await client
            .from('group_members')
            .update({'status': 'left'})
            .eq('group_id', widget.groupId)
            .eq('user_id', userId);

        ref.invalidate(myGroupsNotifierProvider);
        if (context.mounted) {
          context.go('/home/groups');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have left the group.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to leave the group.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hostProfileAsync = ref.watch(hostProfileProvider(widget.group.hostId));
    final matchesPlayedAsync = ref.watch(matchesPlayedProvider(widget.groupId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Stats Hero
          matchesPlayedAsync.when(
            loading: () => const SizedBox(
              height: 80,
              child: AppLoadingShimmer(type: ShimmerType.card),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (count) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.base),
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_outlined, color: Colors.white, size: 40),
                    const SizedBox(width: AppSpacing.base),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count',
                          style: AppTextStyles.displayLarge.copyWith(color: Colors.white),
                        ),
                        Text(
                          'Matches Played in Club',
                          style: AppTextStyles.labelMedium.copyWith(color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // 2. Preferences
          const SectionHeader(title: 'PREFERENCES'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: SwitchListTile.adaptive(
              title: const Text('Group Notifications', style: AppTextStyles.headlineSmall),
              subtitle: const Text('Get push notifications for this group\'s games', style: AppTextStyles.bodySmall),
              value: _notificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications ${val ? 'enabled' : 'disabled'} for this group.')),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // 3. Read-Only Info
          const SectionHeader(title: 'CLUB INFORMATION'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: hostProfileAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Could not fetch organizer contact details'),
              data: (host) {
                final orgName = host?['display_name'] as String? ?? 'Organizer';
                final orgPhone = host?['phone'] as String? ?? 'No contact number';
                final hasUpi = widget.group.defaultUpiId != null && widget.group.defaultUpiId!.isNotEmpty;

                return Column(
                  children: [
                    _buildInfoRow('Sport Type', widget.group.sport.name.toUpperCase()),
                    const Divider(height: AppSpacing.base),
                    _buildInfoRow('Organizer Name', orgName),
                    const Divider(height: AppSpacing.base),
                    _buildInfoRow('Organizer Contact', orgPhone),
                    const Divider(height: AppSpacing.base),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Default UPI ID', style: AppTextStyles.bodySmall),
                              const SizedBox(height: 2),
                              Text(widget.group.defaultUpiId ?? 'None', style: AppTextStyles.headlineSmall),
                            ],
                          ),
                        ),
                        if (hasUpi)
                          IconButton(
                            icon: const Icon(Icons.copy, color: AppColors.primary),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: widget.group.defaultUpiId!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('UPI ID copied to clipboard!')),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // 4. Club Rules
          const SectionHeader(title: 'CLUB RULES & GUIDELINES'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              widget.group.clubRules?.isNotEmpty == true
                  ? widget.group.clubRules!
                  : 'No rules set by organizer yet.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // 5. Danger Zone (Player)
          const SectionHeader(title: 'DANGER ZONE'),
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.destructiveMuted,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.destructive.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Leave Group', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.destructive)),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Leaving the group removes your access to the game calendar, announcements, and match history.',
                  style: TextStyle(fontSize: 12, color: AppColors.destructive),
                ),
                const SizedBox(height: AppSpacing.base),
                AppButton(
                  label: 'Leave Group',
                  variant: AppButtonVariant.destructive,
                  onPressed: _leaveGroup,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.headlineSmall),
        ],
      ),
    );
  }
}

class DeleteGroupDialog extends StatefulWidget {
  final String groupName;
  final VoidCallback onConfirm;
  const DeleteGroupDialog({required this.groupName, required this.onConfirm, super.key});

  @override
  State<DeleteGroupDialog> createState() => _DeleteGroupDialogState();
}

class _DeleteGroupDialogState extends State<DeleteGroupDialog> {
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
    return AlertDialog(
      title: const Text('Delete Group Permanently?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This action CANNOT be undone. All games, announcements, and payment history will be permanently deleted.',
            style: TextStyle(color: AppColors.destructive, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            'Type the group name "${widget.groupName}" to confirm deletion:',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter group name',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            onChanged: (text) {
              setState(() {
                _isValid = text.trim() == widget.groupName;
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
            backgroundColor: AppColors.destructive,
            foregroundColor: Colors.white,
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
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Delete Forever'),
        ),
      ],
    );
  }
}
