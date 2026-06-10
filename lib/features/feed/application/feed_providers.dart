import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/constants/app_constants.dart';

part 'feed_providers.g.dart';

/// All upcoming games across all the user's active groups, ordered by date.
/// Returns full game data including rsvps nested so we can show RSVP status.
@riverpod
Future<List<Map<String, dynamic>>> feedUpcomingGames(
  FeedUpcomingGamesRef ref,
) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];

  // 1. Get user's active group IDs
  final memberships = await client
      .from('group_members')
      .select('group_id')
      .eq('user_id', userId)
      .eq('status', 'active');

  final groupIds = (memberships as List)
      .map((m) => m['group_id'] as String)
      .toList();

  if (groupIds.isEmpty) return [];

  // 2. Fetch upcoming games with nested data
  final response = await client
      .from('games')
      .select('''
        id, title, venue, scheduled_at, max_capacity, cost_paise,
        payment_model, status, rsvp_locked, rsvp_deadline, group_id,
        groups (id, name, sport),
        rsvps (id, status, user_id, waitlist_position, guest_count, user_is_playing)
      ''')
      .inFilter('group_id', groupIds)
      .eq('status', 'upcoming')
      .order('scheduled_at', ascending: true);

  return List<Map<String, dynamic>>.from(response as List);
}

/// Global announcements across all the user's active groups.
@riverpod
Future<List<Map<String, dynamic>>> feedAnnouncements(
  FeedAnnouncementsRef ref,
) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];

  final memberships = await client
      .from('group_members')
      .select('group_id')
      .eq('user_id', userId)
      .eq('status', 'active');

  final groupIds = (memberships as List)
      .map((m) => m['group_id'] as String)
      .toList();

  if (groupIds.isEmpty) return [];

  final response = await client
      .from('announcements')
      .select('''
        id, message, created_at, linked_game_id, group_id,
        groups (name),
        profiles:created_by (display_name, emoji)
      ''')
      .inFilter('group_id', groupIds)
      .order('created_at', ascending: false)
      .limit(10); // fetch up to 10, we paginate in UI

  return List<Map<String, dynamic>>.from(response as List);
}