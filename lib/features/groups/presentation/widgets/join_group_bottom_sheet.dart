import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/groups/application/groups_provider.dart';
import 'package:gameior/features/groups/data/groups_repository.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/core/utils/app_toast.dart';

class JoinGroupBottomSheet extends ConsumerStatefulWidget {
  const JoinGroupBottomSheet({super.key});

  @override
  ConsumerState<JoinGroupBottomSheet> createState() => _JoinGroupBottomSheetState();
}

class _JoinGroupBottomSheetState extends ConsumerState<JoinGroupBottomSheet> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.base,
        right: AppSpacing.base,
        top: AppSpacing.base,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Join with Code', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Enter the 6-character group invite code below.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppTextField(
              label: 'Invite Code',
              hint: 'e.g. X7K2P9',
              controller: _controller,
              maxLength: 6,
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
              validator: (v) {
                if (v == null || v.trim().length != 6) {
                  return 'Enter a valid 6-character code';
                }
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _errorMessage!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.destructive),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Join Group',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final code = _controller.text.toUpperCase().trim();
    try {
      final result = await ref.read(groupsRepositoryProvider).joinGroup(code);
      
      if (result.containsKey('error')) {
        setState(() {
          _errorMessage = result['message'] as String;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          // Success
          showToast(
            context,
            result['message'] ?? 'Successfully joined group!',
            isError: false,
          );
          ref.invalidate(myGroupsNotifierProvider);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Try again.';
        _isLoading = false;
      });
    }
  }
}
