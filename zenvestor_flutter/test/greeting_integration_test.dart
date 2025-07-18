import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenvestor_client/zenvestor_client.dart';
import 'package:zenvestor_flutter/app.dart';

// Mock classes
class MockClient extends Mock implements Client {}

class MockEndpointGreeting extends Mock implements EndpointGreeting {}

class MockGreeting extends Mock implements Greeting {}

// Custom MyHomePage that accepts a client
class TestableMyHomePage extends StatefulWidget {
  const TestableMyHomePage({
    required this.title,
    required this.testClient,
    super.key,
  });

  final String title;
  final Client testClient;

  @override
  TestableMyHomePageState createState() => TestableMyHomePageState();
}

class TestableMyHomePageState extends State<TestableMyHomePage> {
  String? _resultMessage;
  String? _errorMessage;
  final _textEditingController = TextEditingController();

  Future<void> _callHello() async {
    try {
      final result =
          await widget.testClient.greeting.hello(_textEditingController.text);
      setState(() {
        _errorMessage = null;
        _resultMessage = result.message;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(hintText: 'Enter your name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: _callHello,
                child: const Text('Send to Server'),
              ),
            ),
            ResultDisplay(
              resultMessage: _resultMessage,
              errorMessage: _errorMessage,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

void main() {
  group('Greeting integration tests', () {
    late MockClient mockClient;
    late MockEndpointGreeting mockGreeting;

    setUp(() {
      mockClient = MockClient();
      mockGreeting = MockEndpointGreeting();
      when(() => mockClient.greeting).thenReturn(mockGreeting);
    });

    testWidgets('successfully calls greeting endpoint and displays result',
        (WidgetTester tester) async {
      // Arrange
      const testName = 'Alice';
      const expectedMessage = 'Hello Alice';
      final mockGreetingResponse = MockGreeting();
      when(() => mockGreetingResponse.message).thenReturn(expectedMessage);

      when(() => mockGreeting.hello(testName))
          .thenAnswer((_) async => mockGreetingResponse);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestableMyHomePage(
            title: 'Test',
            testClient: mockClient,
          ),
        ),
      );

      // Enter name and tap button
      await tester.enterText(find.byType(TextField), testName);
      await tester.tap(find.text('Send to Server'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(expectedMessage), findsOneWidget);
      expect(find.textContaining('Exception:'), findsNothing);
      verify(() => mockGreeting.hello(testName)).called(1);
    });

    testWidgets('displays error when endpoint call fails',
        (WidgetTester tester) async {
      // Arrange
      const testName = 'Bob';
      const errorMessage = 'Network error';

      when(() => mockGreeting.hello(testName))
          .thenThrow(Exception(errorMessage));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: TestableMyHomePage(
            title: 'Test',
            testClient: mockClient,
          ),
        ),
      );

      // Enter name and tap button
      await tester.enterText(find.byType(TextField), testName);
      await tester.tap(find.text('Send to Server'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Exception: $errorMessage'), findsOneWidget);
      expect(find.text('No server response yet.'), findsNothing);
      verify(() => mockGreeting.hello(testName)).called(1);
    });

    testWidgets('error message is cleared on successful retry',
        (WidgetTester tester) async {
      // Arrange
      const testName = 'Charlie';
      const errorMessage = 'First attempt failed';
      const successMessage = 'Hello Charlie';

      // First call will fail
      when(() => mockGreeting.hello(testName))
          .thenThrow(Exception(errorMessage));

      // Act - First attempt (failure)
      await tester.pumpWidget(
        MaterialApp(
          home: TestableMyHomePage(
            title: 'Test',
            testClient: mockClient,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), testName);
      await tester.tap(find.text('Send to Server'));
      await tester.pumpAndSettle();

      // Verify error is shown
      expect(find.text('Exception: $errorMessage'), findsOneWidget);

      // Setup for success
      final mockGreetingResponse = MockGreeting();
      when(() => mockGreetingResponse.message).thenReturn(successMessage);
      when(() => mockGreeting.hello(testName))
          .thenAnswer((_) async => mockGreetingResponse);

      // Act - Second attempt (success)
      await tester.tap(find.text('Send to Server'));
      await tester.pumpAndSettle();

      // Assert - Error cleared, success shown
      expect(find.text('Exception: $errorMessage'), findsNothing);
      expect(find.text(successMessage), findsOneWidget);
      verify(() => mockGreeting.hello(testName)).called(2);
    });
  });
}
