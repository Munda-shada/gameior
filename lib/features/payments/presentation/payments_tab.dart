import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';

import 'package:gameior/features/payments/presentation/admin_payments_view.dart';
import 'package:gameior/features/payments/presentation/player_payments_view.dart';

class PaymentsTab extends ConsumerWidget {
  final String groupId;
  const PaymentsTab({required this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(groupContextProvider(groupId));

    return contextAsync.when(
      loading: () => const AppLoadingShimmer(type: ShimmerType.listTile),
      error: (e, _) => AppErrorState(
        message: 'Failed to load payments context',
        onRetry: () => ref.invalidate(groupContextProvider(groupId)),
      ),
      data: (groupCtx) {
        final role = groupCtx.myRole;
        final isAdmin = role == MemberRole.host || role == MemberRole.coHost;

        if (isAdmin) {
          return AdminPaymentsView(groupId: groupId);
        } else {
          return PlayerPaymentsView(groupId: groupId, defaultUpiId: groupCtx.group.defaultUpiId ?? '');
        }
      },
    );
  }
}
