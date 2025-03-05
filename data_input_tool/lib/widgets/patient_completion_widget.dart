import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/assessment_page.dart';

class PatientCompletionWidget extends StatefulWidget {
  const PatientCompletionWidget({Key? key}) : super(key: key);

  @override
  State<PatientCompletionWidget> createState() => _PatientCompletionWidgetState();
}

class _PatientCompletionWidgetState extends State<PatientCompletionWidget> {
  late Future<List<Map<String, dynamic>>> _patientStatsFuture;
  // Add ScrollController
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _patientStatsFuture = ApiService.getPatientCompletionStats();
  }
  
  @override
  void dispose() {
    // Dispose the controller when widget is disposed
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _patientStatsFuture = ApiService.getPatientCompletionStats();
    });
  }

  Color _getCompletionColor(double percentage) {
    if (percentage < 30) {
      return Colors.red;
    } else if (percentage < 70) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
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
                  'Patient Data Completion',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshData,
                  tooltip: 'Refresh stats',
                ),
              ],
            ),
            const Divider(),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _patientStatsFuture,
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
                    child: Center(child: Text('No patient data available')),
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
                        final String patientName = item['patient_name'] ?? 'Unknown';
                        final int filledCount = item['filled_assessments'] ?? 0;
                        final int totalCount = item['total_assessments'] ?? 1;
                        final double completionPercentage = (filledCount / totalCount) * 100;
                        final Color progressColor = _getCompletionColor(completionPercentage);
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey.shade100,
                            child: Text(
                              '${completionPercentage.round()}%',
                              style: TextStyle(color: progressColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(patientName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Patient ID: $patientId'),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: filledCount / totalCount,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$filledCount of $totalCount assessments completed',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () {
                            ApiService.getUnfilledAssessments().then((unfilled) {
                              final patientUnfilled = unfilled.where(
                                (assessment) => assessment['patient_id'] == patientId
                              ).toList();
                              
                              if (patientUnfilled.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AssessmentPage(
                                      id: patientId,
                                      assessmentName: patientUnfilled.first['assessment_name'],
                                      assessmentData: {},
                                    ),
                                  ),
                                ).then((_) => _refreshData());
                              }
                            });
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
