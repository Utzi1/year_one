import 'package:flutter/material.dart';
import 'screens/home_page.dart';

/// The main application widget.
/// This sets the title of the application and the theme.
/// The home page is set to [MyHomePage].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Input App',
      home: MyHomePage()
    );
  }
}
