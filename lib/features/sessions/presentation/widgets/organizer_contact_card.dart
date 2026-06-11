import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/settings/application/group_settings_providers.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class OrganizerContactCard extends ConsumerWidget {
  final String hostId;

  const OrganizerContactCard({required this.hostId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hostProfileAsync = ref.watch(hostProfileProvider(hostId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'ORGANIZER CONTACT'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: hostProfileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Could not fetch host profile'),
            data: (host) {
              final name = host?['display_name'] as String? ?? 'Organizer';
              final phone = host?['phone'] as String? ?? '';
              final hasPhone = phone.isNotEmpty;
              final cleanPhone = phone.replaceAll('+', '');

              return Row(
                children: [
                  Icon(Icons.person_outline, size: 24, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: theme.textTheme.headlineSmall),
                        Text(
                          hasPhone ? phone : 'No contact info',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (hasPhone) ...[
                    IconButton(
                      icon: Icon(Icons.phone, color: theme.colorScheme.primary, size: 20),
                      tooltip: 'Call',
                      onPressed: () => launchUrl(Uri.parse('tel:$phone')),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
                      tooltip: 'WhatsApp',
                      onPressed: () => launchUrl(
                        Uri.parse('https://wa.me/$cleanPhone'),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
