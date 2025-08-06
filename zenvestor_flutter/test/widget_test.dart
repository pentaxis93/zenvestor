import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvestor_flutter/app.dart';

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('displays welcome message', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MyApp());

      // Assert
      expect(find.text('Welcome to Zenvestor'), findsOneWidget);
      expect(find.text('Your AI-powered investment assistant'), findsOneWidget);
    });

    testWidgets('displays app title in app bar', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MyApp());

      // Assert
      expect(find.text('Zenvestor'), findsOneWidget);
    });

    testWidgets('displays trending up icon', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MyApp());

      // Assert
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('has correct theme color', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const MyApp());

      // Assert
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.colorScheme.primary, isNotNull);
    });
  });
}
