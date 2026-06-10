import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gameior/features/profile/domain/profile.dart';
import 'package:gameior/features/profile/data/profile_repository.dart';

Future<void> initSupabase() async {
  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (url.isEmpty || anonKey.isEmpty) {
    print("⚠️ WARNING: SUPABASE_URL or SUPABASE_ANON_KEY is empty!");
    print("Make sure you run the app using: flutter run --dart-define-from-file=.env");
  }

  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
    authOptions: FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    )
  );
}

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Auth state stream — drives router redirects
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

final currentUserProvider = FutureProvider<Profile?>((ref) async {
  final authState = ref.watch(authStateProvider).valueOrNull;
  final user = authState?.session?.user;
  if (user == null) return null;
  return ref.watch(profileRepositoryProvider).fetchProfile(user.id);
});