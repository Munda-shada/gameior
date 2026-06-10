import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/groups/application/create_group_provider.dart';
import 'package:gameior/features/groups/application/groups_provider.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _venueController;
  late final TextEditingController _mapsController;
  late final TextEditingController _capacityController;
  late final TextEditingController _costController;
  late final TextEditingController _upiController;
  late final TextEditingController _rulesController;

  @override
  void initState() {
    super.initState();
    final form = ref.read(createGroupNotifierProvider);
    _nameController = TextEditingController(text: form.name);
    _descriptionController = TextEditingController(text: form.description);
    _venueController = TextEditingController(text: form.defaultVenue);
    _mapsController = TextEditingController(text: form.mapsLink);
    _capacityController = TextEditingController(text: form.maxCapacity.toString());
    _costController = TextEditingController(text: (form.defaultCostPaise ~/ 100).toString());
    _upiController = TextEditingController(text: form.defaultUpiId);
    _rulesController = TextEditingController(text: form.clubRules);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _mapsController.dispose();
    _capacityController.dispose();
    _costController.dispose();
    _upiController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createGroupNotifierProvider);
    final notifier = ref.read(createGroupNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create a Group'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (formState.currentStep > 1) {
              notifier.prevStep();
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: formState.currentStep / 4,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Step ${formState.currentStep} of 4',
                      style: AppTextStyles.labelMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  children: [
                    if (formState.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        margin: const EdgeInsets.only(bottom: AppSpacing.base),
                        decoration: BoxDecoration(
                          color: AppColors.destructiveMuted,
                          border: Border.all(color: AppColors.destructive),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          formState.error!,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.destructive),
                        ),
                      ),
                    ],
                    _buildStepContent(formState, notifier),
                  ],
                ),
              ),
              // Bottom buttons
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    if (formState.currentStep > 1) ...[
                      Expanded(
                        child: AppButton(
                          label: 'Back',
                          variant: AppButtonVariant.secondary,
                          onPressed: formState.isSubmitting ? null : notifier.prevStep,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.base),
                    ],
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: formState.currentStep == 4 ? 'Create Group' : 'Continue',
                        isLoading: formState.isSubmitting,
                        onPressed: formState.isSubmitting ? null : () => _onContinue(formState, notifier),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(CreateGroupFormState formState, CreateGroupNotifier notifier) {
    switch (formState.currentStep) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Group Details', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Group Name',
              hint: 'e.g. Saturday Badminton Club',
              controller: _nameController,
              maxLength: 60,
              validator: (v) => v == null || v.trim().isEmpty ? 'Group name is required' : null,
              onChanged: notifier.updateName,
            ),
            const SizedBox(height: AppSpacing.base),
            DropdownButtonFormField<SportType>(
              value: formState.sport,
              decoration: const InputDecoration(labelText: 'Sport'),
              items: SportType.values.map((sport) {
                return DropdownMenuItem(
                  value: sport,
                  child: Text(sport.name[0].toUpperCase() + sport.name.substring(1)),
                );
              }).toList(),
              validator: (v) => v == null ? 'Please select a sport' : null,
              onChanged: (v) {
                if (v != null) notifier.updateSport(v);
              },
            ),
            const SizedBox(height: AppSpacing.base),
            AppTextField(
              label: 'Description (Optional)',
              hint: 'What is this group about?',
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 300,
              onChanged: notifier.updateDescription,
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Venue', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Default Venue',
              hint: 'e.g. Star Sports Arena, Indiranagar',
              controller: _venueController,
              maxLength: 100,
              validator: (v) => v == null || v.trim().isEmpty ? 'Default venue is required' : null,
              onChanged: notifier.updateDefaultVenue,
            ),
            const SizedBox(height: AppSpacing.base),
            AppTextField(
              label: 'Google Maps Link (Optional)',
              hint: 'https://maps.google.com/...',
              controller: _mapsController,
              keyboardType: TextInputType.url,
              onChanged: notifier.updateMapsLink,
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment & Rules', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Maximum Capacity per Game',
              hint: '20',
              controller: _capacityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Capacity is required';
                final capacity = int.tryParse(v) ?? 0;
                if (capacity < 2 || capacity > 200) {
                  return 'Capacity must be between 2 and 200';
                }
                return null;
              },
              onChanged: (v) {
                final val = int.tryParse(v);
                if (val != null) notifier.updateMaxCapacity(val);
              },
            ),
            const SizedBox(height: AppSpacing.base),
            DropdownButtonFormField<PaymentModel>(
              value: formState.paymentModel,
              decoration: const InputDecoration(labelText: 'Payment Model'),
              items: PaymentModel.values.map((model) {
                return DropdownMenuItem(
                  value: model,
                  child: Text(model == PaymentModel.prepaid ? 'Pre-paid (due at RSVP)' : 'Post-paid (split cost after game)'),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) notifier.updatePaymentModel(v);
              },
            ),
            const SizedBox(height: AppSpacing.base),
            AppTextField(
              label: 'Default Session Cost (₹)',
              hint: '150',
              controller: _costController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) => v == null || v.isEmpty ? 'Default cost is required' : null,
              onChanged: (v) {
                final rupees = int.tryParse(v) ?? 0;
                notifier.updateDefaultCost(rupees * 100);
              },
            ),
            const SizedBox(height: AppSpacing.base),
            AppTextField(
              label: 'Organizer UPI ID (for collections)',
              hint: 'name@upi',
              controller: _upiController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'UPI ID is required';
                if (!v.contains('@')) return 'Enter a valid UPI ID';
                return null;
              },
              onChanged: notifier.updateDefaultUpiId,
            ),
            const SizedBox(height: AppSpacing.base),
            AppTextField(
              label: 'Club Rules',
              hint: 'Rules, timings, guest policies...',
              controller: _rulesController,
              maxLines: 4,
              maxLength: 1000,
              validator: (v) => v == null || v.trim().isEmpty ? 'Club rules are required' : null,
              onChanged: notifier.updateClubRules,
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Access Settings', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              title: const Text('Require approval to join'),
              subtitle: const Text('New members must request to join'),
              value: formState.requireApproval,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: notifier.updateRequireApproval,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Allow members to invite'),
              subtitle: const Text('Players can view and share the invite code'),
              value: formState.allowMemberInvites,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: notifier.updateAllowMemberInvites,
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Allow guests'),
              subtitle: const Text('Players can add guests (up to 5) when RSVPing'),
              value: formState.allowGuests,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              onChanged: notifier.updateAllowGuests,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _onContinue(CreateGroupFormState formState, CreateGroupNotifier notifier) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (formState.currentStep < 4) {
      notifier.nextStep();
    } else {
      final groupId = await notifier.submit();
      if (groupId != null && mounted) {
        // Invalidate groups list to fetch the new group
        ref.invalidate(myGroupsNotifierProvider);
        context.go('/group/$groupId');
      }
    }
  }
}