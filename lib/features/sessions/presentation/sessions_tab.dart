import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gameior/core/constants/app_constants.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';

import 'package:gameior/features/sessions/presentation/upcoming_games_view.dart';
import 'package:gameior/features/sessions/presentation/past_games_view.dart';

class SessionsTab extends ConsumerStatefulWidget {
  final String groupId;
  const SessionsTab({required this.groupId, super.key});

  @override
  ConsumerState<SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends ConsumerState<SessionsTab> {
  int _pastGamesLimit = AppConstants.pastGamesInitialLimit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contextAsync = ref.watch(groupContextProvider(widget.groupId));

    return contextAsync.when(
      loading: () => const Scaffold(body: AppLoadingShimmer(type: ShimmerType.listTile)),
      error: (e, _) => Scaffold(
        body: AppErrorState(
          message: 'Failed to load group sessions context',
          onRetry: () => ref.invalidate(groupContextProvider(widget.groupId)),
        ),
      ),
      data: (groupContext) {
        final myRole = groupContext.myRole;
        final isAdmin = myRole == MemberRole.host || myRole == MemberRole.coHost;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: theme.colorScheme.surfaceContainer,
                child: TabBar(
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  indicatorColor: theme.colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Upcoming Games'),
                    Tab(text: 'Past Games'),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                UpcomingGamesView(groupId: widget.groupId, isAdmin: isAdmin),
                PastGamesView(
                  groupId: widget.groupId,
                  isAdmin: isAdmin,
                  limit: _pastGamesLimit,
                  onLoadMore: () {
                    setState(() {
                      _pastGamesLimit += AppConstants.pastGamesLoadMoreStep;
                    });
                  },
                ),
              ],
            ),
            floatingActionButton: isAdmin
                ? FloatingActionButton(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    onPressed: () => context.push('/group/${widget.groupId}/create-game'),
                    child: const Icon(Icons.add),
                  )
                : null,
          ),
        );
      },
    );
  }
}
