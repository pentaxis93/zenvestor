import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:zenvestor_client/zenvestor_client.dart';
import 'package:zenvestor_flutter/client_config.dart';

void main() {
  group('ClientConfig tests', () {
    test('getServerUrl returns default localhost URL when no env var', () {
      // Test the default case (env variable is empty in test)
      final serverUrl = ClientConfig.getServerUrl();
      expect(serverUrl, 'http://localhost:8080/');
    });

    test('createClient creates client with connectivity monitor', () {
      // Arrange
      const testUrl = 'http://test-server:8080/';

      // Act
      final client = ClientConfig.createClient(testUrl);

      // Assert
      expect(client, isA<Client>());
      expect(client.connectivityMonitor, isA<FlutterConnectivityMonitor>());
    });

    test('createClient creates different instances for different URLs', () {
      // Arrange
      const url1 = 'http://server1:8080/';
      const url2 = 'http://server2:8080/';

      // Act
      final client1 = ClientConfig.createClient(url1);
      final client2 = ClientConfig.createClient(url2);

      // Assert
      expect(client1, isNot(same(client2)));
      expect(client1, isA<Client>());
      expect(client2, isA<Client>());
    });
  });
}
