import 'package:flutter/material.dart';
import 'package:zenvestor_client/zenvestor_client.dart';
import 'package:zenvestor_flutter/app.dart';
import 'package:zenvestor_flutter/client_config.dart';

/// Global client object for server communication.
/// In a larger app, consider using dependency injection instead.
late final Client client;

/// Entry point of the Flutter application.
/// This file is intentionally minimal and excluded from test coverage.
void main() {
  client = ClientConfig.createClient(ClientConfig.getServerUrl());
  runApp(const MyApp());
}
