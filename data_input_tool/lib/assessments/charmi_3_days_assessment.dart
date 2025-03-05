import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

/// The CHARMI 3-Day Post-Op Assessment measures early mobility status after surgery.
/// 
/// This follow-up assessment:
/// * Tracks mobility changes immediately after surgical intervention
/// * Compares with pre-operative baseline mobility status
/// * Helps in early identification of mobility issues requiring intervention
/// * Assists in planning appropriate early mobility strategies
///
/// Scores indicate progressive levels of mobility:
/// 0 = Complete immobility
/// 11 = Independent wheelchair mobility or full mobility

class Charmi3DayAssessment extends BaseAssessment {
  const Charmi3DayAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<Charmi3DayAssessment> createState() => _Charmi3DayAssessmentState();
}

class _Charmi3DayAssessmentState extends BaseAssessmentState<Charmi3DayAssessment> {
  // Form state
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  int? _selectedMobilityScore;
  final TextEditingController _commentController = TextEditingController();
  
  // Initial assessment data for comparison
  Map<String, dynamic> _initialAssessmentData = {};

  /// Static mobility information mapping scores to detailed descriptions.
  /// Each level represents a distinct mobility capability.
  static const Map<int, String> _anamneseOptions = {
    0: 'Eigenanamnese',
    1: 'Fremdanamnese',
    2: 'Aktenanamnese',
    3: 'Auskunft verweigert',
    4: 'keine Auskunft möglich',
  };

  static const Map<int, String> mobilityInfo = {
    0: 'Vollständige Immobilität',
    1: 'Transfers im Bett - Von Rückenlage in Seitenlage',
    2: 'Sitz an der Bettkante - ≥ 30 s freier Sitz, Transfer darf unterstützt sein',
    3: 'Transfer an die Bettkante - Transfer in Sitzposition',
    4: 'Transfer Bett in Stuhl',
    5: 'Aufstehen - Aus Sitz- in Standposition und ≥ 30 s halten',
    6: 'Gehen bis 10 m - Auf Zimmerebene',
    7: 'Gehen 10 bis 50 m - Auf Stations-/Wohnungsebene',
    8: 'Gehen über 50 m - Mit reduzierter Gehstrecke oder Ganggeschwindigkeit',
    9: 'Treppensteigen - ≥ eine Etage',
    10: 'Volle Mobilität - Gehstrecke ≥ 1 km',
    11: 'Rollstuhlmobilität - Selbstständige Rollstuhlbenutzung',
  };

