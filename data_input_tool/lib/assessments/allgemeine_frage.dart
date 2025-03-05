import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AllgemeinesAssessment extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> assessmentData;

  const AllgemeinesAssessment({required this.patientId, required this.assessmentData, super.key});

  @override
  _AllgemeinesAssessmentState createState() => _AllgemeinesAssessmentState();
}

class _AllgemeinesAssessmentState extends State<AllgemeinesAssessment> {
  final TextEditingController _alterController = TextEditingController();
  final TextEditingController _operationController = TextEditingController();
  final TextEditingController _isarScoreController = TextEditingController();
  String _selectedGeschlecht = 'NA';

  @override
  void initState() {
    super.initState();
    _loadAssessmentData();
  }

  void _loadAssessmentData() {
    final data = widget.assessmentData;
    _alterController.text = data['alter']?.toString() ?? '';
    _selectedGeschlecht = data['geschlecht']?.toString() ?? 'NA';
    _operationController.text = data['operation']?.toString() ?? '';
    _isarScoreController.text = data['isar_score']?.toString() ?? '';
  }

  @override
  void dispose() {
    _alterController.dispose();
    _operationController.dispose();
    _isarScoreController.dispose();
    super.dispose();
  }

  Future<void> _saveAssessment() async {
    final alter = _alterController.text;
    final geschlecht = _selectedGeschlecht;
    final operation = _operationController.text;
    final isarScore = _isarScoreController.text;

    if (_isInputValid(alter, geschlecht, operation, isarScore)) {
      final confirm = await _showConfirmationDialog();
      if (confirm) {
        final data = {
          'alter': alter,
          'geschlecht': geschlecht,
          'operation': operation,
          'isar_score': isarScore,
        };
        final result = await ApiService.postHashMap(widget.patientId, 'Allgemeines Assessment', data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to save assessment')),
        );
        _clearFields();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitte geben Sie gültige Werte ein!')),
      );
    }
  }

  bool _isInputValid(String alter, String geschlecht, String operation, String isarScore) {
    final int? alterInt = int.tryParse(alter);
    final int? isarScoreInt = int.tryParse(isarScore);
    return alterInt != null && alterInt > 0 && alterInt < 120 &&
           geschlecht.isNotEmpty &&
           operation.isNotEmpty &&
           isarScoreInt != null && isarScoreInt >= 0 && isarScoreInt <= 100;
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(''),
          content: Text('Wollen sie sicher dieses Assessment sichern?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Bestätigen'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _clearFields() {
    _alterController.clear();
    _selectedGeschlecht = 'NA';
    _operationController.clear();
    _isarScoreController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Allgemeines Assessment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _alterController,
              decoration: InputDecoration(
                labelText: 'Alter',
                hintText: 'Geben Sie das Alter des Patienten ein',
              ),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _selectedGeschlecht,
              decoration: InputDecoration(
                labelText: 'Geschlecht',
                hintText: 'Wählen Sie das Geschlecht',
              ),
              items: ['NA', 'Männlich', 'Weiblich', 'Andere'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedGeschlecht = newValue!;
                });
              },
            ),
            TextField(
              controller: _operationController,
              decoration: InputDecoration(
                labelText: 'Operation',
                hintText: 'Geben Sie die Operation ein',
              ),
            ),
            TextField(
              controller: _isarScoreController,
              decoration: InputDecoration(
                labelText: 'ISAR Score',
                hintText: 'Geben Sie den ISAR Score ein',
              ),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _saveAssessment,
              child: Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
