import 'package:serverpod/serverpod.dart';
import 'package:zenvestor_server/src/generated/endpoints.dart';
import 'package:zenvestor_server/src/generated/protocol.dart';

// This is the starting point of your Serverpod server. In most cases, you will
// only need to make additions to this file if you add future calls,  are
// configuring Relic (Serverpod's web-server), or need custom setup work.

/// Runs the Serverpod server with the provided command line arguments.
///
/// This function initializes the server and starts it.
Future<void> run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Start the server.
  await pod.start();
}
