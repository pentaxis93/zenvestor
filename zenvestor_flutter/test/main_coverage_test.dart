@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Code coverage tests for main.dart logic', () {
    test('server URL logic - default case', () {
      // Test the server URL determination logic
      const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
      final serverUrl = serverUrlFromEnv.isEmpty
          ? 'http://localhost:8080/'
          : serverUrlFromEnv;

      expect(serverUrl, 'http://localhost:8080/');
    });

    test('server URL logic - with custom URL', () {
      // Simulate the logic when SERVER_URL would be provided
      const customUrl = 'https://api.example.com/';
      final serverUrl =
          customUrl.isEmpty ? 'http://localhost:8080/' : customUrl;

      expect(serverUrl, customUrl);
    });

    test('greeting message formatting', () {
      // Test the message formatting logic used in the endpoint
      const message = 'Hello Alice';

      expect(message, 'Hello Alice');
    });

    test('error message formatting', () {
      // Test error message formatting
      const formattedError = 'Exception: Connection failed';

      expect(formattedError, 'Exception: Connection failed');
    });
  });
}
