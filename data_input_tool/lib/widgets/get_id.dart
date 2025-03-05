import 'package:flutter/material.dart';

/// A widget that provides an input field for entering an identifier and a submit button.
///
/// This widget consists of a text field for entering an identifier and an icon button
/// to submit the entered identifier. When the button is pressed, the `onSubmit` callback
/// is triggered with the entered identifier.
///
/// Parameters:
/// - `controller`: A [TextEditingController] to control the text being edited.
/// - `onSubmit`: A callback function that is called when the submit button is pressed.
class IdentifierInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmit;

  const IdentifierInput({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Identifier',
              hintText: 'Enter identifier',
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => onSubmit(controller.text),
        ),
      ],
    );
  }
}
