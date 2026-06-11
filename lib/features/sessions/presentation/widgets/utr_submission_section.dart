import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class UtrSubmissionSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSubmit;

  const UtrSubmissionSection({
    required this.controller,
    required this.isLoading,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'UTR TRANSACTION ID'),
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
                controller: controller,
                label: '12-digit UPI Transaction Ref (UTR)',
                hint: 'E.g. 408712345678',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'UTR number is required to confirm payment.';
                  if (v.length != 12) return 'UTR must be exactly 12 digits.';
                  if (!RegExp(r'^[0-9]{12}$').hasMatch(v)) return 'UTR must be numbers only.';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.base),
              AppButton(
                label: 'Submit Payment & Join',
                isLoading: isLoading,
                onPressed: onSubmit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
