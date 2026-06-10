import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/profile/domain/profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

class ProfileRepository {
  ProfileRepository(this._client);
  final SupabaseClient _client;

  Future<Profile?> fetchProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) return null;
    return Profile.fromJson(response);
  }

  Future<void> saveProfile({
    required String userId,
    required String displayName,
    required String phone,
    required String emoji,
  }) async {
    await _client.from('profiles').upsert({
      'id':                  userId,
      'display_name':        displayName,
      'phone':               phone,
      'emoji':               emoji,
      'is_profile_complete': true,
      'updated_at':          DateTime.now().toIso8601String(),
    });
  }
}