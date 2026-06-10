import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/auth/data/auth_repository.dart';
import 'package:gameior/core/supabase/supabase_client.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _isDeleting = false;
  bool _confirmChecked = false;

  Future<void> _deleteAccount() async {
    if (!_confirmChecked) return;

    setState(() => _isDeleting = true);

    try {
      // TODO: Replace with your actual Edge Function or RPC call to delete the user.
      // Example:
      // await ref.read(supabaseClientProvider).functions.invoke('delete_user_account');
      // OR
      // await ref.read(supabaseClientProvider).rpc('delete_my_account');

      // Simulating a network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Sign the user out locally which triggers app_router to redirect to /login
      await ref.read(authRepositoryProvider).signOut();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete account: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delete Account'),
      ),
      body: Padding(
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
                  onChanged: (val) {
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
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.destructive,
                  foregroundColor: Colors.white,
                ),
                onPressed: (_confirmChecked && !_isDeleting) ? _deleteAccount : null,
                child: _isDeleting 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Delete Account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}