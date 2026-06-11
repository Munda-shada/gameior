import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';

import 'package:gameior/features/settings/presentation/admin_settings_view.dart';
import 'package:gameior/features/settings/presentation/player_settings_view.dart';

class GroupSettingsTab extends ConsumerWidget {
  final String groupId;
  const GroupSettingsTab({required this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final contextAsync = ref.watch(groupContextProvider(groupId));

    return contextAsync.when(
      loading: () => const Scaffold(body: AppLoadingShimmer(type: ShimmerType.card)),
      error: (e, _) => Scaffold(
        body: Center(
          child: Text('Failed to load settings', style: theme.textTheme.bodyMedium),
        ),
      ),
      data: (groupContext) {
        final group = groupContext.group;
        final myRole = groupContext.myRole;
        final isAdmin = myRole == MemberRole.host || myRole == MemberRole.coHost;

        if (isAdmin) {
          return AdminSettingsView(
            group: group,
            groupId: groupId,
            myRole: myRole,
          );
        } else {
          return PlayerSettingsView(
            group: group,
            groupId: groupId,
          );
        }
      },
    );
  }
}
