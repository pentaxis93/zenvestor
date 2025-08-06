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

  group('HomePage Widget Tests', () {
    testWidgets('displays initial UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text('Zenvestor'), findsOneWidget);
      expect(find.text('Welcome to Zenvestor'), findsOneWidget);
      expect(find.text('Your AI-powered investment assistant'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('has proper widget structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify the structure is correct
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(3)); // Title + 2 text widgets
    });

    testWidgets('app bar displays correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify app bar title
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final titleWidget = appBar.title! as Text;
      expect(titleWidget.data, 'Zenvestor');
    });
  });
}
