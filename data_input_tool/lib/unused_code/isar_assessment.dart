import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../assessments/base_assessment.dart';

// Main class for ISAR Assessment, extending BaseAssessment
class IsarAssessment extends BaseAssessment {
  const IsarAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<IsarAssessment> createState() => _IsarAssessmentState();
}

// State class for IsarAssessment
class _IsarAssessmentState extends BaseAssessmentState<IsarAssessment> {
  // Stores the last assessment data
  Map<String, dynamic> _lastAssessmentData = {};

  // Selected information source
  int? _selectedAnamnese;
  // Controller for the comment text field
  final TextEditingController _anamneseKommentar = TextEditingController();

  // Map to store answers to ISAR questions
  final Map<String, bool?> _answers = {
    'regular_help': null,
    'increased_help': null,
    'hospitalization': null,
    'vision_problems': null,
    'memory_problems': null,
    'medications': null,
  };

  // Information source options
  final Map<int, String> anamneseInfo = {
    0: 'Eigenanamnese',
    1: 'Fremdanamnese',
    2: 'Aktenanamnese',
    3: 'Auskunft verweigert',
    4: 'keine Auskunft möglich',
  };

  // List of questions for the assessment
  final List<Map<String, dynamic>> questions = [
    {
      'key': 'regular_help',
      'title': 'Hilfebedarf',
      'text': 'Waren Sie vor der Erkrankung oder Verletzung, die Sie in die Klinik geführt hat, auf regelmäßige Hilfe angewiesen?',
      'help': 'Hinweis an Interviewer:in: Es geht um die Zeit unmittelbar vor dem aktuellen Krankenhausaufenthalt.'
    },
    {
      'key': 'increased_help',
      'title': 'Akute Veränderung des Hilfebedarfs',
      'text': 'Benötigten Sie in den letzten 24 Stunden mehr Hilfe als zuvor?',
      'help': 'Hinweis an Interviewer:in: Es geht um den Vergleich des aktuellen Hilfebedarfs mit dem üblichen Hilfebedarf.',
    },
    {
      'key': 'hospitalization',
      'title': 'Hospitalisation',
      'text': 'Waren Sie innerhalb der letzten 6 Monate für einen oder mehrere Tage im Krankenhaus?',
      'help': 'Hinweis an Interviewer:in: Alle stationären Krankenhausaufenthalte zählen, unabhängig von der Ursache.',
    },
    {
      'key': 'vision_problems',
      'title': 'Sensorische Einschränkung',
      'text': 'Haben Sie unter normalen Umständen erhebliche Probleme mit dem Sehen, die nicht mit einer Brille korrigiert werden können?',
      'help': 'Hinweis an Interviewer:in: Es geht um die verbleibende Sehbeeinträchtigung trotz optimaler Korrektur (z.B. mit Brille).',
    },
    {
      'key': 'memory_problems',
      'title': 'Kognitive Einschränkungen',
      'text': 'Haben Sie ernsthafte Probleme mit dem Gedächtnis?',
      'help': 'Hinweis an Interviewer:in: Bei Fremdanamnese fragen Sie nach beobachteten Gedächtnisproblemen.',
    },
    {
      'key': 'medications',
      'title': 'Multimorbidität',
      'text': 'Nehmen Sie pro Tag sechs oder mehr verschiedene Medikamente ein?',
      'help': 'Hinweis an Interviewer:in: Alle regelmäßig eingenommenen Medikamente zählen, unabhängig von der Darreichungsform.',
    },
  ];

  // Getter for ISAR score, counting the number of true answers
  int get isarScore => _answers.values.where((v) => v == true).length;

  @override
  String get assessmentName => 'ISAR Assessment';

  @override
  void initState() {
    super.initState();
    // Initialize from existing data if available
    if (widget.assessmentData.isNotEmpty) {
      _initializeFromExistingData(widget.assessmentData);
    }
    // Load assessment data
    _initializeData();
  }

