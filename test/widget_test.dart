import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker_app/main.dart';

void main() {
  testWidgets('Habit Tracker smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts with a greeting (e.g., "Good Morning" or "Good Afternoon").
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : (hour < 17 ? 'Good Afternoon' : 'Good Evening');
    expect(find.text(greeting), findsOneWidget);

    // Tap the '+' icon to add a habit and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Fill in habit details and save.
    await tester.enterText(find.byType(TextField).at(0), 'New Habit');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify that a habit card appears with the title.
    expect(find.text('New Habit'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
  });
}