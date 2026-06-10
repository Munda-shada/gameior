import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gameior/core/supabase/supabase_client.dart';

part 'calendar_providers.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> calendarGames(CalendarGamesRef ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];

  // 1. Fetch user's active group IDs
  final membershipResponse = await client
      .from('group_members')
      .select('group_id')
      .eq('user_id', userId)
      .eq('status', 'active');
  
  final groupIds = (membershipResponse as List)
      .map((row) => row['group_id'] as String)
      .toList();

  if (groupIds.isEmpty) return [];

  final now = DateTime.now();
  // Keep it lightweight: Fetch from 2 months ago to 2 months ahead
  final startDate = DateTime(now.year, now.month - 2, 1).toUtc().toIso8601String();
  final endDate = DateTime(now.year, now.month + 3, 0, 23, 59, 59).toUtc().toIso8601String();

  // 2. Fetch games for these groups with nested groups(name) select
  final response = await client
      .from('games')
      .select('*, groups(id, name, sport), rsvps(id, status, user_id, guest_count, user_is_playing, waitlist_position)')
      .inFilter('group_id', groupIds)
      .gte('scheduled_at', startDate)
      .lte('scheduled_at', endDate)
      .order('scheduled_at', ascending: true);

  return List<Map<String, dynamic>>.from(response as List);
}

@riverpod
Future<Map<DateTime, List<Map<String, dynamic>>>> calendarEvents(CalendarEventsRef ref) async {
  final games = await ref.watch(calendarGamesProvider.future);
  final events = <DateTime, List<Map<String, dynamic>>>{};

  for (final game in games) {
    if (game['scheduled_at'] == null) continue;
    final scheduledAt = DateTime.parse(game['scheduled_at'] as String).toLocal();
    final dateKey = DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day);
    events.putIfAbsent(dateKey, () => []).add(game);
  }

  return events;
}
