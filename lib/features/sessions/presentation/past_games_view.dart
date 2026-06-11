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

class PastGamesView extends ConsumerWidget {
  final String groupId;
  final bool isAdmin;
  final int limit;
  final VoidCallback onLoadMore;

  const PastGamesView({
    required this.groupId,
    required this.isAdmin,
    required this.limit,
    required this.onLoadMore,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gamesAsync = ref.watch(pastGamesProvider(groupId: groupId, limit: limit));
    final hasPastAsync = ref.watch(hasPastGamesProvider(groupId));
    final client = ref.watch(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;

    return gamesAsync.when(
      loading: () => const AppLoadingShimmer(type: ShimmerType.listTile),
      error: (e, _) => AppErrorState(
        message: 'Failed to load past games',
        onRetry: () => ref.invalidate(pastGamesProvider(groupId: groupId, limit: limit)),
      ),
      data: (games) {
        if (games.isEmpty) {
          return const AppEmptyState(
            icon: Icons.history_outlined,
            message: 'No past sessions yet.',
          );
        }

        final showLoadMore = games.length >= limit;

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(pastGamesProvider(groupId: groupId, limit: limit));
            ref.invalidate(hasPastGamesProvider(groupId));
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.base),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (isAdmin)
                hasPastAsync.when(
                  data: (hasPast) {
                    if (!hasPast) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.base),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reuse settings from past games:',
                              style: theme.textTheme.bodySmall,
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.copy_all, size: 16),
                              label: const Text('Schedule from Template'),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              onPressed: () => context.push('/group/$groupId/create-game?template=true'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ...games.map((game) => GameSessionCard(groupId: groupId, game: game, userId: userId)),
              if (showLoadMore) ...[
                const SizedBox(height: AppSpacing.base),
                OutlinedButton(
                  onPressed: onLoadMore,
                  child: const Text('Load Older Games'),
                ),
                const SizedBox(height: AppSpacing.xl),
              ]
            ],
          ),
        );
      },
    );
  }
}
