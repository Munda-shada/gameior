import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  Future<void> signInWithGoogle() async {
  try {
    print("🚀 START GOOGLE LOGIN");

    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.gameior://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );

    print("✅ GOOGLE LOGIN CALLED SUCCESSFULLY");
  } catch (e, st) {
    print("❌ GOOGLE LOGIN ERROR: $e");
    print("STACK: $st");
    rethrow;
  }
}

  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.gameior://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
    
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});
