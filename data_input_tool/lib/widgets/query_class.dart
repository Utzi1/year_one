import 'package:flutter/material.dart';
import 'lib/widgets/query_class.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Query Input Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              QueryInput(
                query: 'Enter your name:',
                type: 'text',
              ),
              SizedBox(height: 16),
              QueryInput(
                query: 'Select your favorite fruit:',
                type: 'dropdown',
                options: ['Apple', 'Banana', 'Cherry'],
              ),
              SizedBox(height: 16),
              QueryInput(
                query: 'Choose your preferred contact method:',
                type: 'multiple_choice',
                options: ['Email', 'Phone', 'Mail'],
              ),
              SizedBox(height: 16),
              QueryInput(
                query: 'Select your hobbies:',
                type: 'checkbox',
                options: ['Reading', 'Traveling', 'Cooking'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}port 'package:flutter/material.dart';
import 'lib/widgets/query_class.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Query Input Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              QueryInput(
                query: 'Enter your name:',
                type: 'text',
              ),
              SizedBox(height: 16),
              QueryInput(
                query: 'Select your favorite fruit:',
                type: 'dropdown',
                options: ['Apple', 'Banana', 'Cherry'],
              ),
              SizedBox(height: 16),
              QueryInput(
                query: 'Choose your preferred contact method:',
                type: 'multiple_choice',
                options: ['Email', 'Phone', 'Mail'],
              ),
              SizedBox(height: 16),
              QueryInput(
                query: 'Select your hobbies:',
                type: 'checkbox',
                options: ['Reading', 'Traveling', 'Cooking'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
