import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/members/domain/member.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/features/members/presentation/widgets/member_stats_sheet.dart';

class MemberRow extends ConsumerWidget {
  final String groupId;
  final GroupMember member;
  final MemberRole currentRole;

  const MemberRow({
    required this.groupId,
    required this.member,
    required this.currentRole,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(supabaseClientProvider);
    final isMe = member.userId == client.auth.currentUser?.id;

    Color roleColor = Colors.grey;
    String roleLabel = 'Player';
    if (member.role == MemberRole.host) {
      roleColor = AppColors.waitlist;
      roleLabel = 'Host';
    } else if (member.role == MemberRole.coHost) {
      roleColor = Colors.blue;
      roleLabel = 'Co-Host';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: AppColors.border.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: 4,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(color: roleColor.withOpacity(0.3), width: 1.5),
          ),
          child: Center(
            child: Text(
              member.emoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.displayName + (isMe ? ' (You)' : ''),
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                roleLabel,
                style: AppTextStyles.labelSmall.copyWith(
                  color: roleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          member.phone,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () => _showMemberProfileSheet(context),
      ),
    );
  }

  void _showMemberProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MemberStatsSheet(
        groupId: groupId,
        member: member,
        currentUserRole: currentRole,
      ),
    );
  }
}
