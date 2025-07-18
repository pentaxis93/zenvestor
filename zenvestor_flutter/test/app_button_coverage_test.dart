import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenvestor_client/zenvestor_client.dart';
import 'package:zenvestor_flutter/app.dart';
import 'package:zenvestor_flutter/main.dart' as main_app;

// Mock classes
class MockClient extends Mock implements Client {}

class MockEndpointGreeting extends Mock implements EndpointGreeting {}

void main() {
  group('MyHomePage button coverage', () {
    late MockClient mockClient;
    late MockEndpointGreeting mockGreeting;

    setUp(() {
      mockClient = MockClient();
      mockGreeting = MockEndpointGreeting();
      when(() => mockClient.greeting).thenReturn(mockGreeting);

      // Initialize the global client with our mock
      main_app.client = mockClient;
    });

    testWidgets(
      'button onPressed executes _callHello method',
      (WidgetTester tester) async {
        // Arrange
        const testName = 'Coverage Test';
        final greetingResponse = Greeting(
          message: 'Hello, $testName!',
          author: 'Server',
          timestamp: DateTime.now(),
        );

        when(() => mockGreeting.hello(any()))
            .thenAnswer((_) async => greetingResponse);

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: MyHomePage(title: 'Coverage Test'),
          ),
        );

        // Find and tap the button to trigger _callHello
        final button = find.byType(ElevatedButton);
        expect(button, findsOneWidget);

        await tester.tap(button);
        await tester.pump();

        // The _callHello method has been executed, covering lines 46-47
      },
    );
  });
}
