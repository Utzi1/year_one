import 'package:flutter/material.dart';

/**
 * A widget that allows users to input responses to a query in various formats.
 * 
 * The `QueryInput` widget supports four types of input:
 * - `text`: A text field for freeform text input.
 * - `dropdown`: A dropdown menu for selecting one option from a list.
 * - `multiple_choice`: A set of radio buttons for selecting one option from a list.
 * - `checkbox`: A set of checkboxes for selecting multiple options from a list.
 * 
 * The widget displays the query text and the appropriate input field based on the `type`
 * provided.
 * 
 * The `query` parameter specifies the question or prompt to display.
 * The `type` parameter specifies the type of input field to display (`text`, `dropdown`, `multiple_choice`, or `checkbox`).
 * The `options` parameter is an optional nullable list of strings used for `dropdown`, `multiple_choice`, and `checkbox` types.
 * 
 * Example usage:
 * 
 * ```dart
 * QueryInput(
 *   query: 'What is your favorite color?',
 *   type: 'dropdown',
 *   options: ['Red', 'Green', 'Blue'],
 * )
 * ```
 */
class QueryInput extends StatefulWidget {
  final String query;
  final String type;
  final List<String>? options;

  const QueryInput({
    Key? key,
    required this.query,
    required this.type,
    this.options,
  }) : super(key: key);

  @override
  _QueryInputState createState() => _QueryInputState();
}

class _QueryInputState extends State<QueryInput> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedOption;
  final Map<String, bool> _selectedCheckboxes = {};

  @override
  void initState() {
    super.initState();
    if (widget.type == 'checkbox' && widget.options != null) {
      for (var option in widget.options!) {
        _selectedCheckboxes[option] = false;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.query),
        const Padding(padding: EdgeInsets.only(top: 8)),
        if (widget.type == 'text')
          TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          )
        else if (widget.type == 'dropdown' && widget.options != null)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            value: _selectedOption,
            items: widget.options!.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedOption = newValue;
              });
            },
          )
        else if (widget.type == 'multiple_choice' && widget.options != null)
          Column(
            children: widget.options!.map((String value) {
              return RadioListTile<String>(
                title: Text(value),
                value: value,
                groupValue: _selectedOption,
                onChanged: (newValue) {
                  setState(() {
                    _selectedOption = newValue;
                  });
                },
              );
            }).toList(),
          )
        else if (widget.type == 'checkbox' && widget.options != null)
          Column(
            children: widget.options!.map((String value) {
              return CheckboxListTile(
                title: Text(value),
                value: _selectedCheckboxes[value],
                onChanged: (newValue) {
                  setState(() {
                    _selectedCheckboxes[value] = newValue!;
                  });
                },
              );
            }).toList(),
          ),
      ],
    );
  }
}
