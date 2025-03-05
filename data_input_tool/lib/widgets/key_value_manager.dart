/// A stateful widget that manages key-value pairs for patient information.
/// 
/// The `KeyValueManager` widget allows users to input patient information,
/// add new key-value data, and search for existing data by identifier.
/// 
/// This widget uses a text controller:
/// - `_identifierController`: for the patient identifier input.
/// 
/// The widget interacts with an API service to post and retrieve data.
/// 
/// Methods:
/// - `_postData`: Sends the key-value data to the API.
/// - `_loadData`: Retrieves the key-value data from the API using an identifier.
/// 
/// The widget displays the response from the API and any retrieved key-value pairs.
// lib/widgets/key_value_manager.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'key_value_form.dart';

class KeyValueManager extends StatefulWidget {
  const KeyValueManager({super.key});

  @override 
  State<KeyValueManager> createState() => _KeyValueManagerState();
}

class _KeyValueManagerState extends State<KeyValueManager> {
  final TextEditingController _identifierController = TextEditingController();
  String _response = '';
  Map<String, String> _hashmap = {};

  Future<void> _postData(Map<String, String> data) async {
    final id = _identifierController.text.trim();
    if (id.isNotEmpty) {
      print('Posting data for ID: $id'); // Debug information
      print('Data: $data'); // Debug information

      final result = await ApiService.postHashMap(id, 'Patient Data', data);
      print('Server response: $result'); // Debug information

      setState(() {
        _response = result['message'] ?? 'Failed to post data';
      });
    } else {
      setState(() {
        _response = 'Please enter a valid patient ID';
      });
    }
  }

  Future<void> _loadData() async {
    final id = _identifierController.text.trim();
    if (id.isNotEmpty) {
      final result = await ApiService.getHashMap(id);
      setState(() {
        if (result.containsKey('error')) {
          _response = 'Failed to load data: ${result['error']}';
          _hashmap = {};
        } else {
          _response = 'Data loaded successfully';
          _hashmap = Map<String, String>.from(result['body']);
        }
      });
    } else {
      setState(() {
        _response = 'Please enter a valid patient ID';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _identifierController,
            decoration: InputDecoration(labelText: 'Patient ID'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadData,
            child: Text('Load Data'),
          ),
          SizedBox(height: 20),
          KeyValueForm(onSubmit: _postData),
          SizedBox(height: 20),
          Text(_response),
          SizedBox(height: 20),
          if (_hashmap.isNotEmpty)
            ..._hashmap.entries.map((entry) => Text('${entry.key}: ${entry.value}')).toList(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }
}