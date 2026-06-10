// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// TODO: Uncomment this import once your app widget is ready
// import 'package:gameior/main.dart'; 

void main() {
  testWidgets('App-level smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(), // <-- Replace with your actual root widget name
      ),
    );

    // Verify that the app builds successfully.
    expect(find.byType(MaterialApp), findsOneWidget); // <-- Replace here too
  });
}
