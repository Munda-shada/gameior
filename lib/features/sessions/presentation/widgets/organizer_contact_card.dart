import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/settings/application/group_settings_providers.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class OrganizerContactCard extends ConsumerWidget {
  final String hostId;

  const OrganizerContactCard({required this.hostId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hostProfileAsync = ref.watch(hostProfileProvider(hostId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'ORGANIZER CONTACT'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: hostProfileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Could not fetch host profile'),
            data: (host) {
              final name = host?['display_name'] as String? ?? 'Organizer';
              final phone = host?['phone'] as String? ?? 'No contact info';

              return Row(
                children: [
                  const Icon(Icons.person_outline, size: 24, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.headlineSmall),
                      Text('Contact: $phone', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
