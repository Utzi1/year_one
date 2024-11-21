// Use the material theme to create a simple Flutter web app that fetches a value from a REST API.
import 'package:flutter/material.dart';
// To enable the use of HTTP client in the app, import the http package.
import 'package:http/http.dart' as http;
// As our API returns a JSON response, we need to import the dart:convert package to parse that
import 'dart:convert';

// The main function is the entry point of the Flutter app.
void main() {
  runApp(MyApp());
}

// The MyApp class is a StatelessWidget that creates a MaterialApp widget.
// The MaterialApp widget is the root of the Flutter app and contains the title, theme, and home page.
class MyApp extends StatelessWidget {
// The MyApp class has a const constructor that takes a key parameter.
// The key parameter is used to identify the widget in the widget tree.
  const MyApp({super.key});

// The build method returns a MaterialApp widget.
// use override to provide a more specific implementation of a method in a superclass.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}


/// A stateful widget that represents the home page of the Flutter web app.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/// The state class for the MyHomePage widget.
class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _value = '';

  /// Fetches the value associated with the given key from the REST API.
  ///
  /// Makes a GET request to the endpoint 'http://localhost:3000/get/{key}'.
  /// If the request is successful, updates the [_value] with the response body.
  /// Otherwise, updates the [_value] with an error message.
  Future<void> _getValue(String key) async {
    final response = await http.get(Uri.parse('http://localhost:3000/get/$key'));
    if (response.statusCode == 200) {
      setState(() {
        _value = response.body;
      });
    } else {
      setState(() {
        _value = 'Error: ${response.reasonPhrase}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Web App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter key',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _getValue(_controller.text),
              child: const Text('Get Value'),
            ),
            const SizedBox(height: 20),
            Text(
              'Value: $_value',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
