import 'package:flutter/material.dart';
import 'query_class.dart';

class AssessmentsFromText extends StatefulWidget {
  final String filePath;
  const AssessmentsFromText({super.key, required this.filePath});

  @override
  State<AssessmentsFromText> createState() => _AssessmentsFromTextState();
}

class _AssessmentsFromTextState extends State<AssessmentsFromText> {
  final List<Map<String, dynamic>> _queries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQueries();
  }

  Future<void> _loadQueries() async {
    try {
      final data = await DefaultAssetBundle.of(context).loadString(widget.filePath);
      print('File loaded: $data'); // Debug print
      final lines = data.split('\n');
      print('Lines: $lines'); // Debug print
      setState(() {
        _queries.addAll(_parseQueries(lines));
        print('Parsed Queries: $_queries'); // Debug print
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading file: $e'); // Debug print
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _parseQueries(List<String> lines) {
    return lines.map((line) {
      final parts = line.split('|');
      return {
        'query': parts[0],
        'answer': parts.length > 1 ? parts[1] : '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_queries.isEmpty) {
      return const Center(child: Text('No assessments found.'));
    }

    return ListView.builder(
      itemCount: _queries.length,
      itemBuilder: (context, index) {
        final query = _queries[index];
        return ListTile(
          title: Text(query['query']),
          subtitle: Text(query['answer']),
        );
      },
    );
  }
}