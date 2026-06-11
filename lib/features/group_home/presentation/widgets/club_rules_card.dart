import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class ClubRulesCard extends StatefulWidget {
  final String rules;
  const ClubRulesCard({required this.rules, super.key});

  @override
  State<ClubRulesCard> createState() => _ClubRulesCardState();
}

class _ClubRulesCardState extends State<ClubRulesCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasRules = widget.rules.trim().isNotEmpty;
    final displayRules = hasRules ? widget.rules : 'No club rules defined yet.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'CLUB RULES'),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.push_pin, color: AppColors.waitlist),
                title: const Text('Pinned Rules & Guidelines', style: AppTextStyles.headlineSmall),
                trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                onTap: () => setState(() => _isExpanded = !_isExpanded),
              ),
              if (_isExpanded) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
                  child: Divider(height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      displayRules,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