  // Initialize state from existing data
  void _initializeFromExistingData(Map<String, dynamic> data) {
    final assessmentData = data['data'] ?? data;
    setState(() {
      _selectedAnamnese = _parseIntValue(assessmentData, 'anamnese');
      _anamneseKommentar.text = assessmentData['anamnese_kommentar']?.toString() ?? '';

      // Initialize answers safely
      _answers.keys.forEach((key) {
        if (assessmentData.containsKey(key)) {
          final value = assessmentData[key];
          if (value != null) {
            final strValue = value.toString().toLowerCase();
            _answers[key] = strValue == '1' || strValue == 'true';
          }
        }
      });
    });
  }

  // Load assessment data asynchronously
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

  // Parse integer value from data map
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
  Widget buildAssessmentContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_lastAssessmentData.isNotEmpty) ...[
            buildLastAssessment(),
            const SizedBox(height: 24),
            const Divider(),
          ],
          const SizedBox(height: 16),
          _buildAnamneseSection(),
          const SizedBox(height: 16),
          _buildQuestionsSection(),
          const SizedBox(height: 16),
          _buildScoreSection(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: saveAssessment,
            child: const Text('Assessment Speichern'),
          ),
        ],
      ),
    );
  }

  // Build the section for information source selection
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
    );
  }

  // Build the section for ISAR questions
  Widget _buildQuestionsSection() {
    return Column(
      children: questions.map((question) => 
        _buildQuestionSection(
          question['title'],
          question['text'],
          question['key'],
        ),
      ).toList(),
    );
  }

  // Build individual question section
  Widget _buildQuestionSection(String title, String text, String key) {
    final questionData = questions.firstWhere((q) => q['key'] == key);
    final helpText = questionData['help']?.toString() ?? '';
    
    return buildButtonSection(
      title,
      [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            Text(
              questionData['text'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Interviewer help text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      helpText,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Answer buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('JA'),
                  selected: _answers[key] == true,
                  onSelected: (bool selected) {
                    setState(() => _answers[key] = selected ? true : null);
                  },
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('NEIN'),
                  selected: _answers[key] == false,
                  onSelected: (bool selected) {
                    setState(() => _answers[key] = selected ? false : null);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
      '', // Empty info text since we're handling it in the question section
    );
  }

  // Build the section displaying the ISAR score
  Widget _buildScoreSection() {
    final score = isarScore;
    return buildButtonSection(
      'ISAR Score',
      [
        Text(
          'Gesamtscore: $score/6',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (score < 2) ...[
          const SizedBox(height: 8),
          const Text(
            'Hinweis: Einschlusskriterium Studie nicht erfüllt.',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ],
      'Der Score wird automatisch aus den Antworten berechnet.',
    );
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

  // Validate the form before saving
  bool validateForm() {
    if (_selectedAnamnese == null) {
      showError('Bitte wählen Sie eine Informationsquelle aus.');
      return false;
    }

    if (_answers.values.any((value) => value == null)) {
      showError('Bitte beantworten Sie alle Fragen.');
      return false;
    }

    return true;
  }

  @override
  Future<void> saveAssessment() async {
    if (!validateForm()) return;

    try {
      final score = isarScore;
      final Map<String, String> data = {
        'anamnese': _selectedAnamnese.toString(),
        'anamnese_kommentar': _anamneseKommentar.text,
        'isar_score': score.toString(),
      };

      // Add answers safely
      _answers.forEach((key, value) {
        data[key] = (value ?? false).toString();
      });

      final result = await ApiService.saveAssessment(
        widget.patientId,
        assessmentName,
        data,
      );
      
      if (mounted) {
        final message = score < 2 
          ? 'Assessment gespeichert. Hinweis: Einschlusskriterium Studie nicht erfüllt.'
          : 'Assessment gespeichert';
          
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? message),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      showError('Fehler beim Speichern: $e');
    }
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    super.dispose();
  }
}
