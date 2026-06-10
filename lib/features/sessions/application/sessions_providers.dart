import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/sessions/data/sessions_repository.dart';

part 'sessions_providers.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> upcomingGames(UpcomingGamesRef ref, String groupId) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('games')
      .select('*, rsvps(id, status, user_id, guest_count, user_is_playing)')
      .eq('group_id', groupId)
      .eq('status', 'upcoming')
      .order('scheduled_at', ascending: true);
  return List<Map<String, dynamic>>.from(response as List);
}

@riverpod
Future<List<Map<String, dynamic>>> pastGames(PastGamesRef ref, {required String groupId, required int limit}) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('games')
      .select('*, rsvps(id, status, user_id, guest_count, user_is_playing)')
      .eq('group_id', groupId)
      .neq('status', 'upcoming')
      .order('scheduled_at', ascending: false)
      .limit(limit);
  return List<Map<String, dynamic>>.from(response as List);
}

@riverpod
Future<bool> hasPastGames(HasPastGamesRef ref, String groupId) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final response = await client
        .from('games')
        .select('id')
        .eq('group_id', groupId)
        .neq('status', 'upcoming')
        .limit(1);
    return (response as List).isNotEmpty;
  } catch (e) {
    return false;
  }
}

@riverpod
Future<Map<String, dynamic>> gameDetail(GameDetailRef ref, String gameId) async {
  return ref.watch(sessionsRepositoryProvider).fetchGame(gameId);
}
