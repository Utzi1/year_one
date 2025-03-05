/// A form widget that allows users to input multiple key-value pairs dynamically.
///
/// This widget provides a dynamic form where users can:
/// * Add new key-value pair input fields
/// * Input keys and values in text fields
/// * Submit the collected key-value pairs
///
/// The widget manages TextEditingControllers for both keys and values,
/// and provides a callback function when the form is submitted.
///
/// Example usage:
/// ```dart
/// KeyValueForm(
///   onSubmit: (Map<String, String> data) {
///     // Handle the submitted key-value pairs
///     print(data);
///   },
/// )
/// ```
///
/// The form automatically cleans up resources by disposing of TextEditingControllers
/// when the widget is removed from the widget tree.
import 'package:flutter/material.dart';

class KeyValueForm extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;

  const KeyValueForm({required this.onSubmit});

  @override
  _KeyValueFormState createState() => _KeyValueFormState();
}

class _KeyValueFormState extends State<KeyValueForm> {
  final List<TextEditingController> _keyControllers = [];
  final List<TextEditingController> _valueControllers = [];

  void _addKeyValuePair() {
    setState(() {
      _keyControllers.add(TextEditingController());
      _valueControllers.add(TextEditingController());
    });
  }

  void _submit() {
    final Map<String, String> data = {};
    for (int i = 0; i < _keyControllers.length; i++) {
      final key = _keyControllers[i].text.trim();
      final value = _valueControllers[i].text.trim();
      if (key.isNotEmpty && value.isNotEmpty) {
        data[key] = value;
      }
    }
    widget.onSubmit(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _keyControllers.length; i++)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _keyControllers[i],
                  decoration: const InputDecoration(labelText: 'Key'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _valueControllers[i],
                  decoration: const InputDecoration(labelText: 'Value'),
                ),
              ),
            ],
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _addKeyValuePair,
          child: const Text('Add Key-Value Pair'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in _keyControllers) {
      controller.dispose();
    }
    for (var controller in _valueControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

