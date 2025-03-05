import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'assessment_page.dart';

/// A widget for displaying assessments.
/// 
/// This widget displays a list of assessments for a given ID.
/// Each assessment is shown in an expansion tile with its details.
class DisplayAssessments extends StatelessWidget {
  final String id;

  /// Creates a [DisplayAssessments] widget.
  ///
  /// The [id] parameter must not be null and is required to fetch the
  /// assessments for the specified patient.
  const DisplayAssessments({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assessments for ID: $id'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getAssessments(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildNoAssessmentsFound(context);
          } else {
            return _buildAssessmentsList(snapshot.data!);
          }
        },
      ),
    );
  }

  /// Builds the widget to display when no assessments are found.
  Widget _buildNoAssessmentsFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No assessments found'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssessmentPage(
                    id: id,
                    assessmentName: 'Age and Wellbeing Assessment',
                    assessmentData: {},
                  ),
                ),
              );
            },
            child: const Text('Fill Out Assessment'),
          ),
        ],
      ),
    );
  }

  /// Builds the list of assessments.
  Widget _buildAssessmentsList(Map<String, dynamic> assessments) {
    return ListView.builder(
      itemCount: assessments.length,
      itemBuilder: (context, index) {
        final assessmentName = assessments.keys.elementAt(index);
        final assessmentData = assessments[assessmentName];
        return _buildAssessmentTile(context, assessmentName, assessmentData);
      },
    );
  }

  /// Builds an individual assessment tile.
  Widget _buildAssessmentTile(BuildContext context, String assessmentName, Map<String, dynamic> assessmentData) {
    return ExpansionTile(
      title: Text(assessmentName),
      children: [
        ...assessmentData.entries.map<Widget>((entry) {
          return ListTile(
            title: Text('${entry.key}: ${entry.value}'),
          );
        }).toList(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssessmentPage(
                    id: id,
                    assessmentName: assessmentName,
                    assessmentData: assessmentData,
                  ),
                ),
              );
            },
            child: const Text('View Assessment'),
          ),
        ),
      ],
    );
  }
}
