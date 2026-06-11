import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';
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

  Widget _buildSkillChip(ThemeData theme, String value, String label) {
    final isSelected = allowedSkillLevels.contains(value);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) => onSkillLevelSelected(value, selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'GAME DETAILS'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Allowed Skill Levels', style: theme.textTheme.headlineSmall),
              ),
              const SizedBox(height: AppSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _buildSkillChip(theme, 'all', 'All Levels'),
                    _buildSkillChip(theme, 'beginner', 'Beginner'),
                    _buildSkillChip(theme, 'intermediate', 'Intermediate'),
                    _buildSkillChip(theme, 'advanced', 'Advanced'),
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
