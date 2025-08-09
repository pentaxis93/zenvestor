import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvestor_flutter/app.dart';

void main() {
  group('MyApp tests', () {
    testWidgets('MyApp builds correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Zenvestor'), findsOneWidget);
    });
  });

  group('MyHomePage tests', () {
    testWidgets('MyHomePage displays welcome message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyHomePage(title: 'Zenvestor'),
        ),
      );

      expect(find.text('Zenvestor'), findsOneWidget);
      expect(find.text('Welcome to Zenvestor'), findsOneWidget);
    });

    testWidgets('MyHomePage has correct structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyHomePage(title: 'Test Title'),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Test Title'), findsOneWidget);
    });
  });
}
