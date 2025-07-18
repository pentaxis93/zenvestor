import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenvestor_client/zenvestor_client.dart';
import 'package:zenvestor_flutter/app.dart';

// Mock classes
class MockClient extends Mock implements Client {}

class MockEndpointGreeting extends Mock implements EndpointGreeting {}

// Test widget that exposes the internal method
class TestableMyHomePage extends MyHomePage {
  const TestableMyHomePage({required super.title, super.key});

  @override
  TestableMyHomePageState createState() => TestableMyHomePageState();
}

class TestableMyHomePageState extends MyHomePageState {
  // Expose the internal method for testing
  Future<void> testCallHelloWithClient(Client testClient) async {
    await callHelloWithClient(testClient);
  }
}

void main() {
  group('MyHomePage _callHello coverage tests', () {
    late MockClient mockClient;
    late MockEndpointGreeting mockGreeting;

    setUp(() {
      mockClient = MockClient();
      mockGreeting = MockEndpointGreeting();
      when(() => mockClient.greeting).thenReturn(mockGreeting);
    });

    testWidgets(
      'handles successful greeting response',
      (WidgetTester tester) async {
        // Arrange
        const testName = 'Coverage Test';
        final greetingResponse = Greeting(
          message: 'Hello, $testName!',
          author: 'Server',
          timestamp: DateTime.now(),
        );

        when(() => mockGreeting.hello(testName))
            .thenAnswer((_) async => greetingResponse);

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: TestableMyHomePage(title: 'Test Page'),
          ),
        );

        // Get the state
        final state = tester.state<TestableMyHomePageState>(
          find.byType(TestableMyHomePage),
        );

        // Enter text
        await tester.enterText(find.byType(TextField), testName);

        // Call the method directly with mock client
        await state.testCallHelloWithClient(mockClient);
        await tester.pump();

        // Assert
        verify(() => mockGreeting.hello(testName)).called(1);
        expect(find.text('Hello, $testName!'), findsOneWidget);
      },
    );

    testWidgets(
      'handles exception and sets error message',
      (WidgetTester tester) async {
        // Arrange
        const testName = 'Error Test';
        const errorMessage = 'Server unavailable';

        when(() => mockGreeting.hello(testName))
            .thenThrow(Exception(errorMessage));

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: TestableMyHomePage(title: 'Test Page'),
          ),
        );

        // Get the state
        final state = tester.state<TestableMyHomePageState>(
          find.byType(TestableMyHomePage),
        );

        // Enter text
        await tester.enterText(find.byType(TextField), testName);

        // Call the method directly with mock client
        await state.testCallHelloWithClient(mockClient);
        await tester.pump();

        // Assert
        verify(() => mockGreeting.hello(testName)).called(1);
        expect(find.text('Exception: $errorMessage'), findsOneWidget);
      },
    );

    testWidgets(
      'clears error when subsequent call succeeds',
      (WidgetTester tester) async {
        // Arrange
        const errorText = 'Fail';
        const successText = 'Success';
        const errorMessage = 'Temporary error';

        final greetingResponse = Greeting(
          message: 'Hello, $successText!',
          author: 'Server',
          timestamp: DateTime.now(),
        );

        when(() => mockGreeting.hello(errorText))
            .thenThrow(Exception(errorMessage));
        when(() => mockGreeting.hello(successText))
            .thenAnswer((_) async => greetingResponse);

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: TestableMyHomePage(title: 'Test Page'),
          ),
        );

        final state = tester.state<TestableMyHomePageState>(
          find.byType(TestableMyHomePage),
        );

        // First call - error
        await tester.enterText(find.byType(TextField), errorText);
        await state.testCallHelloWithClient(mockClient);
        await tester.pump();

        // Verify error
        expect(find.text('Exception: $errorMessage'), findsOneWidget);

        // Second call - success
        await tester.enterText(find.byType(TextField), successText);
        await state.testCallHelloWithClient(mockClient);
        await tester.pump();

        // Assert error cleared
        expect(find.text('Exception: $errorMessage'), findsNothing);
        expect(find.text('Hello, $successText!'), findsOneWidget);
      },
    );
  });
}