  @override
  String get assessmentName => 'CHARMI 3-Day Assessment';

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
      final result = await ApiService.getLastAssessment(widget.patientId, 'CHARMI Assessment');
      if (result.isNotEmpty && result['data'] != null) {
        setState(() {
          _initialAssessmentData = result['data'];
        });
      }
    } catch (e) {
      // Silently handle error - initial assessment may not exist
      print('Could not load initial CHARMI assessment: $e');
    }
  }

  void _initializeFromData(Map<String, dynamic> data) {
    final assessmentData = data['data'] ?? data;
    setState(() {
      _selectedAnamnese = _parseIntValue(assessmentData, 'anamnese');
      _anamneseKommentar.text = assessmentData['anamnese_kommentar']?.toString() ?? '';
      _selectedMobilityScore = _parseIntValue(assessmentData, 'mobility_score');
      _commentController.text = assessmentData['comment']?.toString() ?? '';
    });
  }

  int? _parseIntValue(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) {
      final value = data[key];
      if (value is int) return value;
      if (value is String && value.toLowerCase() != 'null') {
        return int.tryParse(value);
      }
    }
    return null;
  }
  
  int? _getInitialMobilityScore() {
    if (_initialAssessmentData.isEmpty) return null;
    return _parseIntValue(_initialAssessmentData, 'mobility_score');
  }
  
  String _getMobilityChangeText() {
    final initialScore = _getInitialMobilityScore();
    
    if (initialScore == null || _selectedMobilityScore == null) {
      return 'Keine präoperativen Vergleichsdaten verfügbar';
    }
    
    final difference = _selectedMobilityScore! - initialScore;
    if (difference > 0) {
      return 'Verbesserung um $difference Mobilitätsstufen';
    } else if (difference < 0) {
      return 'Verringerung um ${-difference} Mobilitätsstufen nach Operation';
    } else {
      return 'Keine Veränderung seit präoperativer Erhebung';
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
          'mobility_score': _selectedMobilityScore.toString(),
          'comment': _commentController.text,
          'initial_score': _getInitialMobilityScore()?.toString() ?? 'None',
          'mobility_change': _getMobilityChangeText(),
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
    if (_selectedAnamnese == null || _selectedMobilityScore == null) {
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
        _buildInitialMobilitySection(),
        const SizedBox(height: 16),
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildMobilitySection(),
        const SizedBox(height: 16),
        _buildMobilityComparisonSection(),
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
              'Tag 3 nach Operation: Beurteilen Sie die aktuelle Mobilität des Patienten.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInitialMobilitySection() {
    final initialScore = _getInitialMobilityScore();
    
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
                'Kein präoperatives CHARMI Assessment gefunden. Vergleichswerte sind nicht verfügbar.',
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
                  'Präoperative Mobilität:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('CHARMI Score: $initialScore'),
                Text('Beschreibung: ${mobilityInfo[initialScore]}', style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMobilityComparisonSection() {
    final initialScore = _getInitialMobilityScore();
    
    if (initialScore == null || _selectedMobilityScore == null) {
      return const SizedBox.shrink();
    }
    
    final difference = _selectedMobilityScore! - initialScore;
    Color color;
    IconData icon;
    String message;
    
    if (difference > 0) {
      color = Colors.green;
      icon = Icons.arrow_upward;
      message = 'Unerwartete Verbesserung nach Operation';
    } else if (difference < 0) {
      // Normal to decline after surgery
      if (difference > -3) {
        color = Colors.orange;
        icon = Icons.arrow_downward;
        message = 'Erwartete Mobilitätsreduktion nach Operation';
      } else {
        color = Colors.red;
        icon = Icons.arrow_downward;
        message = 'Erhebliche Mobilitätseinschränkung nach Operation';
      }
    } else {
      color = Colors.blue;
      icon = Icons.compare_arrows;
      message = 'Keine Veränderung der Mobilität';
    }
    
    return buildButtonSection(
      'Mobilitätsveränderung nach 3 Tagen',
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
              'Tag 3: ${_selectedMobilityScore}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _getMobilityChangeText(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: color,
          ),
        ),
      ],
      'Vergleich zum präoperativen Assessment. Eine Abnahme der Mobilität ist nach Operation zunächst normal.',
      isAnswered: true,
    );
  }

  Widget _buildAnamneseSection() {
    return buildButtonSection(
      'Informationsquelle (Tag 3 nach OP)',
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

  Widget _buildMobilitySection() {
    return buildButtonSection(
      'Mobilität (Tag 3 nach OP)',
      [
        ...mobilityInfo.entries.map((entry) => RadioListTile<int>(
          title: Text(entry.value),
          value: entry.key,
          groupValue: _selectedMobilityScore,
          onChanged: (value) => setState(() => _selectedMobilityScore = value),
          activeColor: _getScoreColor(entry.key),
        )),
        const SizedBox(height: 16),
        TextField(
          controller: _commentController,
          decoration: const InputDecoration(
            labelText: 'Kommentar zur postoperativen Mobilität',
            border: OutlineInputBorder(),
            hintText: 'Besonderheiten, Hilfsmittel, Einschränkungen...',
          ),
          maxLines: 3,
        ),
      ],
      'Bewerten Sie die maximale Mobilität in den letzten 24 Stunden (Tag 3 nach OP)',
      isAnswered: _selectedMobilityScore != null,
    );
  }
  
  // Helper for coloring mobility scores
  Color _getScoreColor(int score) {
    // Early mobilization at day 3 is typically lower than preop
    if (_getInitialMobilityScore() == null) return Colors.blue;
    
    final initialScore = _getInitialMobilityScore()!;
    
    if (score > initialScore) {
      return Colors.green;
    } else if (score < initialScore) {
      return score > 4 ? Colors.orange : Colors.red;
    } else {
      return Colors.blue;
    }
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    _commentController.dispose();
    super.dispose();
  }
}
