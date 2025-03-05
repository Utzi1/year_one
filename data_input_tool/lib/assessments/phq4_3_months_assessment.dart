import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

/// The PHQ-4 3-Month Follow-up Assessment tracks changes in depression and anxiety symptoms.
/// 
/// This follow-up assessment:
/// * Evaluates changes in psychological symptoms after 3 months
/// * Compares with baseline mental health status
/// * Helps identify persistent or new-onset depression/anxiety
/// * Guides decisions about continued mental health interventions
///
/// Scoring:
/// * Depression subscore: Sum of first two items (0-6)
/// * Anxiety subscore: Sum of last two items (0-6)
/// * Total score: Sum of all items (0-12)
/// * Higher scores indicate greater symptom severity

class PHQ4ThreeMonthAssessment extends BaseAssessment {
  const PHQ4ThreeMonthAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<PHQ4ThreeMonthAssessment> createState() => _PHQ4ThreeMonthAssessmentState();
}

class _PHQ4ThreeMonthAssessmentState extends BaseAssessmentState<PHQ4ThreeMonthAssessment> {
  // Form state
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  int? _interestScore;
  int? _depressionScore;
  int? _anxietyScore;
  int? _worryScore;
  
  // Initial assessment data for comparison
  Map<String, dynamic> _initialAssessmentData = {};

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
  String get assessmentName => 'PHQ-4 3-Month Assessment';

  @override
  void initState() {
    super.initState();
    if (widget.assessmentData.isNotEmpty) {
      _initializeFromData(widget.assessmentData);
    }
    _loadInitialAssessment();
  }
  
