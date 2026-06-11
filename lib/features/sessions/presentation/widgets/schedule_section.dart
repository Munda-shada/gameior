import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class ScheduleSection extends StatelessWidget {
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;
  final String dateStr;
  final String timeStr;
  final String durationOption;
  final ValueChanged<String?> onDurationChanged;
  final TextEditingController customDurationController;
  final TextEditingController venueController;
  final TextEditingController mapsController;

  const ScheduleSection({
    required this.onSelectDate,
    required this.onSelectTime,
    required this.dateStr,
    required this.timeStr,
    required this.durationOption,
    required this.onDurationChanged,
    required this.customDurationController,
    required this.venueController,
    required this.mapsController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'WHEN & WHERE'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onSelectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Match Date'),
                        child: Text(dateStr, style: theme.textTheme.bodyLarge),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: InkWell(
                      onTap: onSelectTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Start Time'),
                        child: Text(timeStr, style: theme.textTheme.bodyLarge),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: durationOption,
                      decoration: const InputDecoration(labelText: 'Duration'),
                      items: const [
                        DropdownMenuItem(value: '30', child: Text('30 Mins')),
                        DropdownMenuItem(value: '60', child: Text('1 Hour')),
                        DropdownMenuItem(value: '90', child: Text('1.5 Hours')),
                        DropdownMenuItem(value: '120', child: Text('2 Hours')),
                        DropdownMenuItem(value: '150', child: Text('2.5 Hours')),
                        DropdownMenuItem(value: '180', child: Text('3 Hours')),
                        DropdownMenuItem(value: 'Custom', child: Text('Custom duration')),
                      ],
                      onChanged: onDurationChanged,
                    ),
                  ),
                  if (durationOption == 'Custom') ...[
                    const SizedBox(width: AppSpacing.base),
                    Expanded(
                      child: AppTextField(
                        controller: customDurationController,
                        label: 'Duration (mins)',
                        hint: '100',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ]
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              AppTextField(
                controller: venueController,
                label: 'Venue Location Name',
                hint: 'Court 4, Sector 5 Arena',
                maxLength: 100,
                validator: (v) => v == null || v.isEmpty ? 'Venue name is required.' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: mapsController,
                label: 'Google Maps Link (Optional)',
                hint: 'https://maps.app.goo.gl/...',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
