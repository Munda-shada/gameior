import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/profile/data/profile_repository.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';
import 'package:gameior/features/profile/application/signup_provider.dart';
import 'package:gameior/core/utils/app_toast.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _phoneController;
  String _selectedEmoji = '🏸';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _phoneController = TextEditingController();

    // Pre-fill existing profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(currentUserProvider).valueOrNull;
      if (profile != null) {
        _displayNameController.text = profile.displayName;
        String phoneVal = profile.phone ?? '';
        if (phoneVal.startsWith('+91')) {
          phoneVal = phoneVal.substring(3);
        }
        _phoneController.text = phoneVal;
        setState(() {
          _selectedEmoji = profile.emoji;
        });
      }
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showEmojiPicker() {
    showAppBottomSheet(
      context: context,
      title: 'Choose Your Emoji',
      child: EmojiPickerGrid(
        onSelected: (emoji) {
          setState(() => _selectedEmoji = emoji);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final profile = ref.read(currentUserProvider).valueOrNull;
      
      if (profile != null) {
        final phoneText = _phoneController.text.trim();
        await profileRepo.saveProfile(
          userId: profile.id,
          displayName: _displayNameController.text.trim(),
          phone: phoneText.isEmpty ? null : '+91$phoneText',
          emoji: _selectedEmoji,
        );
        
        // Refresh current user data to reflect changes immediately
        ref.invalidate(currentUserProvider);
        
        if (mounted) {
          showToast(context, 'Profile updated successfully');
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Failed to update profile: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showEmojiPicker,
                  child: Column(
                    children: [
                      Text(
                        _selectedEmoji,
                        style: const TextStyle(fontSize: 72),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'Tap to change',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Display Name', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Your name'),
                enabled: !_isLoading,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Display name is required';
                  if (val.trim().length > 32) return 'Display name must be less than 32 characters';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Phone Number', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(), 
                  prefixText: '+91 ',
                  hintText: '9876543210',
                  helperText: 'Enter a 10-digit mobile number',
                  counterText: '',
                ),
                enabled: !_isLoading,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return null;
                  if (val.trim().length != 10) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}