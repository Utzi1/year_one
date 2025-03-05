import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

/// The Montreal Cognitive Assessment (MoCA) 5-Minute Protocol
/// A brief cognitive screening test focusing on key domains:
/// * Memory (5 points)
/// * Attention (3 points)
/// * Verbal Fluency (3 points)
/// * Orientation (4 points)
///
/// Total score: 0-15 points
/// Cutoff score for cognitive impairment: <10 points

class MoCA5MinAssessment extends BaseAssessment {
  const MoCA5MinAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<MoCA5MinAssessment> createState() => _MoCA5MinAssessmentState();
}

class _MoCA5MinAssessmentState extends BaseAssessmentState<MoCA5MinAssessment> {
  @override
  Future<Map<String, dynamic>> loadAssessment() async {
    return {};
  }
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  int? _memoryScore;
  int? _attentionScore;
  int? _fluencyScore;
  int? _orientationScore;
  final TextEditingController _commentController = TextEditingController();

  static const Map<int, String> _anamneseOptions = {
    0: 'Eigenanamnese',
    1: 'Fremdanamnese',
    2: 'Aktenanamnese',
    3: 'Auskunft verweigert',
    4: 'keine Auskunft möglich',
  };

  @override
  String get assessmentName => 'MoCA 5-Min Assessment';

  @override
  void initState() {
    super.initState();
    if (widget.assessmentData.isNotEmpty) {
      _initializeFromData(widget.assessmentData);
    }
  }

  int _parseIntValue(Map<String, dynamic> data, String key) {
    return int.tryParse(data[key]?.toString() ?? '') ?? 0;
  }

  void _initializeFromData(Map<String, dynamic> data) {
    final assessmentData = data['data'] ?? data;
    setState(() {
      _selectedAnamnese = _parseIntValue(assessmentData, 'anamnese');
      _anamneseKommentar.text = assessmentData['anamnese_kommentar']?.toString() ?? '';
      _memoryScore = _parseIntValue(assessmentData, 'memory_score');
      _attentionScore = _parseIntValue(assessmentData, 'attention_score');
      _fluencyScore = _parseIntValue(assessmentData, 'fluency_score');
      _orientationScore = _parseIntValue(assessmentData, 'orientation_score');
      _commentController.text = assessmentData['comment']?.toString() ?? '';
    });
  }

  int _calculateTotalScore() {
    return (_memoryScore ?? 0) +
           (_attentionScore ?? 0) +
           (_fluencyScore ?? 0) +
           (_orientationScore ?? 0);
  }