  Future<void> _loadInitialAssessment() async {
    try {
      final result = await ApiService.getLastAssessment(widget.patientId, 'PHQ-4 Assessment');
      if (result.isNotEmpty && result['data'] != null) {
        setState(() {
          _initialAssessmentData = result['data'];
        });
      }
    } catch (e) {
      // Silently handle error - initial assessment may not exist
      print('Could not load initial PHQ-4 assessment: $e');
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
  
  // Helper methods for getting initial assessment values
  int? _getInitialItemValue(String key) {
    if (_initialAssessmentData.isEmpty) return null;
    return _parseIntValue(_initialAssessmentData, key);
  }
  
  int? _getInitialTotalScore() {
    if (_initialAssessmentData.isEmpty) return null;
    
    final interestScore = _getInitialItemValue('interest_score');
    final depressionScore = _getInitialItemValue('depression_score');
    final anxietyScore = _getInitialItemValue('anxiety_score');
    final worryScore = _getInitialItemValue('worry_score');
    
    if (interestScore == null || depressionScore == null || 
        anxietyScore == null || worryScore == null) {
      return null;
    }
    
    return interestScore + depressionScore + anxietyScore + worryScore;
  }
  
  int? _getInitialDepressionScore() {
    if (_initialAssessmentData.isEmpty) return null;
    
    final interestScore = _getInitialItemValue('interest_score');
    final depressionScore = _getInitialItemValue('depression_score');
    
    if (interestScore == null || depressionScore == null) {
      return null;
    }
    
    return interestScore + depressionScore;
  }
  
  int? _getInitialAnxietyScore() {
    if (_initialAssessmentData.isEmpty) return null;
    
    final anxietyScore = _getInitialItemValue('anxiety_score');
    final worryScore = _getInitialItemValue('worry_score');
    
    if (anxietyScore == null || worryScore == null) {
      return null;
    }
    
    return anxietyScore + worryScore;
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
      'initial_total_score': _getInitialTotalScore()?.toString() ?? 'None',
      'initial_depression_score': _getInitialDepressionScore()?.toString() ?? 'None',
      'initial_anxiety_score': _getInitialAnxietyScore()?.toString() ?? 'None',
      'follow_up_month': '3',
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
        _buildInitialScoreSection(),
        const SizedBox(height: 16),
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildQuestionsSection(),
        const SizedBox(height: 16),
        _buildScoresSection(),
        const SizedBox(height: 16),
        _buildScoreComparisonSection(),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: saveAssessment,
          child: const Text('Assessment Speichern'),
        ),
      ],
    );
  }
  
  Widget _buildInitialScoreSection() {
    final initialScore = _getInitialTotalScore();
    
    if (initialScore == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Kein vorheriges PHQ-4 Assessment gefunden. Vergleichswerte sind nicht verfügbar.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
    
    final initialDepressionScore = _getInitialDepressionScore() ?? 0;
    final initialAnxietyScore = _getInitialAnxietyScore() ?? 0;
    
    String depressionRating = initialDepressionScore >= 3 ? 'Auffällig' : 'Unauffällig';
    String anxietyRating = initialAnxietyScore >= 3 ? 'Auffällig' : 'Unauffällig';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ergebnis des ersten Assessments:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('PHQ-4 Gesamtscore: $initialScore/12'),
                Text('Depression: $initialDepressionScore/6 ($depressionRating)'),
                Text('Angst: $initialAnxietyScore/6 ($anxietyRating)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScoreComparisonSection() {
    final initialTotalScore = _getInitialTotalScore();
    final currentTotalScore = _calculateTotalScore();
    
    if (initialTotalScore == null) {
      return const SizedBox.shrink();
    }
    
    final initialDepressionScore = _getInitialDepressionScore() ?? 0;
    final initialAnxietyScore = _getInitialAnxietyScore() ?? 0;
    
    final currentDepressionScore = _calculateDepressionScore();
    final currentAnxietyScore = _calculateAnxietyScore();
    
    final totalDifference = currentTotalScore - initialTotalScore;
    final depressionDifference = currentDepressionScore - initialDepressionScore;
    final anxietyDifference = currentAnxietyScore - initialAnxietyScore;
    
    Color getTrendColor(int difference) {
      // For mental health scores, lower is better!
      if (difference < 0) return Colors.green;
      if (difference > 0) return Colors.red;
      return Colors.blue;
    }
    
    IconData getTrendIcon(int difference) {
      // For mental health scores, lower is better!
      if (difference < 0) return Icons.arrow_downward;
      if (difference > 0) return Icons.arrow_upward;
      return Icons.compare_arrows;
    }
    
    String getTrendText(int difference, String domain) {
      // For mental health scores, lower is better!
      if (difference < 0) {
        return '${-difference} Punkte Verbesserung ($domain)';
      }
      if (difference > 0) {
        return '$difference Punkte Verschlechterung ($domain)';
      }
      return 'Keine Veränderung ($domain)';
    }
    
    return buildButtonSection(
      'Vergleich nach 3 Monaten',
      [
        _buildComparisonRow(
          'Gesamt:',
          initialTotalScore,
          currentTotalScore,
          getTrendColor(totalDifference),
          getTrendIcon(totalDifference)
        ),
        const SizedBox(height: 8),
        _buildComparisonRow(
          'Depression:',
          initialDepressionScore,
          currentDepressionScore,
          getTrendColor(depressionDifference),
          getTrendIcon(depressionDifference)
        ),
        const SizedBox(height: 8),
        _buildComparisonRow(
          'Angst:',
          initialAnxietyScore,
          currentAnxietyScore,
          getTrendColor(anxietyDifference),
          getTrendIcon(anxietyDifference)
        ),
        const SizedBox(height: 16),
        Text(
          getTrendText(totalDifference, 'Gesamt'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: getTrendColor(totalDifference),
          ),
        ),
      ],
      'Für psychische Symptome gilt: Niedrigere Werte zeigen eine Verbesserung an.',
      isAnswered: true,
    );
  }
  
  Widget _buildComparisonRow(String label, int initialValue, int currentValue, Color color, IconData icon) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Text('Initial: $initialValue', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text('Aktuell: $currentValue', 
          style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildAnamneseSection() {
    return buildButtonSection(
      'Informationsquelle (3-Monats-Kontrolle)',
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
    final initialInterestScore = _getInitialItemValue('interest_score');
    final initialDepressionScore = _getInitialItemValue('depression_score');
    final initialAnxietyScore = _getInitialItemValue('anxiety_score');
    final initialWorryScore = _getInitialItemValue('worry_score');
    
    return buildButtonSection(
      'PHQ-4 Fragebogen (3-Monats-Kontrolle)',
      [
        const Text(
          'Wie oft fühlten Sie sich im Verlauf der letzten 2 Wochen durch '
          'die folgenden Beschwerden beeinträchtigt?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildQuestionFieldWithComparison(
          'Wenig Interesse oder Freude an Ihren Tätigkeiten',
          _interestScore,
          initialInterestScore,
          (value) => setState(() => _interestScore = value),
        ),
        _buildQuestionFieldWithComparison(
          'Niedergeschlagenheit, Schwermut oder Hoffnungslosigkeit',
          _depressionScore,
          initialDepressionScore,
          (value) => setState(() => _depressionScore = value),
        ),
        _buildQuestionFieldWithComparison(
          'Nervosität, Ängstlichkeit oder Anspannung',
          _anxietyScore,
          initialAnxietyScore,
          (value) => setState(() => _anxietyScore = value),
        ),
        _buildQuestionFieldWithComparison(
          'Nicht in der Lage sein, Sorgen zu stoppen oder zu kontrollieren',
          _worryScore,
          initialWorryScore,
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

  Widget _buildQuestionFieldWithComparison(
    String question, 
    int? currentValue, 
    int? previousValue,
    ValueChanged<int?> onChanged
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(question),
        ),
        if (previousValue != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text('Vorheriger Wert: $previousValue (${scoreInfo[previousValue]})'),
            ),
          ),
        buildActionButtonField<int>(
          value: currentValue,
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

    final depressionAlert = depressionScore >= 3;
    final anxietyAlert = anxietyScore >= 3;

    return buildButtonSection(
      'Auswertung (3-Monats-Kontrolle)',
      [
        Text('Gesamtpunktzahl: $totalScore/12',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Depression Subscore: $depressionScore/6',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: depressionAlert ? Colors.red : Colors.green,
                ),
              ),
            ),
            if (depressionAlert)
              Icon(Icons.warning_amber_rounded, color: Colors.red),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                'Angst Subscore: $anxietyScore/6',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: anxietyAlert ? Colors.red : Colors.green,
                ),
              ),
            ),
            if (anxietyAlert)
              Icon(Icons.warning_amber_rounded, color: Colors.red),
          ],
        ),
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
