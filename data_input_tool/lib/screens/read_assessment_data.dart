import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReadAssessmentData extends StatefulWidget {
  const ReadAssessmentData({super.key});

  @override
  _ReadAssessmentDataState createState() => _ReadAssessmentDataState();
}

class _ReadAssessmentDataState extends State<ReadAssessmentData> {
  final TextEditingController _idController = TextEditingController();
  Map<String, dynamic>? _assessmentData;
  String? _error;

  Future<void> _fetchData() async {
    final id = _idController.text.trim();
    if (id.isNotEmpty) {
      final result = await ApiService.getAllData(id);
      setState(() {
        if (result.containsKey('error')) {
          _error = result['error'];
          _assessmentData = null;
        } else {
          _error = null;
          _assessmentData = result;
        }
      });
    } else {
      setState(() {
        _error = 'Please enter a valid ID';
        _assessmentData = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Assessment Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Enter ID',
                hintText: 'Enter ID',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Fetch Data'),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
            if (_assessmentData != null)
              Expanded(
                child: ListView(
                  children: _assessmentData!.entries.map((entry) {
                    return ExpansionTile(
                      title: Text(entry.key),
                      children: entry.value.entries.map<Widget>((subEntry) {
                        return ListTile(
                          title: Text('${subEntry.key}: ${subEntry.value}'),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}