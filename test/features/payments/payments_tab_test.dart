import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameior/features/payments/presentation/payments_tab.dart';

void main() {
  group('CustomSegmentedControl Widget Test', () {
    testWidgets('renders segments with correct labels and highlights selection', (WidgetTester tester) async {
      bool firstSelected = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomSegmentedControl(
              label1: 'Segment A',
              label2: 'Segment B',
              isFirstSelected: firstSelected,
              onSelected: (val) {
                firstSelected = val;
              },
            ),
          ),
        ),
      );

      // Verify labels are displayed
      expect(find.text('Segment A'), findsOneWidget);
      expect(find.text('Segment B'), findsOneWidget);

      // Tap second segment
      await tester.tap(find.text('Segment B'));
      await tester.pump();

      // Verify selection changed
      expect(firstSelected, false);
    });
  });
}
