import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/utils/app_toast.dart';
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
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/shared/widgets/section_header.dart';
import 'package:gameior/features/settings/presentation/widgets/delete_group_dialog.dart';

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
  final List<Map<String, dynamic>> _costItems = [];

  void _updateCostFromBreakdown() {
    if (!_showCostBreakdown) return;
    double sum = 0.0;
    for (var item in _costItems) {
      sum += (item['costRupees'] as double? ?? 0.0);
    }
    setState(() {
      _costController.text = sum.toStringAsFixed(0);
    });
  }

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
      showToast(context, 'Group name cannot be empty.', isError: true);
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
        showToast(context, 'General settings saved!');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Error: $e', isError: true);
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
        showToast(context, 'Access control settings saved!');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Error: $e', isError: true);
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
        showToast(context, 'Payment settings saved!');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Error: $e', isError: true);
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
        showToast(context, 'Club rules updated!');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Error: $e', isError: true);
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
                showToast(context, 'Group "${widget.group.name}" deleted permanently.');
              }
            } catch (e) {
              if (context.mounted) {
                showToast(context, 'Failed to delete group: $e', isError: true);
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

          // Audit Logs Section
          const SectionHeader(title: 'AUDIT LOGS'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: ListTile(
              leading: const Icon(Icons.security_outlined, color: AppColors.primary),
              title: const Text('View Admin Logs', style: AppTextStyles.headlineSmall),
              subtitle: const Text('Auditing membership and role changes', style: AppTextStyles.bodySmall),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () {
                context.push('/group/${widget.groupId}/audit-logs');
              },
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
                  onChanged: (val) {
                    setState(() {
                      _showCostBreakdown = val;
                      if (val) _updateCostFromBreakdown();
                    });
                  },
                ),
                if (_showCostBreakdown) ...[
                  const SizedBox(height: AppSpacing.xs),
                  ..._costItems.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final labelController = TextEditingController(text: item['label'] as String);
                    final valController = TextEditingController(text: (item['costRupees'] as double).toStringAsFixed(0));

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: labelController,
                              decoration: const InputDecoration(labelText: 'Item Label', hintText: 'Court fee'),
                              onChanged: (val) {
                                _costItems[idx]['label'] = val;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: valController,
                              decoration: const InputDecoration(labelText: 'Amount (₹)'),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (val) {
                                _costItems[idx]['costRupees'] = double.tryParse(val) ?? 0.0;
                                _updateCostFromBreakdown();
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.destructive),
                            onPressed: () {
                              setState(() {
                                _costItems.removeAt(idx);
                                _updateCostFromBreakdown();
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  if (_costItems.length < 5)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Line Item'),
                        onPressed: () {
                          setState(() {
                            _costItems.add({'label': '', 'costRupees': 0.0});
                          });
                        },
                      ),
                    ),
                ],
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
