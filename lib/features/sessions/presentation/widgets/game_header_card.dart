import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                game['sport'].toString().toUpperCase(),
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: status == 'upcoming'
                      ? AppColors.primaryMuted
                      : (status == 'completed' ? Colors.blue[50] : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: status == 'upcoming'
                        ? AppColors.primaryDark
                        : (status == 'completed' ? Colors.blue[800] : AppColors.textDisabled),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTextStyles.displayMedium),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text('$duration mins session', style: AppTextStyles.bodySmall),
              const SizedBox(width: AppSpacing.sm),
              const Text('•', style: AppTextStyles.bodySmall),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _formatSkillLevels(game['allowed_skill_levels'] as List? ?? []),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(venue, style: AppTextStyles.headlineSmall),
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
            const Text('Organizer Notes:', style: AppTextStyles.labelSmall),
            const SizedBox(height: 4),
            Text(desc!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          ],
        ],
      ),
    );
  }
}
