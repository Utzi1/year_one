import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'create_patient.dart';
import '../widgets/key_value_manager.dart';
import 'assessment_page.dart';
import 'read_assessment_data.dart';
import 'isar_assessment_standalone.dart';
import 'create_patient_by_department.dart';
import '../widgets/unfilled_assessments_widget.dart';
import '../widgets/patient_completion_widget.dart';

/// The home page of the application.
/// 
/// This widget serves as the main entry point of the application,
/// providing navigation to different features such as creating a patient,
/// searching for assessments, and managing key-value pairs.
/// It also allows the users to compute the isar score on its main page.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input-Tool'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.person_add,
              text: 'Create Patient',
              onTap: () => _navigateTo(context, const CreatePatientForm(), 'Create Patient'),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.vpn_key,
              text: 'Key-Value Manager',
              onTap: () => _navigateTo(context, const KeyValueManager(), 'Key-Value Manager'),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.search,
              text: 'Search Assessment',
              onTap: () => _navigateTo(context, const ReadAssessmentData(), 'Search Assessment'),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.assignment,
              text: 'ISAR Assessment Standalone',
              onTap: () => _navigateTo(context, const IsarScoreAssessment(), 'ISAR Assessment Standalone'),
            ),
          ],
        ),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          primary: true, // Use primary ScrollController
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search by ID',
                  hintText: 'Enter ID',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final id = _searchController.text.trim();
                  if (id.isNotEmpty) {
                    final result = await ApiService.getAllData(id);
                    if (result.containsKey('error')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ID not found: ${result['error']}')),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssessmentPage(id: id, assessmentName: 'Dummy Assessment', assessmentData: result),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Search'),
              ),
              const SizedBox(height: 24),
              
              // Adding the new widgets for tracking progress
              const UnfilledAssessmentsWidget(),
              const PatientCompletionWidget(),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IsarScoreAssessment(),
                    ),
                  );
                },
                child: const Text('Go to ISAR Assessment Standalone'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePatientByDepartment(),
                    ),
                  );
                },
                child: const Text('Create Patient by Department'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget page, String title) {
    Navigator.pop(context); // Close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: page,
        ),
      ),
    );
  }
}
