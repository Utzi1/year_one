import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/assessment_page.dart';

class UnfilledAssessmentsWidget extends StatefulWidget {
  const UnfilledAssessmentsWidget({Key? key}) : super(key: key);

  @override
  State<UnfilledAssessmentsWidget> createState() => _UnfilledAssessmentsWidgetState();
}

class _UnfilledAssessmentsWidgetState extends State<UnfilledAssessmentsWidget> {
  late Future<List<Map<String, dynamic>>> _unfilledAssessmentsFuture;
  // Add ScrollController
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _unfilledAssessmentsFuture = ApiService.getUnfilledAssessments();
  }

  @override
  void dispose() {
    // Dispose the controller when widget is disposed
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _unfilledAssessmentsFuture = ApiService.getUnfilledAssessments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Unfilled Assessments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshData,
                  tooltip: 'Refresh list',
                ),
              ],
            ),
            const Divider(),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _unfilledAssessmentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: Text('All assessments filled - Great job!')),
                  );
                }
                
                return SizedBox(
                  height: 300,
                  child: Scrollbar(
                    controller: _scrollController, // Assign controller to Scrollbar
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _scrollController, // Assign same controller to ListView
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];
                        final String patientId = item['patient_id'];
                        final String assessmentName = item['assessment_name'];
                        final String patientName = item['patient_name'] ?? 'Unknown';
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.assignment_late_outlined, color: Colors.blue),
                          ),
                          title: Text('$assessmentName'),
                          subtitle: Text('Patient: $patientName (ID: $patientId)'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssessmentPage(
                                  id: patientId,
                                  assessmentName: assessmentName,
                                  assessmentData: {},
                                ),
                              ),
                            ).then((_) => _refreshData());
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
