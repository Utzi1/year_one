import 'package:flutter/material.dart';

// pre-op
import '../assessments/allgemeine_frage.dart';
import '../assessments/ernaerung_malnutrition_assessment.dart';

import '../assessments/barthel_index_assessment.dart';

import '../assessments/moca_5min_assessment_buttons_recode.dart';

// 3rd day post-op
import '../assessments/barthel_index_3_days_assessment.dart';
import '../assessments/charmi_3_days_assessment.dart';
import '../assessments/schmerz_3_days_assessment.dart';
import 'home_page.dart';
import '../services/api_service.dart';
import '../assessments/charmi_assessment.dart';
import '../assessments/sturze_assessment.dart';
import '../assessments/phq4_assessment.dart';
import '../assessments/sozialdemographie_assessment.dart';
import '../assessments/sozialanamnese_assessment.dart';
import '../assessments/schmerz_assessment.dart'; 
import '../assessments/sensorik_assessment.dart';
import '../assessments/patient_goals_assessment.dart';
import '../assessments/isar_score_assessment.dart';
import '../assessments/csf_assessment.dart';  // Add this import

// 3months post-op
import '../assessments/ernaerung_malnutrition_3_months.dart';
import '../assessments/moca_5min_3_months_assessment.dart';
import '../assessments/barthel_index_3_months_assessment.dart';
import '../assessments/phq4_3_months_assessment.dart';

class AssessmentPage extends StatefulWidget {
  final String id;
  final String assessmentName;
  final Map<String, dynamic> assessmentData;

  const AssessmentPage({required this.id, required this.assessmentName, required this.assessmentData, super.key});

  @override
  _AssessmentPageState createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  late Future<String?> _patientExistsFuture;

  @override
  void initState() {
    super.initState();
    _patientExistsFuture = _checkPatientExists();
  }

