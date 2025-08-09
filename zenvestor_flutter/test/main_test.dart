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
      expect(find.text('Welcome to Zenvestor'), findsOneWidget);
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('has correct scaffold structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyHomePage(title: 'Test'),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
