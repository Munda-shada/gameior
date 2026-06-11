import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gameior/core/constants/app_constants.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/utils/app_toast.dart';
import 'package:gameior/features/profile/data/profile_repository.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';

part 'signup_provider.g.dart';



@riverpod
class SignupNotifier extends _$SignupNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> saveProfile({
    required String displayName,
    required String phone,
    required String emoji,
  }) async {
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(profileRepositoryProvider).saveProfile(
        userId:      user.id,
        displayName: displayName,
        phone:       '+91$phone',
        emoji:       emoji,
      );
      ref.invalidate(currentUserProvider);
    });
  }
}

class EmojiPickerGrid extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const EmojiPickerGrid({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const emojis = ['🏸','⚽','🏀','🎾','🏐','🏏','🥊','🏊','🚴','🤸','🐼','🦁','🐯','🦊','🦅'];
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
      itemCount: emojis.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onSelected(emojis[index]),
          child: Center(
            child: Text(emojis[index], style: const TextStyle(fontSize: 32)),
          ),
        );
      },
    );
  }
}

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController  = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedEmoji  = '🏸';
  final _formKey = GlobalKey<FormState>();

  // Pre-fill name from OAuth
  @override
  void initState() {
    super.initState();
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    final oauthName = user?.userMetadata?['full_name'] as String?;
    if (oauthName != null) _nameController.text = oauthName;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupNotifierProvider);

    ref.listen(signupNotifierProvider, (_, next) {
      if (next.hasError) {
        showToast(context, 'Failed to save profile. Try again.', isError: true);
      }
      // On success, router automatically redirects (currentUserProvider invalidated)
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Set Up Your Profile'),
        automaticallyImplyLeading: false, // no back button
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            children: [
              // Emoji picker section
              Center(
                child: GestureDetector(
                  onTap: _showEmojiPicker,
                  child: Column(
                    children: [
                      Text(_selectedEmoji, 
                           style: const TextStyle(fontSize: 72)),
                      Text('Tap to change',
                           style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Display name
              AppTextField(
                label: 'Display Name',
                hint: 'How others will see you',
                controller: _nameController,
                maxLength: AppConstants.maxDisplayNameLength,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Display name is required';
                  }
                  if (v.trim().length > AppConstants.maxDisplayNameLength) {
                    return 'Max ${AppConstants.maxDisplayNameLength} characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.base),

              // Phone number
              AppTextField(
                label: 'Mobile Number',
                hint: '98765 43210',
                controller: _phoneController,
                prefixText: '+91 ',
                keyboardType: TextInputType.number,
                maxLength: 10,
                validator: (v) {
                  if (v == null || v.length != 10) {
                    return 'Enter a valid 10-digit mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppButton(
                label: 'Get Started',
                isLoading: state.isLoading,
                onPressed: state.isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    ref.read(signupNotifierProvider.notifier).saveProfile(
      displayName: _nameController.text.trim(),
      phone:       _phoneController.text.trim(),
      emoji:       _selectedEmoji,
    );
  }

  void _showEmojiPicker() {
    // Show bottom sheet with emoji grid
    // Emojis: ['🏸','⚽','🏀','🎾','🏐','🏏','🥊','🏊','🚴','🤸','🐼','🦁','🐯','🦊','🦅']
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
}