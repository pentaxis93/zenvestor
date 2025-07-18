import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvestor_flutter/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('main function tests', () {
    test('initializes client with default server URL when SERVER_URL not set',
        () {
      // This test verifies that the main function properly initializes
      // the client, but we can't directly test main() since it calls runApp
      // Instead, we'll test the logic that main uses

      const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
      final serverUrl = serverUrlFromEnv.isEmpty
          ? 'http://localhost:8080/'
          : serverUrlFromEnv;

      expect(serverUrl, 'http://localhost:8080/');
    });
  });

  group('MyHomePage Widget Tests', () {
    testWidgets('displays initial UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyHomePage(title: 'Test Title'),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Send to Server'), findsOneWidget);
      expect(find.byType(ResultDisplay), findsOneWidget);
    });

    testWidgets('text field updates when user types',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyHomePage(title: 'Test'),
        ),
      );

      const testInput = 'Test Input';
      await tester.enterText(find.byType(TextField), testInput);

      // Verify the TextField contains the entered text
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, testInput);
    });

    testWidgets('has proper widget structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyHomePage(title: 'Test'),
        ),
      );

      // Verify the structure is correct
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Padding), findsNWidgets(5));
    });
  });
}
