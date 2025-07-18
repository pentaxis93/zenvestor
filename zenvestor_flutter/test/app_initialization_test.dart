import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:zenvestor_client/zenvestor_client.dart';

void main() {
  group('App initialization tests', () {
    test('client can be created with server URL', () {
      // Test the client creation logic similar to main()
      const serverUrlFromEnv = '';
      final serverUrl = serverUrlFromEnv.isEmpty
          ? 'http://localhost:8080/'
          : serverUrlFromEnv;

      expect(serverUrl, 'http://localhost:8080/');

      // Create a client similar to how main() does it
      final testClient = Client(serverUrl)
        ..connectivityMonitor = FlutterConnectivityMonitor();

      expect(testClient, isA<Client>());
      expect(testClient.connectivityMonitor, isA<FlutterConnectivityMonitor>());
    });

    test('client creation with custom server URL', () {
      // Simulate having a custom SERVER_URL
      const customUrl = 'https://api.example.com/';
      final serverUrl =
          customUrl.isEmpty ? 'http://localhost:8080/' : customUrl;

      expect(serverUrl, 'https://api.example.com/');

      // Create client with custom URL
      final testClient = Client(serverUrl);
      expect(testClient, isA<Client>());
    });
  });
}
