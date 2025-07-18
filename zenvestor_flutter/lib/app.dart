import 'package:flutter/material.dart';
import 'package:zenvestor_client/zenvestor_client.dart';
import 'package:zenvestor_flutter/main.dart' show client;

/// The root widget of the application.
class MyApp extends StatelessWidget {
  /// Creates the root application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serverpod Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Serverpod Example'),
    );
  }
}

/// The main page of the application that displays a greeting form.
class MyHomePage extends StatefulWidget {
  /// Creates the home page with the specified [title].
  const MyHomePage({required this.title, super.key});

  /// The title to display in the app bar.
  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

/// The state for [MyHomePage] widget.
class MyHomePageState extends State<MyHomePage> {
  /// Holds the last result or null if no result exists yet.
  String? _resultMessage;

  /// Holds the last error message that we've received from the server or null
  /// if no error exists yet.
  String? _errorMessage;

  final _textEditingController = TextEditingController();

  /// Calls the `hello` method of the `greeting` endpoint. Will set either the
  /// `_resultMessage` or `_errorMessage` field, depending on if the call
  /// is successful.
  Future<void> _callHello() async {
    await callHelloWithClient(client);
  }

  /// Internal method that accepts a client parameter for testing.
  @visibleForTesting
  Future<void> callHelloWithClient(Client testClient) async {
    try {
      final result =
          await testClient.greeting.hello(_textEditingController.text);
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
}

/// ResultDisplays shows the result of the call. Either the returned result
/// from the `example.greeting` endpoint method or an error message.
class ResultDisplay extends StatelessWidget {
  /// Creates a result display widget.
  const ResultDisplay({super.key, this.resultMessage, this.errorMessage});

  /// The successful result message to display.
  final String? resultMessage;

  /// The error message to display.
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    String text;
    Color backgroundColor;
    if (errorMessage != null) {
      backgroundColor = Colors.red[300]!;
      text = errorMessage!;
    } else if (resultMessage != null) {
      backgroundColor = Colors.green[300]!;
      text = resultMessage!;
    } else {
      backgroundColor = Colors.grey[300]!;
      text = 'No server response yet.';
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: ColoredBox(
        color: backgroundColor,
        child: Center(child: Text(text)),
      ),
    );
  }
}
