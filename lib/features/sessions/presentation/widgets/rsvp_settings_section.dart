import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class RsvpSettingsSection extends StatelessWidget {
  final TextEditingController capacityController;
  final bool allowGuests;
  final ValueChanged<bool> onAllowGuestsChanged;
  final DateTime? rsvpDeadlineDate;
  final TimeOfDay? rsvpDeadlineTime;
  final VoidCallback onSelectRsvpDeadlineDate;
  final VoidCallback onSelectRsvpDeadlineTime;
  final VoidCallback onClearDeadline;
  final String rsvpDateStr;
  final String rsvpTimeStr;

  const RsvpSettingsSection({
    required this.capacityController,
    required this.allowGuests,
    required this.onAllowGuestsChanged,
    required this.rsvpDeadlineDate,
    required this.rsvpDeadlineTime,
    required this.onSelectRsvpDeadlineDate,
    required this.onSelectRsvpDeadlineTime,
    required this.onClearDeadline,
    required this.rsvpDateStr,
    required this.rsvpTimeStr,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'RSVP LIMITS & DEADLINE'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              AppTextField(
                controller: capacityController,
                label: 'Maximum Game Capacity',
                hint: '20',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Capacity is required.';
                  final cap = int.tryParse(v) ?? 0;
                  if (cap < 2 || cap > 200) return 'Capacity must be between 2 and 200.';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile.adaptive(
                title: Text('Allow Guest RSVPs', style: theme.textTheme.headlineSmall),
                subtitle: Text('Players can add +1 or more extra guests', style: theme.textTheme.bodySmall),
                value: allowGuests,
                activeColor: theme.colorScheme.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: onAllowGuestsChanged,
              ),
              const Divider(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('RSVP Deadline (Optional)', style: theme.textTheme.headlineSmall),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onSelectRsvpDeadlineDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Deadline Date'),
                        child: Text(rsvpDeadlineDate != null ? rsvpDateStr : 'None', style: theme.textTheme.bodyLarge),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: InkWell(
                      onTap: onSelectRsvpDeadlineTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Deadline Time'),
                        child: Text(rsvpDeadlineTime != null ? rsvpTimeStr : 'None', style: theme.textTheme.bodyLarge),
                      ),
                    ),
                  ),
                ],
              ),
              if (rsvpDeadlineDate != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onClearDeadline,
                    child: Text(
                      'Clear Deadline',
                      style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.error),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
