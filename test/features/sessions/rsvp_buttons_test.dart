import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameior/features/sessions/widgets/rsvp_buttons.dart';
import 'package:gameior/shared/models/enums.dart';

void main() {
  group('RsvpButtons Widget Test', () {
    testWidgets('renders all four buttons with correct labels when unlocked and not loading', (WidgetTester tester) async {
      RsvpStatus? selectedStatus;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RsvpButtons(
              currentStatus: RsvpStatus.unanswered,
              onChanged: (status) => selectedStatus = status,
            ),
          ),
        ),
      );

      // Verify that YES, NO, MAYBE, GUEST buttons exist
      expect(find.text('YES'), findsOneWidget);
      expect(find.text('NO'), findsOneWidget);
      expect(find.text('MAYBE'), findsOneWidget);
      expect(find.text('GUEST'), findsOneWidget);

      // Tap YES and verify selectedStatus
      await tester.tap(find.text('YES'));
      await tester.pump();
      expect(selectedStatus, RsvpStatus.yes);

      // Tap NO and verify selectedStatus
      await tester.tap(find.text('NO'));
      await tester.pump();
      expect(selectedStatus, RsvpStatus.no);
    });

    testWidgets('shows loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RsvpButtons(
              currentStatus: RsvpStatus.unanswered,
              isLoading: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('YES'), findsNothing);
    });

    testWidgets('shows locked banner when isLocked is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RsvpButtons(
              currentStatus: RsvpStatus.yes,
              isLocked: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('YES'), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('RSVP is locked: YES'), findsOneWidget);
    });
  });
}
