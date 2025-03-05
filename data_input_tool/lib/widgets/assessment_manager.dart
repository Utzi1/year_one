import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/assessment_page.dart';

/// A widget that manages the display and navigation of assessments.
class AssessmentManager extends StatefulWidget {
  /// The ID used to fetch the assessments.
  final String id;

  /// Creates an instance of [AssessmentManager].
  const AssessmentManager({required this.id, super.key});

  @override
  _AssessmentManagerState createState() => _AssessmentManagerState();
}

class _AssessmentManagerState extends State<AssessmentManager> {
  /// A future that holds the assessments data.
  late Future<Map<String, dynamic>> _assessmentsFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future to load assessments.
    _assessmentsFuture = _loadAssessments();
  }

  /// Loads the assessments from the API.
  ///
  /// This method fetches all data related to the assessments using the provided ID.
  /// If an error occurs during the fetch, an exception is thrown.
  ///
  /// Returns a [Future] that resolves to a [Map] containing the assessments data.
  Future<Map<String, dynamic>> _loadAssessments() async {
    final result = await ApiService.getAllData(widget.id);
    if (result.containsKey('error')) {
      throw Exception(result['error']);
    }
    return result;
  }

  /// Determines the color based on the assessment status.
  ///
  /// Parameters:
  /// - `status`: The status of the assessment.
  ///
  /// Returns a [Color] based on the status.
  Color _getColorBasedOnStatus(String status) {
    switch (status) {
      case 'finished':
        return Colors.green;
      case 'unfinished':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _assessmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No assessments found'));
        } else {
          final assessments = snapshot.data!;
          return ListView.builder(
            itemCount: assessments.length,
            itemBuilder: (context, index) {
              final assessmentName = assessments.keys.elementAt(index);
              final assessmentData = assessments[assessmentName];
              final status = assessmentData['status'] ?? 'unknown';
              final color = _getColorBasedOnStatus(status);
              return ListTile(
                title: Text(assessmentName),
                tileColor: color.withOpacity(0.2),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssessmentPage(id: widget.id, assessmentName: assessmentName, assessmentData: assessmentData),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
