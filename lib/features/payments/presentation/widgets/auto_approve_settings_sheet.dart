import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/payments/data/payments_repository.dart';
import 'package:gameior/core/utils/app_toast.dart';

class AutoApproveSettingsBottomSheet extends ConsumerStatefulWidget {
  final String groupId;
  const AutoApproveSettingsBottomSheet({required this.groupId, super.key});

  @override
  ConsumerState<AutoApproveSettingsBottomSheet> createState() =>
      _AutoApproveSettingsBottomSheetState();
}

class _AutoApproveSettingsBottomSheetState
    extends ConsumerState<AutoApproveSettingsBottomSheet> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final groupCtxAsync = ref.watch(groupContextProvider(widget.groupId));

    return groupCtxAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Failed to load group details')),
      data: (groupCtx) {
        final autoApprove = groupCtx.group.autoApprovePayments;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Settings', style: AppTextStyles.headlineLarge),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile.adaptive(
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-approve payments', style: AppTextStyles.headlineSmall),
                subtitle: const Text('Skip manual UTR verification. Incoming player payments will be marked as PAID instantly.', style: AppTextStyles.bodySmall),
                value: autoApprove,
                onChanged: _isSaving
                    ? null
                    : (val) async {
                        setState(() => _isSaving = true);
                        try {
                          await ref.read(paymentsRepositoryProvider).setAutoApprove(
                                groupId: widget.groupId,
                                enabled: val,
                              );
                          ref.invalidate(groupContextProvider(widget.groupId));
                          if (mounted) {
                            showToast(context, val ? 'Auto-approve payments enabled!' : 'Auto-approve payments disabled!');
                          }
                        } catch (e) {
                          if (mounted) {
                            showToast(context, 'Failed to save settings.', isError: true);
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isSaving = false);
                          }
                        }
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}
