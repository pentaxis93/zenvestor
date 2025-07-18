import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenvestor_flutter/app.dart';

void main() {
  group('ResultDisplay Widget Tests', () {
    testWidgets(
      'displays no server response message when both messages are null',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ResultDisplay(),
            ),
          ),
        );

        // Assert
        expect(find.text('No server response yet.'), findsOneWidget);

        // Verify the background color is grey
        final coloredBox = tester.widget<ColoredBox>(
          find.byType(ColoredBox),
        );
        expect(coloredBox.color, Colors.grey[300]);
      },
    );

    testWidgets(
      'displays success message with green background',
      (WidgetTester tester) async {
        // Arrange
        const successMessage = 'Hello, John!';

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ResultDisplay(
                resultMessage: successMessage,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text(successMessage), findsOneWidget);

        // Verify the background color is green
        final coloredBox = tester.widget<ColoredBox>(
          find.byType(ColoredBox),
        );
        expect(coloredBox.color, Colors.green[300]);
      },
    );

    testWidgets(
      'displays error message with red background',
      (WidgetTester tester) async {
        // Arrange
        const errorMessage = 'Connection failed';

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ResultDisplay(
                errorMessage: errorMessage,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text(errorMessage), findsOneWidget);

        // Verify the background color is red
        final coloredBox = tester.widget<ColoredBox>(
          find.byType(ColoredBox),
        );
        expect(coloredBox.color, Colors.red[300]);
      },
    );

    testWidgets(
      'error message takes precedence over result message',
      (WidgetTester tester) async {
        // Arrange
        const successMessage = 'Hello, John!';
        const errorMessage = 'Connection failed';

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ResultDisplay(
                resultMessage: successMessage,
                errorMessage: errorMessage,
              ),
            ),
          ),
        );

        // Assert
        // Should display error message, not success message
        expect(find.text(errorMessage), findsOneWidget);
        expect(find.text(successMessage), findsNothing);

        // Verify the background color is red (error color)
        final coloredBox = tester.widget<ColoredBox>(
          find.byType(ColoredBox),
        );
        expect(coloredBox.color, Colors.red[300]);
      },
    );

    testWidgets(
      'widget has minimum height constraint',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ResultDisplay(),
            ),
          ),
        );

        // Assert
        final constrainedBox = tester.widget<ConstrainedBox>(
          find.descendant(
            of: find.byType(ResultDisplay),
            matching: find.byType(ConstrainedBox),
          ),
        );
        expect(constrainedBox.constraints.minHeight, 50);
      },
    );
  });

  group('MyApp Widget Tests', () {
    testWidgets(
      'creates MaterialApp with correct title',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(const MyApp());

        // Assert
        final materialApp = tester.widget<MaterialApp>(
          find.byType(MaterialApp),
        );
        expect(materialApp.title, 'Serverpod Demo');
      },
    );

    testWidgets(
      'displays MyHomePage as home widget',
      (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(const MyApp());

        // Assert
        expect(find.byType(MyHomePage), findsOneWidget);
        expect(find.text('Serverpod Example'), findsOneWidget);
      },
    );
  });
}
