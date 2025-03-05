import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

/// The ISAR Score Assessment (Identification of Seniors At Risk)
/// is a screening tool to identify elderly patients at risk.
/// It evaluates six key areas:
/// * Pre-admission care needs
/// * Acute changes in care needs
/// * Recent hospitalization
/// * Vision problems
/// * Memory problems
/// * Medication use
///
/// Scoring:
/// * Each "yes" answer = 1 point
/// * Total score ≥ 2 indicates high risk
/// * Maximum score is 6 points

/// ISAR Score Assessment widget for elderly risk screening.
/// Implements standardized risk assessment protocol.
class IsarScoreAssessment extends BaseAssessment {
  const IsarScoreAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<IsarScoreAssessment> createState() => _IsarScoreAssessmentState();
}

/// State management for ISAR Score Assessment.
/// Handles binary responses and calculates risk scores.
class _IsarScoreAssessmentState extends BaseAssessmentState<IsarScoreAssessment> {
  // Form state
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  final List<bool?> _answers = List.filled(6, null);

  static const Map<int, String> _anamneseOptions = {
    0: 'Eigenanamnese',
    1: 'Fremdanamnese',
    2: 'Aktenanamnese',
    3: 'Auskunft verweigert',
    4: 'keine Auskunft möglich',
  };

  /// Predefined questions for the ISAR assessment.
  /// Each question includes:
  /// * Title: Brief identifier
  /// * Text: Full question text
  /// * Help: Additional guidance for interviewer
  static const List<Question> _questions = [
    Question(
      title: 'Hilfebedarf',
      text: 'Waren Sie vor der Erkrankung oder Verletzung, die Sie in die Klinik geführt hat, auf regelmäßige Hilfe angewiesen?',
      help: 'Hinweis an Interviewer:in: Es geht um die Zeit unmittelbar vor dem aktuellen Krankenhausaufenthalt.',
    ),
    Question(
      title: 'Akute Veränderung des Hilfebedarfs',
      text: 'Benötigten Sie in den letzten 24 Stunden mehr Hilfe als zuvor?',
      help: 'Hinweis an Interviewer:in: Es geht um den Vergleich des aktuellen Hilfebedarfs mit dem üblichen Hilfebedarf.',
    ),
    Question(
      title: 'Hospitalisation',
      text: 'Waren Sie innerhalb der letzten 6 Monate für einen oder mehrere Tage im Krankenhaus?',
      help: 'Hinweis an Interviewer:in: Alle stationären Krankenhausaufenthalte zählen, unabhängig von der Ursache.',
    ),
    Question(
      title: 'Sensorische Einschränkung',
      text: 'Haben Sie unter normalen Umständen erhebliche Probleme mit dem Sehen, die nicht mit einer Brille korrigiert werden können?',
      help: 'Hinweis an Interviewer:in: Es geht um die verbleibende Sehbeeinträchtigung trotz optimaler Korrektur (z.B. mit Brille).',
    ),
    Question(
      title: 'Kognitive Einschränkungen',
      text: 'Haben Sie ernsthafte Probleme mit dem Gedächtnis?',
      help: 'Hinweis an Interviewer:in: Bei Fremdanamnese fragen Sie nach beobachteten Gedächtnisproblemen.',
    ),
    Question(
      title: 'Multimorbidität',
      text: 'Nehmen Sie pro Tag sechs oder mehr verschiedene Medikamente ein?',
      help: 'Hinweis an Interviewer:in: Alle regelmäßig eingenommenen Medikamente zählen, unabhängig von der Darreichungsform.',
    ),
  ];

  /// Calculates total score based on "yes" answers.
  /// Score of 2 or more indicates high risk.
  int get _totalScore => _answers.where((answer) => answer == true).length;

  @override
  String get assessmentName => 'ISAR-Score';

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
      
      final List<dynamic>? answersData = assessmentData['answers'];
      if (answersData != null) {
        for (int i = 0; i < answersData.length && i < _answers.length; i++) {
          _answers[i] = answersData[i] == 1 || answersData[i] == true;
        }
      }
    });
  }

  int? _parseIntValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
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
    if (_selectedAnamnese == null || _answers.contains(null)) {
      showError('Bitte füllen Sie alle Felder aus.');
      return false;
    }
    return true;
  }

  Map<String, dynamic> _prepareDataForSave() {
    return {
      'anamnese': _selectedAnamnese.toString(),
      'anamnese_kommentar': _anamneseKommentar.text,
      'answers': _answers.map((a) => a == true ? 1 : 0).toList(),
      'total_score': _totalScore,
    };
  }

  @override
  Widget buildAssessmentContent() {
    return Column(
      children: [
        _buildAnamneseSection(),
        ..._questions.asMap().entries.map((entry) => 
          _buildQuestionSection(entry.key, entry.value)
        ),
        _buildScoreSection(),
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

  Widget _buildQuestionSection(int index, Question question) {
    return buildButtonSection(
      question.title,
      [
        Text(question.text),
        if (question.help != null) ...[
          const SizedBox(height: 8),
          Text(
            question.help!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade900,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('JA'),
              selected: _answers[index] == true,
              onSelected: (selected) => setState(() => 
                _answers[index] = selected ? true : null
              ),
            ),
            const SizedBox(width: 16),
            ChoiceChip(
              label: const Text('NEIN'),
              selected: _answers[index] == false,
              onSelected: (selected) => setState(() => 
                _answers[index] = selected ? false : null
              ),
            ),
          ],
        ),
      ],
      question.help ?? '',
      isAnswered: _answers[index] != null,
    );
  }

  Widget _buildScoreSection() {
    final score = _totalScore;
    final bool isStudyEligible = score >= 2;

    return buildButtonSection(
      'Gesamtpunktzahl',
      [
        Text(
          'ISAR-Score: $score/6',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (!isStudyEligible) ...[
          const SizedBox(height: 16),
          const Text(
            'Einschlusskriterium Studie nicht erfüllt.',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
      'Der ISAR-Score berechnet sich aus der Anzahl der mit "JA" beantworteten Fragen.',
      isAnswered: !_answers.contains(null),
    );
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    super.dispose();
  }
}

class Question {
  final String title;
  final String text;
  final String? help;

  const Question({
    required this.title,
    required this.text,
    this.help,
  });
}


