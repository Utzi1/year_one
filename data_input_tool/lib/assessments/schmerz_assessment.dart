import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

class SchmerzAssessment extends BaseAssessment {
  const SchmerzAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<SchmerzAssessment> createState() => _SchmerzAssessmentState();
}

class _SchmerzAssessmentState extends BaseAssessmentState<SchmerzAssessment> {
  // Information source
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  
  // NRS Pain score
  int? _painScore;

  final Map<int, String> anamneseInfo = {
    0: 'Eigenanamnese',
    1: 'Fremdanamnese',
    2: 'Aktenanamnese',
    3: 'Auskunft verweigert',
    4: 'keine Auskunft möglich',
  };

  final Map<int, String> painScaleInfo = {
    0: 'Kein Schmerz',
    1: '',
    2: '',
    3: '',
    4: '',
    5: 'Moderater Schmerz',
    6: '',
    7: '',
    8: '',
    9: '',
    10: 'Stärkster vorstellbarer Schmerz',
  };

  // Add missing field
  Map<String, dynamic> _lastAssessmentData = {};

  @override
  String get assessmentName => 'Schmerz Assessment';

  @override
  void initState() {
    super.initState();
    if (widget.assessmentData.isNotEmpty) {
      _initializeFromExistingData(widget.assessmentData);
    }
    _initializeData();
  }

  void _initializeFromExistingData(Map<String, dynamic> data) {
    final assessmentData = data['data'] ?? data;
    setState(() {
      _selectedAnamnese = _parseIntValue(assessmentData, 'anamnese');
      _anamneseKommentar.text = assessmentData['anamnese_kommentar']?.toString() ?? '';
      _painScore = _parseIntValue(assessmentData, 'pain_score');
    });
  }

  int? _parseIntValue(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) {
      final value = data[key];
      if (value is int) return value;
      if (value is String) {
        if (value.toLowerCase() == 'null' || value == 'None') return null;
        return int.tryParse(value);
      }
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> loadAssessment() async {
    try {
      return await ApiService.getLastAssessment(
        widget.patientId,
        assessmentName,
      );
    } catch (e) {
      showError('Fehler beim Laden des Assessments: $e');
      return {};
    }
  }

  void _initializeData() async {
    try {
      final data = await loadAssessment();
      if (mounted && data.isNotEmpty) {
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
      if (mounted) {
        showError('Fehler beim Laden des Assessments: $e');
      }
    }
  }

  bool validateForm() {
    if (_selectedAnamnese == null) {
      showError('Bitte wählen Sie eine Informationsquelle aus.');
      return false;
    }

    if (_painScore == null) {
      showError('Bitte wählen Sie einen Schmerzwert aus.');
      return false;
    }

    return true;
  }

  @override
  Future<void> saveAssessment() async {
    if (!validateForm()) return;

    try {
      final result = await ApiService.saveAssessment(
        widget.patientId,
        assessmentName,
        {
          'anamnese': _selectedAnamnese.toString(),
          'anamnese_kommentar': _anamneseKommentar.text,
          'pain_score': _painScore?.toString() ?? 'None',
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
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildPainSection(),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: saveAssessment,
          child: const Text('Assessment Speichern'),
        ),
      ],
    );
  }

  Widget _buildAnamneseSection() {
    return buildButtonSection(
      'Informationsquelle',
      [
        buildActionButtonField<int>(
          value: _selectedAnamnese,
          items: anamneseInfo.keys.toList(),
          onChanged: (value) => setState(() => _selectedAnamnese = value),
          itemInfo: anamneseInfo,
        ),
        TextField(
          controller: _anamneseKommentar,
          decoration: const InputDecoration(
            labelText: 'Kommentar zur Informationsquelle',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
      'Bitte wählen Sie die Quelle der Informationen aus.',
      isAnswered: _selectedAnamnese != null,
    );
  }

  /// Builds the pain score section with NRS scale
  /// Shows orange background when unanswered
  Widget _buildPainSection() {
    return buildButtonSection(
      'Schmerzskala (NRS)',
      [
        const Text(
          'Im Folgenden möchte ich Sie zu ihren aktuellen Schmerzen befragen. '
          'Wie stark sind Ihre derzeitigen Schmerzen auf einer Skala von 0 '
          '(kein Schmerz) bis 10 (stärkster vorstellbarer Schmerz)?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...painScaleInfo.entries.map((entry) => RadioListTile<int>(
          title: Text('${entry.key}${entry.value.isNotEmpty ? ' - ${entry.value}' : ''}'),
          value: entry.key,
          groupValue: _painScore,
          onChanged: (value) => setState(() => _painScore = value),
        )),
      ],
      'Bitte wählen Sie einen Wert zwischen 0 und 10.',
      isAnswered: _painScore != null,
    );
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    super.dispose();
  }
}
