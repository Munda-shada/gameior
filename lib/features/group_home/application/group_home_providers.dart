import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gameior/core/supabase/supabase_client.dart';

part 'group_home_providers.g.dart';

@riverpod
Future<Map<String, dynamic>?> nextGroupGame(NextGroupGameRef ref, String groupId) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final response = await client
        .from('games')
        .select()
        .eq('group_id', groupId)
        .eq('status', 'upcoming')
        .order('scheduled_at', ascending: true)
        .limit(1)
        .maybeSingle();
    return response;
  } catch (e) {
    return null;
  }
}

@riverpod
Future<int> playerDues(PlayerDuesRef ref, String groupId) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return 0;
  try {
    final response = await client
        .from('payment_dues')
        .select('amount_paise')
        .eq('group_id', groupId)
        .eq('player_id', userId)
        .eq('status', 'unpaid');
    final sum = (response as List).fold<int>(0, (prev, element) {
      return prev + (element['amount_paise'] as num).toInt();
    });
    return sum;
  } catch (e) {
    return 0;
  }
}

@riverpod
Future<int> adminDues(AdminDuesRef ref, String groupId) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final response = await client
        .from('payment_dues')
        .select('amount_paise')
        .eq('group_id', groupId)
        .inFilter('status', ['unpaid', 'pending_verification']);
    final sum = (response as List).fold<int>(0, (prev, element) {
      return prev + (element['amount_paise'] as num).toInt();
    });
    return sum;
  } catch (e) {
    return 0;
  }
}

@riverpod
Future<List<Map<String, dynamic>>> groupAnnouncements(GroupAnnouncementsRef ref, String groupId) async {
  final client = ref.watch(supabaseClientProvider);
  final response = await client
      .from('announcements')
      .select('*, profiles:created_by(display_name, emoji)')
      .eq('group_id', groupId)
      .order('created_at', ascending: false)
      .limit(5);
  return List<Map<String, dynamic>>.from(response as List);
}

@riverpod
Future<List<Map<String, dynamic>>> groupUpcomingGames(GroupUpcomingGamesRef ref, String groupId) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final response = await client
        .from('games')
        .select('id, title, scheduled_at')
        .eq('group_id', groupId)
        .eq('status', 'upcoming')
        .order('scheduled_at', ascending: true);
    return List<Map<String, dynamic>>.from(response as List);
  } catch (e) {
    return [];
  }
}
