import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/sessions/application/sessions_providers.dart';
import 'package:gameior/features/sessions/presentation/widgets/game_session_card.dart';
import 'package:gameior/shared/widgets/app_empty_state.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';

class UpcomingGamesView extends ConsumerWidget {
  final String groupId;
  final bool isAdmin;
  const UpcomingGamesView({required this.groupId, required this.isAdmin, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(upcomingGamesProvider(groupId));
    final client = ref.watch(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;

    return gamesAsync.when(
      loading: () => const AppLoadingShimmer(type: ShimmerType.card),
      error: (e, _) => AppErrorState(
        message: 'Failed to load upcoming games',
        onRetry: () => ref.invalidate(upcomingGamesProvider(groupId)),
      ),
      data: (games) {
        if (games.isEmpty) {
          if (isAdmin) {
            return AppEmptyState(
              icon: Icons.sports_outlined,
              message: 'Ready to schedule? Tap + to create your first session.',
              ctaLabel: 'Create Game',
              onCtaTap: () => context.push('/group/$groupId/create-game'),
            );
          } else {
            return const AppEmptyState(
              icon: Icons.sports_outlined,
              message: 'No sessions scheduled yet. Check back soon.',
            );
          }
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(upcomingGamesProvider(groupId)),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: games.length,
            itemBuilder: (ctx, index) {
              final game = games[index];
              return GameSessionCard(groupId: groupId, game: game, userId: userId);
            },
          ),
        );
      },
    );
  }
}
