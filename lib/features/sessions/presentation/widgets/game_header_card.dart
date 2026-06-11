import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/utils/app_toast.dart';

class GameHeaderCard extends StatelessWidget {
  final Map<String, dynamic> game;
  final String status;
  final String title;
  final String venue;
  final String? desc;
  final int duration;

  const GameHeaderCard({
    required this.game,
    required this.status,
    required this.title,
    required this.venue,
    required this.desc,
    required this.duration,
    super.key,
  });

  String _formatSkillLevels(List<dynamic> skillLevels) {
    if (skillLevels.isEmpty || skillLevels.contains('all')) {
      return 'All Levels';
    }
    return skillLevels.map((s) {
      final str = s.toString();
      if (str.isEmpty) return '';
      return str[0].toUpperCase() + str.substring(1).toLowerCase();
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                game['sport'].toString().toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: status == 'upcoming'
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : (status == 'completed'
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: status == 'upcoming'
                        ? theme.colorScheme.primary
                        : (status == 'completed'
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: theme.textTheme.displayMedium),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text('$duration mins session', style: theme.textTheme.bodySmall),
              const SizedBox(width: AppSpacing.sm),
              Text('•', style: theme.textTheme.bodySmall),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _formatSkillLevels(game['allowed_skill_levels'] as List? ?? []),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(venue, style: theme.textTheme.headlineSmall),
                    if (game['maps_link'] != null && (game['maps_link'] as String).isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.map_outlined, size: 16),
                        label: const Text('Open in Google Maps', style: TextStyle(fontSize: 12)),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () async {
                          final url = game['maps_link'] as String;
                          final uri = Uri.parse(url);
                          try {
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } else {
                              if (context.mounted) {
                                showToast(context, 'Could not launch maps app.', isError: true);
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              showToast(context, 'Could not launch maps app: $e', isError: true);
                            }
                          }
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (desc != null && desc!.isNotEmpty) ...[
            const Divider(height: AppSpacing.lg),
            Text('Organizer Notes:', style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(
              desc!,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
            ),
          ],
        ],
      ),
    );
  }
}
