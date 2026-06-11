import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Delete Your Account?',
            style: textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'If you delete your account, you will permanently lose your profile, group memberships, and game history. This action cannot be undone.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Checkbox(
                value: _confirmChecked,
                activeColor: colorScheme.error,
                onChanged: widget.isDeleting
                    ? null
                    : (val) {
                        setState(() => _confirmChecked = val ?? false);
                      },
              ),
              Expanded(
                child: Text(
                  'I understand that my account will be permanently deleted.',
                  style: textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_confirmChecked) ...[
            Text(
              'Type "DELETE" to confirm account deletion:',
              style: textTheme.bodySmall,
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