  Future<String?> _checkPatientExists() async {
    try {
      final result = await ApiService.getPatient(widget.id);
      if (result.containsKey('error')) {
        return result['error'];
      }
      return null;
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AssessmentPage für die ID: ${widget.id}'),
      ),
      drawer: _buildDrawer(context),
      body: FutureBuilder<String?>(
        future: _patientExistsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data != null) {
            return Center(
              child: Text(
                snapshot.data ?? 'An unknown error occurred.',
                style: const TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          } else {
            return _buildAssessmentWidget();
          }
        },
      ),
    );
  }
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            text: 'Home',
            onTap: () => _navigateToHome(context),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Präoperativ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.question_answer,
            text: 'Allgemeine Fragen',
            onTap: () => _navigateToAssessment(context, 'Allgemeine Fragen', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.restaurant,
            text: 'Ernährung und Malnutrition',
            onTap: () => _navigateToAssessment(context, 'Ernährung Malnutrition', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.psychology,
            text: 'MoCA 5min',
            onTap: () => _navigateToAssessment(context, 'MoCA 5min', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.accessibility_new,
            text: 'Barthel Index',
            onTap: () => _navigateToAssessment(context, 'Barthel Index', {}),
          ),
           _buildDrawerItem(
            context,
            icon: Icons.assessment,
            text: 'ISAR Assessment',
            onTap: () => _navigateToAssessment(context, 'ISAR Assessment', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.mood,
            text: 'PHQ-4 Assessment',
            onTap: () => _navigateToAssessment(context, 'PHQ-4 Assessment', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.healing,
            text: 'Schmerz Assessment',
            onTap: () => _navigateToAssessment(context, 'Schmerz Assessment', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.monitor_heart,
            text: 'CHARMI Assessment',
            onTap: () => _navigateToAssessment(context, 'CHARMI Assessment', {}),
          ),        
          _buildDrawerItem(
            context,
            icon: Icons.medical_services,
            text: 'CSF Assessment',
            onTap: () => _navigateToAssessment(context, 'CSF Assessment', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.elderly,
            text: 'Stürz Assessment',
            onTap: () => _navigateToAssessment(context, 'Sturz Assessment', {}),
          ),  
          _buildDrawerItem(
            context,
            icon: Icons.remove_red_eye,
            text: 'Sensorik Assessment',
            onTap: () => _navigateToAssessment(context, 'Sensorik Assessment', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.people,
            text: 'Sozialdemographie',
            onTap: () => _navigateToAssessment(context, 'Sozialdemographie Assessment', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.family_restroom,
            text: 'Sozialanamnese Assessment',
            onTap: () => _navigateToAssessment(context, 'Sozialanamnese Assessment', {}),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('3. Tag postoperativ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.accessibility_new,
            text: 'Barthel Index 3. Tag',
            onTap: () => _navigateToAssessment(context, 'Barthel Index 3. Tag', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.monitor_heart,
            text: 'CHARMI 3. Tag',
            onTap: () => _navigateToAssessment(context, 'CHARMI 3. Tag', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.healing,
            text: 'Schmerz 3. Tag',
            onTap: () => _navigateToAssessment(context, 'Schmerz 3. Tag', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.emoji_events,
            text: 'Patient:innenzentrierte Ziele',
            onTap: () => _navigateToAssessment(context, 'Patient:innenzentrierte Ziele', {}),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Nach 3 Monaten', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.restaurant,
            text: 'Ernährung und Malnutrition 3 Monate',
            onTap: () => _navigateToAssessment(context, 'Ernährung Malnutrition 3. Monat', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.accessibility_new,
            text: 'Barthel Index 3 Monate',
            onTap: () => _navigateToAssessment(context, 'Barthel Index 3. Monat', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.psychology,
            text: 'MoCA 5min 3 Monate',
            onTap: () => _navigateToAssessment(context, 'MoCA 5min 3 Monate', {}),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.mood,
            text: 'PHQ-4 3 Monate',
            onTap: () => _navigateToAssessment(context, 'PHQ-4 3 Monate', {}),
          ),
         

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Nach 15 Monaten', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

        ],
      ),
    );
  }

  Widget _buildAssessmentWidget() {
    switch (widget.assessmentName) {
      case 'Allgemeine Fragen':
        return AllgemeinesAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'Barthel Index':
        return BarthelIndexAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'Ernährung Malnutrition':
        return MalnutritionAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'MoCA 5min':
        return MoCA5MinAssessmentButtonsRecode(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'CHARMI Assessment':
        return CharmiAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'CHARMI 3 Tage':
        return Charmi3DayAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'Sturz Assessment':
        return SturzeAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'PHQ-4 Assessment':
        return PHQ4Assessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'PHQ-4 3 Monate':
        return PHQ4ThreeMonthAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'Sozialdemographie Assessment':
        return SozialdemographieAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'Sozialanamnese Assessment':
        return SozialanamneseAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'Schmerz Assessment':
        return SchmerzAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'Schmerz 3 Tage':
        return Schmerz3DayAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'Sensorik Assessment':
        return SensorikAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'Patient Goals Assessment':
        return PatientGoalsAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'ISAR Assessment':
        return IsarScoreAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'CSF Assessment':
        return CSFAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'Ernährung Malnutrition 3 Monate':
        return MalnutritionThreeMonthAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'Barthel Index 3 Tage':
        return BarthelIndex3DayAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'Barthel Index 3 Monate':
        return BarthelIndex3MonthAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      case 'MoCA 5min 3 Monate':
        return MoCA5Min3MonthAssessment(patientId: widget.id, assessmentData: widget.assessmentData);
      default:
        return const Center(child: Text('Im Reiter auf der Linken Seite können sie die Assessments ausfüllen'));
    }
  }

  ListTile _buildDrawerItem(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage()),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateToAssessment(BuildContext context, String assessmentName, Map<String, dynamic> assessmentData) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentPage(id: widget.id, assessmentName: assessmentName, assessmentData: assessmentData),
      ),
    );
  }
}
