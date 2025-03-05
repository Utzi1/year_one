import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

class SozialdemographieAssessment extends BaseAssessment {
  const SozialdemographieAssessment({
    required super.patientId, 
    required super.assessmentData,
  });

  @override
  State<SozialdemographieAssessment> createState() => _SozialdemographieAssessmentState();
}

class _SozialdemographieAssessmentState extends BaseAssessmentState<SozialdemographieAssessment> {
  int? _selectedAnamnese;
  final TextEditingController _selectedAnamneseKommentar = TextEditingController();
  int? _selectedFamilyStatus;
  int? _hasChildren;
  final TextEditingController _numberOfChildrenController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic> _lastAssessmentData = {};

  final Map<int, String> anamneseInfo = {
    0: 'Eigenanamnese',
    1: 'Fremdanamnese',
    2: 'Aktenanamnese',
    3: 'Auskunft verweigert',
    4: 'keine Auskunft möglich',
  };

  final Map<int, String> familyStatusInfo = {
    0: 'In Ehe/Partnerschaft lebend',
    1: 'Ledig',
    2: 'Geschieden oder in Trennung lebend',
    3: 'Verwitwet',
    99: 'Teilnehmer:in weiß es nicht',
    100: 'Teilnehmer:in verweigert Antwort',
  };

  final Map<int, String> hasChildrenInfo = {
    0: 'Ja',
    1: 'Nein',
    99: 'Teilnehmer:in weiß es nicht',
    100: 'Teilnehmer:in verweigert Antwort',
  };

  @override
  String get assessmentName => 'Sozialdemographie Assessment';

  @override
  void initState() {
    super.initState();
    if (widget.assessmentData.isNotEmpty) {
      _initializeFromExistingData(widget.assessmentData);
    }
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    try {
      final data = await loadAssessment();
      if (data.isNotEmpty) {
        setState(() {
          _lastAssessmentData = Map<String, dynamic>.from({
            'timestamp': data['timestamp'],
            'unix_timestamp': data['unix_timestamp'],
            'key': data['key'],
            ...data['data'] ?? {},
          });
          _initializeFromExistingData(data);
        });
      }
    } catch (e) {
      showError('Fehler beim Laden: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initializeFromExistingData(Map<String, dynamic> data) {
    final assessmentData = data['data'] ?? data;
    setState(() {
      _selectedAnamnese = _parseIntValue(assessmentData, 'anamnese');
      _selectedAnamneseKommentar.text = assessmentData['anamnese_kommentar']?.toString() ?? '';
      _selectedFamilyStatus = _parseIntValue(assessmentData, 'family_status');
      _hasChildren = _parseIntValue(assessmentData, 'has_children');
      _numberOfChildrenController.text = assessmentData['number_of_children']?.toString() ?? '';
    });
  }

  int? _parseIntValue(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) {
      final value = data[key];
      if (value is int) return value;
      if (value is String) {
        if (value.toLowerCase() == 'null') return null;
        return int.tryParse(value);
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> loadAssessment() async {
    return await ApiService.getLastAssessment(widget.patientId, assessmentName);
  }

  @override
  Future<void> saveAssessment() async {
    if (_selectedAnamnese == null) {
      showError('Bitte wählen Sie eine Informationsquelle aus.');
      return;
    }

    int? numberOfChildren;
    if (_hasChildren == 0) {  // If "Ja" is selected
      numberOfChildren = int.tryParse(_numberOfChildrenController.text);
      if (numberOfChildren == null || numberOfChildren < 1 || numberOfChildren > 30) {
        showError('Bitte geben Sie eine gültige Anzahl von Kindern ein (1-30).');
        return;
      }
    }

    try {
      final result = await ApiService.saveAssessment(
        widget.patientId,
        assessmentName,
        {
          'anamnese': _selectedAnamnese.toString(),
          'anamnese_kommentar': _selectedAnamneseKommentar.text,
          'family_status': _selectedFamilyStatus?.toString() ?? 'None',
          'has_children': _hasChildren?.toString() ?? 'None',
          'number_of_children': numberOfChildren?.toString() ?? 'None',
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Assessment gespeichert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      showError('Fehler beim Speichern: $e');
    }
  }

  @override
  Widget buildAssessmentContent() {
    return Column(
      children: [
        if (_lastAssessmentData.isNotEmpty) ...[
          buildLastAssessment(),
          const SizedBox(height: 24),
          const Divider(),
        ],
        const SizedBox(height: 16),
        buildButtonSection(
          'Informationsquelle',
          [
            buildActionButtonField<int>(
              value: _selectedAnamnese,
              items: anamneseInfo.keys.toList(),
              onChanged: (value) => setState(() => _selectedAnamnese = value),
              itemInfo: anamneseInfo,
            ),
            TextField(
              controller: _selectedAnamneseKommentar,
              decoration: const InputDecoration(
                labelText: 'Kommentar zur Informationsquelle',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
          'Bitte wählen Sie die Quelle der Informationen aus.',
        ),
        const SizedBox(height: 16),
        buildButtonSection(
          'Familienstand',
          [
            ...familyStatusInfo.entries.map((entry) => RadioListTile<int>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _selectedFamilyStatus,
              onChanged: (value) => setState(() => _selectedFamilyStatus = value),
            )),
          ],
          'Was ist Ihr aktueller Familienstand?',
        ),
        const SizedBox(height: 16),
        buildButtonSection(
          'Kinder',
          [
            ...hasChildrenInfo.entries.map((entry) => RadioListTile<int>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _hasChildren,
              onChanged: (value) => setState(() => _hasChildren = value),
            )),
            if (_hasChildren == 0) ...[  // Show number input only if "Ja" is selected
              const SizedBox(height: 16),
              TextField(
                controller: _numberOfChildrenController,
                decoration: const InputDecoration(
                  labelText: 'Wie viele Kinder haben Sie?',
                  border: OutlineInputBorder(),
                  hintText: 'Anzahl der Kinder (1-30)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ],
          'Haben Sie Kinder?',
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: saveAssessment,
          child: const Text('Assessment Speichern'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _selectedAnamneseKommentar.dispose();
    _numberOfChildrenController.dispose();
    super.dispose();
  }

}
