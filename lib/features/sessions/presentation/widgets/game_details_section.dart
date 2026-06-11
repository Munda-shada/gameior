import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class GameDetailsSection extends StatelessWidget {
  final SportType sport;
  final ValueChanged<SportType?> onSportChanged;
  final TextEditingController titleController;
  final VoidCallback onGenerateName;
  final TextEditingController descController;
  final List<String> allowedSkillLevels;
  final Function(String, bool) onSkillLevelSelected;

  const GameDetailsSection({
    required this.sport,
    required this.onSportChanged,
    required this.titleController,
    required this.onGenerateName,
    required this.descController,
    required this.allowedSkillLevels,
    required this.onSkillLevelSelected,
    super.key,
  });

  Widget _buildSkillChip(String value, String label) {
    final isSelected = allowedSkillLevels.contains(value);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary.withOpacity(0.15),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) => onSkillLevelSelected(value, selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'GAME DETAILS'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              DropdownButtonFormField<SportType>(
                value: sport,
                decoration: const InputDecoration(labelText: 'Sport Type'),
                items: SportType.values.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()));
                }).toList(),
                onChanged: onSportChanged,
              ),
              const SizedBox(height: AppSpacing.base),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: titleController,
                      label: 'Match Session Title',
                      hint: 'Sunday Smash Clash',
                      maxLength: 60,
                      validator: (v) => v == null || v.isEmpty ? 'Session title is required.' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.auto_awesome),
                    onPressed: onGenerateName,
                    tooltip: 'Generate Random Name',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: descController,
                label: 'Description / Notes (Optional)',
                hint: 'Bring your own rackets. Brand new shuttles provided.',
                maxLength: 300,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.base),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Allowed Skill Levels', style: AppTextStyles.headlineSmall),
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _buildSkillChip('all', 'All Levels'),
                    _buildSkillChip('beginner', 'Beginner'),
                    _buildSkillChip('intermediate', 'Intermediate'),
                    _buildSkillChip('advanced', 'Advanced'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
