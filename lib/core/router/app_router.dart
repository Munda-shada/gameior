import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/features/profile/application/signup_provider.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/auth/presentation/splash_screen.dart';
import 'package:gameior/features/auth/presentation/login_screen.dart';
import 'package:gameior/features/home/presentation/home_shell.dart';
import 'package:gameior/features/feed/presentation/feed_tab.dart';
import 'package:gameior/features/groups/presentation/groups_tab.dart';
import 'package:gameior/features/groups/presentation/create_group_screen.dart';
import 'package:gameior/features/calendar/presentation/calendar_tab.dart';
import 'package:gameior/features/profile/presentation/profile_tab.dart';
import 'package:gameior/features/profile/presentation/edit_profile_screen.dart';
import 'package:gameior/features/profile/presentation/notification_preferences_screen.dart';
import 'package:gameior/features/profile/presentation/delete_account_screen.dart';
import 'package:gameior/features/group_workspace/presentation/group_shell.dart';
import 'package:gameior/features/sessions/presentation/game_detail_screen.dart';
import 'package:gameior/features/sessions/presentation/game_payment_screen.dart';
import 'package:gameior/features/sessions/presentation/complete_game_screen.dart';
import 'package:gameior/features/sessions/presentation/create_game_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(currentUserProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: routerNotifier,
    redirect: (context, state) {
  final authState = ref.read(authStateProvider);
  final profileState = ref.read(currentUserProvider);
  
  final isAuthenticated = authState.valueOrNull?.session != null;
  final isLoading = profileState.isLoading && profileState.valueOrNull == null;
  final isProfileComplete = profileState.valueOrNull?.isProfileComplete ?? false;

  final location = state.matchedLocation;
  final onAuthPages = location == '/login' 
                   || location == '/signup' 
                   || location == '/splash';

  // Still loading profile — don't interrupt the user's flow
  if (isAuthenticated && isLoading) {
    if (onAuthPages) return '/splash';
    return null;
  }

  // Not logged in → go to login
  if (!isAuthenticated && !onAuthPages) return '/login';
  if (!isAuthenticated) return null;

  // Logged in but profile incomplete → go to signup
  if (!isProfileComplete && location != '/signup') return '/signup';

  // Logged in, profile complete, on an auth page → go to app
  if (isProfileComplete && onAuthPages) return '/home/feed';

  return null;
},
    routes: [
  GoRoute(path: '/splash',  builder: (context, state) => const SplashScreen()),
  GoRoute(path: '/login',   builder: (context, state) => const LoginScreen()),
  GoRoute(path: '/signup',  builder: (context, state) => SignupScreen()),

  StatefulShellRoute.indexedStack(   // Persistent bottom nav (home)
    builder: (context, state, shell) => HomeShell(shell: shell),
    branches: [
      StatefulShellBranch(routes: [
        GoRoute(path: '/home/feed', builder: (context, state) => FeedTab()),
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: '/home/groups',
          builder: (context, state) => const GroupsTab(),
          routes: [
            GoRoute(path: 'create', builder: (context, state) => const CreateGroupScreen()),
          ],
        ),
      ]),
      StatefulShellBranch(routes: [
        GoRoute(path: '/home/calendar', builder: (context, state) => const CalendarTab()),
      ]),
      StatefulShellBranch(routes: [
        GoRoute(
          path: '/home/profile',
          builder: (context, state) => const ProfileTab(),
          routes: [
            GoRoute(path: 'edit',           builder: (context, state) => const EditProfileScreen()),
            GoRoute(path: 'notifications',  builder: (context, state) => const NotificationPreferencesScreen()),
            GoRoute(path: 'delete-account', builder: (context, state) => const DeleteAccountScreen()),
          ],
        ),
      ]),
    ],
  ),

  GoRoute(
    path: '/group/:groupId',
    builder: (context, state) {
      final tabStr = state.uri.queryParameters['tab'];
      final initialTab = tabStr != null ? int.tryParse(tabStr) : null;
      final extraTab = (state.extra as Map<String, dynamic>?)?['initialTab'] as int?;
      return GroupShell(
        groupId: state.pathParameters['groupId']!,
        initialTab: initialTab ?? extraTab,
      );
    },
    routes: [
      GoRoute(
        path: 'game/:gameId',
        builder: (ctx, state) => GameDetailScreen(
          groupId: state.pathParameters['groupId']!,
          gameId:  state.pathParameters['gameId']!,
        ),
        routes: [
          GoRoute(
            path: 'payment',
            builder: (ctx, state) => GamePaymentScreen(
              groupId: state.pathParameters['groupId']!,
              gameId:  state.pathParameters['gameId']!,
            ),
          ),
          GoRoute(
            path: 'complete',
            builder: (ctx, state) => CompleteGameScreen(
              groupId: state.pathParameters['groupId']!,
              gameId:  state.pathParameters['gameId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: 'create-game',
        builder: (ctx, state) => CreateGameScreen(
          groupId:    state.pathParameters['groupId']!,
          editGameId: state.uri.queryParameters['edit'],  // null = new game
          isTemplate: state.uri.queryParameters['template'] == 'true',
        ),
      ),
    ],
  ),
],
  );
});