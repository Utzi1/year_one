import 'package:flutter/material.dart';
import 'assessments_from_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assessment App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AssessmentPage(),
    );
  }
}

class AssessmentPage extends StatelessWidget {
  const AssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Page'),
      ),
      body: const AssessmentsFromText(
        filePath: 'assets/sample_assessment.txt',
      ),
    );
  }
}
