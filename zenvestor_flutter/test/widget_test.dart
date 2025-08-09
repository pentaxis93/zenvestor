import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvestor_flutter/app.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('creates MaterialApp with correct configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(materialApp.title, 'Zenvestor');
    });
  });

  group('MyHomePage Widget Tests', () {
    testWidgets('displays title in app bar', (WidgetTester tester) async {
      const testTitle = 'Test Title';
      await tester.pumpWidget(
        const MaterialApp(
          home: MyHomePage(title: testTitle),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('displays welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyHomePage(title: 'Test'),
        ),
      );

      expect(find.text('Welcome to Zenvestor'), findsOneWidget);
    });

    testWidgets('has centered content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyHomePage(title: 'Test'),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });
  });
}
