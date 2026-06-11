import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/profile/data/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

@riverpod
Future<Map<String, dynamic>> globalProfileStats(GlobalProfileStatsRef ref) async {
  final authState = ref.watch(authStateProvider).valueOrNull;
  final user = authState?.session?.user;
  if (user == null) {
    return {
      'gamesPlayed': 0,
      'attendancePct': 0.0,
      'groupsCount': 0,
      'upcomingGames': 0,
    };
  }
  return ref.watch(profileRepositoryProvider).fetchGlobalUserStats(user.id);
}
