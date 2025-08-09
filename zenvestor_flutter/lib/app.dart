import 'package:flutter/material.dart';

/// The root widget of the application.
class MyApp extends StatelessWidget {
  /// Creates the root application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenvestor',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Zenvestor'),
    );
  }
}

/// The main page of the application.
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: const Center(
        child: Text('Welcome to Zenvestor'),
      ),
    );
  }
}
