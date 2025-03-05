import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

class SensorikAssessment extends BaseAssessment {
  const SensorikAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<SensorikAssessment> createState() => _SensorikAssessmentState();
}

class _SensorikAssessmentState extends BaseAssessmentState<SensorikAssessment> {
  // Add missing field
  Map<String, dynamic> _lastAssessmentData = {};

  // Information source
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  
  // Sensory questions
  int? _visionProblems;
  int? _wearsGlasses;
  int? _hearingProblems;
  int? _wearsHearingAid;

  final Map<int, String> anamneseInfo = {
    0: 'Eigenanamnese',
    1: 'Fremdanamnese',
    2: 'Auskunft verweigert',
    3: 'keine Auskunft möglich',
  };

  final Map<int, String> yesNoAnswers = {
    0: 'Ja',
    1: 'Nein',
    99: 'Teilnehmer:in weiß es nicht',
    100: 'Teilnehmer:in verweigert Antwort',
  };

  @override
  String get assessmentName => 'Sensorik Assessment';

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
      _visionProblems = _parseIntValue(assessmentData, 'vision_problems');
      _wearsGlasses = _parseIntValue(assessmentData, 'wears_glasses');
      _hearingProblems = _parseIntValue(assessmentData, 'hearing_problems');
      _wearsHearingAid = _parseIntValue(assessmentData, 'wears_hearing_aid');
    });
  }

  /// Safely parses an integer value from assessment data
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

  /// Initialize data from API and handle errors
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
          'vision_problems': _visionProblems?.toString() ?? 'None',
          'wears_glasses': _wearsGlasses?.toString() ?? 'None',
          'hearing_problems': _hearingProblems?.toString() ?? 'None',
          'wears_hearing_aid': _wearsHearingAid?.toString() ?? 'None',
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
        _buildVisionSection(),
        const SizedBox(height: 16),
        _buildHearingSection(),
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

  Widget _buildVisionSection() {
    return Column(
      children: [
        _buildQuestionSection(
          'Haben Sie Probleme mit dem Sehen, z. B. dem Lesen von Überschriften in der Zeitung?',
          _visionProblems,
          (value) => setState(() => _visionProblems = value),
        ),
        const SizedBox(height: 16),
        _buildQuestionSection(
          'Tragen Sie, außer zum Lesen, für gewöhnlich eine Brille?',
          _wearsGlasses,
          (value) => setState(() => _wearsGlasses = value),
        ),
      ],
    );
  }

  Widget _buildHearingSection() {
    return Column(
      children: [
        _buildQuestionSection(
          'Haben Sie Probleme mit dem Hören, wenn viele Menschen durcheinanderreden?',
          _hearingProblems,
          (value) => setState(() => _hearingProblems = value),
        ),
        const SizedBox(height: 16),
        _buildQuestionSection(
          'Tragen Sie für gewöhnlich ein Hörgerät?',
          _wearsHearingAid,
          (value) => setState(() => _wearsHearingAid = value),
        ),
      ],
    );
  }

  /// Builds a question section with yes/no answers
  /// Shows orange background when unanswered
  Widget _buildQuestionSection(String question, int? value, ValueChanged<int?> onChanged) {
    return buildButtonSection(
      question,
      [
        ...yesNoAnswers.entries.map((entry) => RadioListTile<int>(
          title: Text(entry.value),
          value: entry.key,
          groupValue: value,
          onChanged: onChanged,
        )),
      ],
      'Bitte wählen Sie eine Antwort aus.',
      isAnswered: value != null,
    );
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    super.dispose();
  }
}
