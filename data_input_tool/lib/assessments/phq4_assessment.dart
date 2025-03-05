import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

/// The PHQ-4 Assessment (Patient Health Questionnaire-4)
/// A brief screening tool for depression and anxiety.
/// 
/// Evaluates four key areas over the past 2 weeks:
/// * Interest in activities
/// * Feeling depressed
/// * Feeling anxious
/// * Ability to control worrying
///
/// Scoring:
/// * Each item scored 0-3 (Not at all to Nearly every day)
/// * Depression subscore: Sum of first two items
/// * Anxiety subscore: Sum of last two items
/// * Total score: Sum of all items (0-12)

class PHQ4Assessment extends BaseAssessment {
  const PHQ4Assessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<PHQ4Assessment> createState() => _PHQ4AssessmentState();
}

class _PHQ4AssessmentState extends BaseAssessmentState<PHQ4Assessment> {
  // Form state
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  int? _interestScore;
  int? _depressionScore;
  int? _anxietyScore;
  int? _worryScore;

  static const Map<int, String> _anamneseOptions = {
    0: 'Eigenanamnese',
    1: 'Auskunft verweigert',
    2: 'keine Auskunft möglich',
  };

  static const Map<int, String> scoreInfo = {
    0: 'Überhaupt nicht',
    1: 'An einzelnen Tagen',
    2: 'An mehr als der Hälfte der Tage',
    3: 'Beinahe jeden Tag',
  };

  @override
  String get assessmentName => 'PHQ-4 Assessment';

  @override
  void initState() {
    super.initState();
    if (widget.assessmentData.isNotEmpty) {
      _initializeFromData(widget.assessmentData);
    }
  }

  void _initializeFromData(Map<String, dynamic> data) {
    final assessmentData = data['data'] ?? data;
    setState(() {
      _selectedAnamnese = _parseIntValue(assessmentData, 'anamnese');
      _anamneseKommentar.text = assessmentData['anamnese_kommentar']?.toString() ?? '';
      _interestScore = _parseIntValue(assessmentData, 'interest_score');
      _depressionScore = _parseIntValue(assessmentData, 'depression_score');
      _anxietyScore = _parseIntValue(assessmentData, 'anxiety_score');
      _worryScore = _parseIntValue(assessmentData, 'worry_score');
    });
  }

  int? _parseIntValue(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) {
      final value = data[key];
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> loadAssessment() async {
    try {
      return await ApiService.getLastAssessment(widget.patientId, assessmentName);
    } catch (e) {
      showError('Fehler beim Laden: $e');
      return {};
    }
  }

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
    if (_selectedAnamnese == null ||
        _interestScore == null ||
        _depressionScore == null ||
        _anxietyScore == null ||
        _worryScore == null) {
      showError('Bitte füllen Sie alle Felder aus.');
      return false;
    }
    return true;
  }

  Map<String, String> _prepareDataForSave() {
    return {
      'anamnese': _selectedAnamnese.toString(),
      'anamnese_kommentar': _anamneseKommentar.text,
      'interest_score': _interestScore.toString(),
      'depression_score': _depressionScore.toString(),
      'anxiety_score': _anxietyScore.toString(),
      'worry_score': _worryScore.toString(),
      'total_score': _calculateTotalScore().toString(),
      'depression_subscore': _calculateDepressionScore().toString(),
      'anxiety_subscore': _calculateAnxietyScore().toString(),
    };
  }

  int _calculateTotalScore() {
    return (_interestScore ?? 0) +
           (_depressionScore ?? 0) +
           (_anxietyScore ?? 0) +
           (_worryScore ?? 0);
  }

  int _calculateDepressionScore() {
    return (_interestScore ?? 0) + (_depressionScore ?? 0);
  }

  int _calculateAnxietyScore() {
    return (_anxietyScore ?? 0) + (_worryScore ?? 0);
  }

  @override
  Widget buildAssessmentContent() {
    return Column(
      children: [
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildQuestionsSection(),
        const SizedBox(height: 16),
        _buildScoresSection(),
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
          items: _anamneseOptions.keys.toList(),
          onChanged: (value) => setState(() => _selectedAnamnese = value),
          itemInfo: _anamneseOptions,
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

  Widget _buildQuestionsSection() {
    return buildButtonSection(
      'PHQ-4 Fragebogen',
      [
        const Text(
          'Wie oft fühlten Sie sich im Verlauf der letzten 2 Wochen durch '
          'die folgenden Beschwerden beeinträchtigt?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildQuestionField(
          'Wenig Interesse oder Freude an Ihren Tätigkeiten',
          _interestScore,
          (value) => setState(() => _interestScore = value),
        ),
        _buildQuestionField(
          'Niedergeschlagenheit, Schwermut oder Hoffnungslosigkeit',
          _depressionScore,
          (value) => setState(() => _depressionScore = value),
        ),
        _buildQuestionField(
          'Nervosität, Ängstlichkeit oder Anspannung',
          _anxietyScore,
          (value) => setState(() => _anxietyScore = value),
        ),
        _buildQuestionField(
          'Nicht in der Lage sein, Sorgen zu stoppen oder zu kontrollieren',
          _worryScore,
          (value) => setState(() => _worryScore = value),
        ),
      ],
      'Bewerten Sie jede Frage auf einer Skala von 0 bis 3',
      isAnswered: _interestScore != null &&
                  _depressionScore != null &&
                  _anxietyScore != null &&
                  _worryScore != null,
    );
  }

  Widget _buildQuestionField(String question, int? value, ValueChanged<int?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(question),
        ),
        buildActionButtonField<int>(
          value: value,
          items: scoreInfo.keys.toList(),
          onChanged: onChanged,
          itemInfo: scoreInfo,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildScoresSection() {
    final totalScore = _calculateTotalScore();
    final depressionScore = _calculateDepressionScore();
    final anxietyScore = _calculateAnxietyScore();

    return buildButtonSection(
      'Auswertung',
      [
        Text('Gesamtpunktzahl: $totalScore/12',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('Depression Subscore: $depressionScore/6'),
        Text('Angst Subscore: $anxietyScore/6'),
      ],
      'Depression Subscore ≥ 3: Mögliche Depression\n'
      'Angst Subscore ≥ 3: Mögliche Angststörung',
      isAnswered: true,
    );
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    super.dispose();
  }
}
