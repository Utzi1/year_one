import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

/// The Pain Assessment 3-Day Post-Op captures pain levels shortly after surgery.
/// 
/// This follow-up assessment:
/// * Tracks pain intensity during the early post-operative period
/// * Compares with pre-operative baseline pain levels
/// * Helps evaluate the effectiveness of post-operative pain management
/// * Identifies patients requiring improved analgesia
///
/// Pain is scored on the Numeric Rating Scale (NRS):
/// * 0 = No pain
/// * 1-3 = Mild pain
/// * 4-6 = Moderate pain 
/// * 7-10 = Severe pain
 
class Schmerz3DayAssessment extends BaseAssessment {
  const Schmerz3DayAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<Schmerz3DayAssessment> createState() => _Schmerz3DayAssessmentState();
}

class _Schmerz3DayAssessmentState extends BaseAssessmentState<Schmerz3DayAssessment> {
  // Form state
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  int? _painScore;
  
  // Initial assessment data for comparison
  Map<String, dynamic> _initialAssessmentData = {};

  final Map<int, String> anamneseInfo = {
    0: 'Eigenanamnese',
    1: 'Fremdanamnese',
    2: 'Aktenanamnese',
    3: 'Auskunft verweigert',
    4: 'keine Auskunft möglich',
  };

  final Map<int, String> painScaleInfo = {
    0: 'Kein Schmerz',
    1: 'Sehr leichter Schmerz',
    2: 'Leichter Schmerz',
    3: 'Mäßiger Schmerz',
    4: 'Mäßig starker Schmerz',
    5: 'Mittlerer Schmerz',
    6: 'Starker Schmerz',
    7: 'Sehr starker Schmerz',
    8: 'Stärkster Schmerz',
    9: 'Unerträglicher Schmerz',
    10: 'Stärkster vorstellbarer Schmerz',
  };

  @override
  String get assessmentName => 'Schmerz am 3. Tag';

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
      final result = await ApiService.getLastAssessment(widget.patientId, 'Schmerz Assessment');
      if (result.isNotEmpty && result['data'] != null) {
        setState(() {
          _initialAssessmentData = result['data'];
        });
      }
    } catch (e) {
      // Silently handle error - initial assessment may not exist
      print('Could not load initial pain assessment: $e');
    }
  }

  void _initializeFromData(Map<String, dynamic> data) {
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
  
  int? _getInitialPainScore() {
    if (_initialAssessmentData.isEmpty) return null;
    return _parseIntValue(_initialAssessmentData, 'pain_score');
  }
  
  String _getPainChangeText() {
    final initialScore = _getInitialPainScore();
    
    if (initialScore == null || _painScore == null) {
      return 'Keine präoperativen Vergleichsdaten verfügbar';
    }
    
    final difference = _painScore! - initialScore;
    if (difference > 0) {
      return 'Schmerzzunahme um $difference Punkte seit präoperativer Erhebung';
    } else if (difference < 0) {
      return 'Schmerzabnahme um ${-difference} Punkte seit präoperativer Erhebung';
    } else {
      return 'Keine Veränderung der Schmerzintensität seit präoperativer Erhebung';
    }
  }

  String _getPainStatusText() {
    if (_painScore == null) return '';
    
    if (_painScore! <= 3) {
      return 'Leichte Schmerzen - Schmerzmanagement ausreichend';
    } else if (_painScore! <= 5) {
      return 'Mäßige Schmerzen - Schmerzmanagement überprüfen';
    } else {
      return 'Starke Schmerzen - Schmerzmanagement optimieren!';
    }
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
        {
          'anamnese': _selectedAnamnese.toString(),
          'anamnese_kommentar': _anamneseKommentar.text,
          'pain_score': _painScore?.toString() ?? 'None',
          'initial_score': _getInitialPainScore()?.toString() ?? 'None',
          'pain_change': _getPainChangeText(),
          'post_op_day': '3',
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

  bool _validateForm() {
    if (_selectedAnamnese == null || _painScore == null) {
      showError('Bitte füllen Sie alle erforderlichen Felder aus.');
      return false;
    }
    return true;
  }

  @override
  Widget buildAssessmentContent() {
    return Column(
      children: [
        _buildPostOpNotice(),
        const SizedBox(height: 16),
        _buildInitialPainSection(),
        const SizedBox(height: 16),
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildPainScoreSection(),
        const SizedBox(height: 16),
        _buildPainComparisonSection(),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: saveAssessment,
          child: const Text('Assessment Speichern'),
        ),
      ],
    );
  }
  
  Widget _buildPostOpNotice() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.medical_services, color: Colors.amber.shade700),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Tag 3 nach Operation: Beurteilen Sie die aktuellen Schmerzen des Patienten.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInitialPainSection() {
    final initialScore = _getInitialPainScore();
    
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
                'Kein präoperatives Schmerz-Assessment gefunden. Vergleichswerte sind nicht verfügbar.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
    
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
                  'Präoperative Schmerzen:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Schmerzstärke: $initialScore/10'),
                Text(
                  'Beschreibung: ${painScaleInfo[initialScore]}',
                  style: const TextStyle(fontStyle: FontStyle.italic)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPainComparisonSection() {
    final initialScore = _getInitialPainScore();
    
    if (initialScore == null || _painScore == null) {
      return const SizedBox.shrink();
    }
    
    final difference = _painScore! - initialScore;
    Color color;
    IconData icon;
    
    // For pain, lower scores are better!
    if (difference < 0) {
      color = Colors.green;
      icon = Icons.arrow_downward;
    } else if (difference > 0) {
      // After surgery, increased pain is expected
      color = difference <= 3 ? Colors.orange : Colors.red;
      icon = Icons.arrow_upward;
    } else {
      color = Colors.blue;
      icon = Icons.compare_arrows;
    }
    
    return buildButtonSection(
      'Schmerzveränderung nach 3 Tagen',
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Präoperativ: $initialScore',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 16),
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              'Tag 3: ${_painScore}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _getPainChangeText(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getPainStatusText(),
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: _painScore! <= 3 ? Colors.green : (_painScore! <= 5 ? Colors.orange : Colors.red),
          ),
        ),
      ],
      'Vergleich zum präoperativen Assessment. Nach der Operation sind erhöhte Schmerzen zunächst normal, sollten aber adäquat behandelt werden.',
      isAnswered: true,
    );
  }

  Widget _buildAnamneseSection() {
    return buildButtonSection(
      'Informationsquelle (Tag 3 nach OP)',
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

  Widget _buildPainScoreSection() {
    return buildButtonSection(
      'Schmerzskala (NRS) am 3. postoperativen Tag',
      [
        const Text(
          'Im Folgenden möchte ich Sie zu ihren aktuellen Schmerzen nach der Operation befragen. '
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
          activeColor: _getPainColor(entry.key),
        )),
      ],
      'Bitte wählen Sie einen Wert zwischen 0 und 10.',
      isAnswered: _painScore != null,
    );
  }
  
  // Helper for coloring pain scores
  Color _getPainColor(int score) {
    if (score <= 3) {
      return Colors.green;
    } else if (score <= 6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    super.dispose();
  }
}
