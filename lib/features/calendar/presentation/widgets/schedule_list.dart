import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/calendar/application/calendar_providers.dart';
import 'package:gameior/features/groups/application/groups_provider.dart';
import 'package:gameior/features/calendar/presentation/widgets/event_tile.dart';

class ScheduleList extends ConsumerWidget {
  final List<Map<String, dynamic>> games;
  final String? currentUserId;

  const ScheduleList({
    required this.games,
    required this.currentUserId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasGroups = ref.watch(myGroupsNotifierProvider).valueOrNull?.isNotEmpty ?? false;

    if (games.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => ref.invalidate(calendarEventsProvider),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_available, size: 64, color: Colors.grey),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Keep your calendar active by hosting or joining new group sessions.',
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: () {
                        if (hasGroups) {
                          context.push('/home/groups');
                        } else {
                          context.push('/home/groups/create');
                        }
                      },
                      child: Text(hasGroups ? 'Host a Game' : 'Create a Group'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(calendarEventsProvider),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.base),
        itemCount: games.length,
        itemBuilder: (context, index) {
          return GameEventTile(
            game: games[index],
            currentUserId: currentUserId,
          );
        },
      ),
    );
  }
}
