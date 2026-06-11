import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/widgets/app_button.dart';

class DeleteConfirmationForm extends StatefulWidget {
  final bool isDeleting;
  final VoidCallback onDeleteAccount;

  const DeleteConfirmationForm({
    required this.isDeleting,
    required this.onDeleteAccount,
    super.key,
  });

  @override
  State<DeleteConfirmationForm> createState() => _DeleteConfirmationFormState();
}

class _DeleteConfirmationFormState extends State<DeleteConfirmationForm> {
  bool _confirmChecked = false;
  final _confirmController = TextEditingController();
  bool _isDeleteInputValid = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isDeleteInputValid = _confirmController.text.trim().toUpperCase() == 'DELETE';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.destructive,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Delete Your Account?',
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'If you delete your account, you will permanently lose your profile, group memberships, and game history. This action cannot be undone.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Checkbox(
                value: _confirmChecked,
                activeColor: AppColors.destructive,
                onChanged: widget.isDeleting
                    ? null
                    : (val) {
                        setState(() => _confirmChecked = val ?? false);
                      },
              ),
              const Expanded(
                child: Text(
                  'I understand that my account will be permanently deleted.',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_confirmChecked) ...[
            const Text(
              'Type "DELETE" to confirm account deletion:',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _confirmController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'DELETE',
              ),
              enabled: !widget.isDeleting,
            ),
          ],
          const Spacer(),
          AppButton(
            label: 'Delete Account',
            variant: AppButtonVariant.destructive,
            isLoading: widget.isDeleting,
            onPressed: (_confirmChecked && _isDeleteInputValid && !widget.isDeleting)
                ? widget.onDeleteAccount
                : null,
          ),
        ],
      ),
    );
  }
}
