import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smoking_tracker_app/smoking_tracker.dart';

// Helper function to wrap the widget for testing
Widget createTestableWidget({required Widget child}) {
  return MaterialApp(
    home: child,
  );
}

void main() {
  const String countKey = 'daily_smoke_count';

  group('SmokingTracker Widget Tests', () {
    testWidgets('Initial state - loads count from SharedPreferences (default 0)', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({}); // No data saved

      await tester.pumpWidget(createTestableWidget(child: const SmokingTracker()));
      await tester.pumpAndSettle(); // Wait for async operations like SharedPreferences

      expect(find.text('Current count: 0'), findsOneWidget);
      expect(find.widgetWithText(TextField, '0'), findsOneWidget);
    });

    testWidgets('Initial state - loads count from SharedPreferences (existing value)', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({countKey: 5});

      await tester.pumpWidget(createTestableWidget(child: const SmokingTracker()));
      await tester.pumpAndSettle();

      expect(find.text('Current count: 5'), findsOneWidget);
      expect(find.widgetWithText(TextField, '5'), findsOneWidget);
    });

    testWidgets('Increment button increases count and saves', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({countKey: 2});
      final Map<String, Object> mockValues = {countKey: 2};
      SharedPreferences.setMockInitialValues(mockValues);


      await tester.pumpWidget(createTestableWidget(child: const SmokingTracker()));
      await tester.pumpAndSettle();

      expect(find.text('Current count: 2'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle(); // Allow time for setState and SharedPreferences

      expect(find.text('Current count: 3'), findsOneWidget);
      expect(find.widgetWithText(TextField, '3'), findsOneWidget);
      
      // Verify save (indirectly, by checking if SharedPreferences was updated)
      // Note: Direct mocking of SharedPreferences.setInt is complex in widget tests.
      // We rely on setMockInitialValues and re-checking or testing the load part.
      // For more direct verification, unit tests for the state logic would be better.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(countKey), 3);
    });

    testWidgets('Decrement button decreases count and saves', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({countKey: 3});

      await tester.pumpWidget(createTestableWidget(child: const SmokingTracker()));
      await tester.pumpAndSettle();

      expect(find.text('Current count: 3'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.text('Current count: 2'), findsOneWidget);
      expect(find.widgetWithText(TextField, '2'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(countKey), 2);
    });

    testWidgets('Decrement button does not go below 0', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({countKey: 0});

      await tester.pumpWidget(createTestableWidget(child: const SmokingTracker()));
      await tester.pumpAndSettle();

      expect(find.text('Current count: 0'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.text('Current count: 0'), findsOneWidget); // Still 0
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(countKey), 0); // Should remain 0
    });

    testWidgets('TextField input updates count and saves', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({countKey: 1});

      await tester.pumpWidget(createTestableWidget(child: const SmokingTracker()));
      await tester.pumpAndSettle();

      expect(find.text('Current count: 1'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '7');
      await tester.pumpAndSettle();

      expect(find.text('Current count: 7'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(countKey), 7);
    });
    
    testWidgets('TextField input with invalid text does not change count', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({countKey: 1});

      await tester.pumpWidget(createTestableWidget(child: const SmokingTracker()));
      await tester.pumpAndSettle();

      expect(find.text('Current count: 1'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'abc'); // Invalid input
      await tester.pumpAndSettle();

      // Count should remain unchanged because int.tryParse("abc") is null
      expect(find.text('Current count: 1'), findsOneWidget); 
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(countKey), 1); // Should remain 1
    });

    testWidgets('Save button saves current count manually', (WidgetTester tester) async {
      // Set initial value in TextField different from what might be in prefs
      // to ensure the manual save picks up the TextField/current _count value.
      SharedPreferences.setMockInitialValues({countKey: 0}); // Initial prefs value

      await tester.pumpWidget(createTestableWidget(child: const SmokingTracker()));
      await tester.pumpAndSettle(); // Load initial (0)

      // Manually change count via increment to ensure _count is, say, 1
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle(); // _count is now 1, TextField is "1", prefs is 1 (due to auto-save)
      
      // Now, change text field to something else, e.g., 10, which updates _count
      await tester.enterText(find.byType(TextField), '10');
      await tester.pumpAndSettle(); // _count is 10, TextField is "10", prefs is 10 (due to auto-save)

      expect(find.text('Current count: 10'), findsOneWidget);
      
      // To specifically test the "Save" button's own call to _saveCount,
      // we can ensure the value is what we expect before and after.
      // Let's change the value in the text field again, so _count changes.
      await tester.enterText(find.byType(TextField), '12');
      await tester.pumpAndSettle(); // _count is 12, auto-saved to prefs.
      expect(find.text('Current count: 12'), findsOneWidget);
      
      final prefsBeforeManualSave = await SharedPreferences.getInstance();
      expect(prefsBeforeManualSave.getInt(countKey), 12);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save Count'));
      await tester.pumpAndSettle(); // Wait for SnackBar and potential save

      // Verify SnackBar
      expect(find.text('Count saved: 12'), findsOneWidget);

      final prefsAfterManualSave = await SharedPreferences.getInstance();
      expect(prefsAfterManualSave.getInt(countKey), 12); // Still 12, as it was already up-to-date
    });
  });
}
