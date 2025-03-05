import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Input App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.grey[50],
        scaffoldBackgroundColor: Colors.grey[50],
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
        ).copyWith(
          secondary: Colors.grey[800],
        ),
        textTheme: TextTheme(
          displayMedium: TextStyle(  // Changed from headline4
            fontSize: 32.0, 
            fontWeight: FontWeight.w300,
            color: Colors.grey[900],
          ),
          bodyMedium: TextStyle(    // Changed from bodyText2
            fontSize: 16.0, 
            color: Colors.grey[800],
            height: 1.5,
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.grey[200],
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20.0, 
            fontWeight: FontWeight.w500,
            color: Colors.grey[900],
          ),
          iconTheme: IconThemeData(color: Colors.grey[900]),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey[200],
          thickness: 1,
        ),
      ),
      home: LoginScreen(),
    );
  }
}
