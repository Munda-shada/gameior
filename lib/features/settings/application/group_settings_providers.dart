import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gameior/core/supabase/supabase_client.dart';

part 'group_settings_providers.g.dart';

@riverpod
Future<Map<String, dynamic>?> hostProfile(HostProfileRef ref, String hostId) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final response = await client
        .from('profiles')
        .select('display_name, phone')
        .eq('id', hostId)
        .single();
    return response;
  } catch (e) {
    return null;
  }
}

@riverpod
Future<int> matchesPlayed(MatchesPlayedRef ref, String groupId) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return 0;
  try {
    final response = await client
        .from('rsvps')
        .select('id, games!inner(group_id)')
        .eq('user_id', userId)
        .eq('games.group_id', groupId)
        .inFilter('status', ['yes', 'guest']);
    return (response as List).length;
  } catch (e) {
    return 0;
  }
}
