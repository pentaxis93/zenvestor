import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:zenvestor_client/zenvestor_client.dart';

/// Configuration helper for creating and initializing the Serverpod client.
class ClientConfig {
  /// Gets the server URL from environment variables or returns default.
  static String getServerUrl() {
    const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
    return serverUrlFromEnv.isEmpty
        ? 'http://localhost:8080/'
        : serverUrlFromEnv;
  }

  /// Creates a new client instance with the given server URL.
  static Client createClient(String serverUrl) {
    return Client(serverUrl)
      ..connectivityMonitor = FlutterConnectivityMonitor();
  }
}
