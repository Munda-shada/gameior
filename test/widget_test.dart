import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gameior/app.dart';
import 'package:gameior/core/supabase/supabase_client.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  testWidgets('App-level smoke test', (WidgetTester tester) async {
    final mockClient = MockSupabaseClient();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(mockClient),
          authStateProvider.overrideWith((ref) {
            return const Stream.empty();
          }),
          currentUserProvider.overrideWith((ref) {
            return Future.value(null);
          }),
        ],
        child: const GameiorApp(),
      ),
    );

    // Let the splash screen evaluate and route to login
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the app builds successfully and contains MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