  @override
  Widget buildAssessmentContent() {
    return Column(
      children: [
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildMemorySection(),
        const SizedBox(height: 16),
        _buildAttentionSection(),
        const SizedBox(height: 16),
        _buildFluencySection(),
        const SizedBox(height: 16),
        _buildOrientationSection(),
        const SizedBox(height: 16),
        _buildTotalScoreSection(),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: saveAssessment,
          child: const Text('Assessment Speichern'),
        ),
      ],
    );
  }

  Widget _buildMemorySection() {
    return buildButtonSection(
      'Gedächtnis (0-5 Punkte)',
      [
        buildActionButtonField<int>(
          value: _memoryScore,
          items: const [0, 1, 2, 3, 4, 5],
          onChanged: (value) => setState(() => _memoryScore = value),
          itemInfo: const {
            0: '0 Wörter',
            1: '1 Wort',
            2: '2 Wörter',
            3: '3 Wörter',
            4: '4 Wörter',
            5: '5 Wörter',
          },
        ),
      ],
      'Anzahl der richtig erinnerten Wörter nach verzögertem Abruf',
      isAnswered: _memoryScore != null,
    );
  }

  // ... implement other sections similarly ...

  @override
  Future<void> saveAssessment() async {
    if (!_validateForm()) return;

    try {
      final result = await ApiService.saveAssessment(
        widget.patientId,
        assessmentName,
        _prepareDataForSave(),
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

  bool _validateForm() {
    if (_selectedAnamnese == null) {
      showError('Bitte wählen Sie eine Anamnese-Option.');
      return false;
    }
    if (_memoryScore == null) {
      showError('Bitte geben Sie eine Gedächtnisbewertung ein.');
      return false;
    }
    if (_attentionScore == null) {
      showError('Bitte geben Sie eine Aufmerksamkeitsbewertung ein.');
      return false;
    }
    if (_fluencyScore == null) {
      showError('Bitte geben Sie eine Sprachflüssigkeitsbewertung ein.');
      return false;
    }
    if (_orientationScore == null) {
      showError('Bitte geben Sie eine Orientierungsbewertung ein.');
      return false;
    }
    return true;
  }

  Map<String, dynamic> _prepareDataForSave() {
    return {
      'anamnese': _selectedAnamnese,
      'anamnese_kommentar': _anamneseKommentar.text,
      'memory_score': _memoryScore,
      'attention_score': _attentionScore,
      'fluency_score': _fluencyScore,
      'orientation_score': _orientationScore,
      'comment': _commentController.text,
      'total_score': _calculateTotalScore(),
    };
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildAnamneseSection() {
    return buildButtonSection(
      'Anamnese',
      [
        buildActionButtonField<int>(
          value: _selectedAnamnese,
          items: _anamneseOptions.keys.toList(),
          onChanged: (value) => setState(() => _selectedAnamnese = value),
          itemInfo: _anamneseOptions,
        ),
        TextField(
          controller: _anamneseKommentar,
          decoration: const InputDecoration(
            labelText: 'Kommentar',
          ),
        ),
      ],
      'Wählen Sie die Art der Anamnese und geben Sie ggf. einen Kommentar ein.',
      isAnswered: _selectedAnamnese != null,
    );
  }

  Widget _buildAttentionSection() {
    return buildButtonSection(
      'Aufmerksamkeit (0-3 Punkte)',
      [
        buildActionButtonField<int>(
          value: _attentionScore,
          items: const [0, 1, 2, 3],
          onChanged: (value) => setState(() => _attentionScore = value),
          itemInfo: const {
            0: '0 Punkte',
            1: '1 Punkt',
            2: '2 Punkte',
            3: '3 Punkte',
          },
        ),
      ],
      'Bewerten Sie die Aufmerksamkeit des Patienten.',
      isAnswered: _attentionScore != null,
    );
  }

  Widget _buildFluencySection() {
    return buildButtonSection(
      'Sprachflüssigkeit (0-3 Punkte)',
      [
        buildActionButtonField<int>(
          value: _fluencyScore,
          items: const [0, 1, 2, 3],
          onChanged: (value) => setState(() => _fluencyScore = value),
          itemInfo: const {
            0: '0 Punkte',
            1: '1 Punkt',
            2: '2 Punkte',
            3: '3 Punkte',
          },
        ),
      ],
      'Bewerten Sie die Sprachflüssigkeit des Patienten.',
      isAnswered: _fluencyScore != null,
    );
  }

  Widget _buildOrientationSection() {
    return buildButtonSection(
      'Orientierung (0-4 Punkte)',
      [
        buildActionButtonField<int>(
          value: _orientationScore,
          items: const [0, 1, 2, 3, 4],
          onChanged: (value) => setState(() => _orientationScore = value),
          itemInfo: const {
            0: '0 Punkte',
            1: '1 Punkt',
            2: '2 Punkte',
            3: '3 Punkte',
            4: '4 Punkte',
          },
        ),
      ],
      'Bewerten Sie die Orientierung des Patienten.',
      isAnswered: _orientationScore != null,
    );
  }

  Widget _buildTotalScoreSection() {
    return buildButtonSection(
      'Gesamtpunktzahl',
      [
        Text(
          'Gesamtpunktzahl: ${_calculateTotalScore()}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
      'Die Gesamtpunktzahl des Assessments.',
      isAnswered: true,
    );
  }
}
