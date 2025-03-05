import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// A base abstract widget class for all assessment-related screens in the application.
/// Provides common functionality and structure for different types of medical assessments.
///
/// The [BaseAssessment] class serves as a foundation for creating assessment screens,
/// requiring a [patientId] and [assessmentData] for initialization.
///
/// The [BaseAssessmentState] class provides:
/// * Common UI components and layouts
/// * Error handling functionality
/// * Assessment data management
/// * Standard styling and formatting
///
/// Key features:
/// * Abstract methods that must be implemented by child classes:
///   - [assessmentName]: Gets the name of the assessment
///   - [saveAssessment]: Handles saving assessment data
///   - [loadAssessment]: Retrieves assessment data
///   - [buildAssessmentContent]: Builds the main content of the assessment
///
/// Helper methods include:
/// * [showError]: Displays error messages in a snackbar
/// * [buildContainer]: Creates a standardized container with consistent styling
/// * [buildSectionTitle]: Renders section headers
/// * [buildInfoText]: Displays informational text in a styled container
/// * [buildButtonSection]: Creates a section with buttons and related information
/// * [buildActionButtonField]: Builds a set of choice chips for selection
/// * [buildLastAssessment]: Shows the previous assessment data
///
/// Usage:
/// ```dart
/// class MyAssessment extends BaseAssessment {
///   // Implementation
/// }
/// ```
///
/// Note: This class requires proper implementation of all abstract methods
/// in the child classes to function correctly.

abstract class BaseAssessment extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> assessmentData;

  const BaseAssessment({
    required this.patientId,
    required this.assessmentData,
    super.key,
  });
}

abstract class BaseAssessmentState<T extends BaseAssessment> extends State<T> {
  bool _isLoading = false;
  Map<String, dynamic> _lastAssessmentData = {};

  // Abstract methods that must be implemented by children
  String get assessmentName;
  Future<void> saveAssessment();
  Future<Map<String, dynamic>> loadAssessment();
  Widget buildAssessmentContent();

  // Helper methods
  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget buildContainer({required Widget child, Color? backgroundColor}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.0),
            color: backgroundColor ?? Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.only(bottom: 16.0),
          child: child,
        );
      },
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget buildInfoText(String text) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey.shade50,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF616161),
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      },
    );
  }

  /// Builds a section with title, buttons, and info text
  /// Uses orange background for unanswered required questions
  /// Uses green background for answered questions
  Widget buildButtonSection(
    String title,
    List<Widget> buttons,
    String infoText, {
    bool isAnswered = false,
  }) {
    return buildContainer(
      backgroundColor: isAnswered ? Colors.green.shade50 : Colors.orange.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isAnswered ? Colors.green.shade900 : Colors.orange.shade900,
            ),
          ),
          buildInfoText(infoText),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: buttons,
          ),
        ],
      ),
    );
  }

  /// Builds a field of action buttons (choice chips)
  /// Shows orange warning when unanswered
  /// Shows green highlighting for selected options
  Widget buildActionButtonField<T>({
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required Map<T, String> itemInfo,
  }) {
    final bool isAnswered = value != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isAnswered)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Bitte auswählen',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ...items.map((item) {
          final isSelected = value == item;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ChoiceChip(
              label: Text(
                itemInfo[item] ?? '',
                style: TextStyle(
                  color: isSelected ? Colors.green.shade900 : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.green.shade100,
              backgroundColor: Colors.grey.shade200,
              onSelected: (selected) => onChanged(selected ? item : null),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Builds a styled checkbox with consistent colors across all assessments
  Widget buildStyledCheckbox({
    required bool? value,
    required ValueChanged<bool?> onChanged,
    Color? activeColor,
    Color? checkColor,
  }) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? Colors.green.shade100,
      checkColor: checkColor ?? Colors.green.shade900,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget buildLastAssessment() {
    if (_lastAssessmentData.isEmpty) return const SizedBox.shrink();

    final timestamp = _lastAssessmentData['timestamp'] ?? 'Unbekannt';
    final assessmentData = Map<String, dynamic>.from(_lastAssessmentData)
      ..removeWhere((key, value) => ['timestamp', 'unix_timestamp', 'key'].contains(key));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vorheriges Assessment:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...assessmentData.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(assessmentName),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          primary: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_lastAssessmentData.isNotEmpty) ...[
                  buildLastAssessment(),
                  const SizedBox(height: 24),
                  const Divider(),
                ],
                buildAssessmentContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
