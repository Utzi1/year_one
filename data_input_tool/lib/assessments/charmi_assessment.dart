import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

/// The CHARMI Assessment evaluates patient mobility levels.
/// It uses a 0-11 point scale to assess:
/// * Bed mobility
/// * Sitting balance
/// * Transfers
/// * Walking ability
/// * Stair climbing
/// * Wheelchair use (when applicable)
///
/// Scores indicate progressive levels of mobility:
/// 0 = Complete immobility
/// 11 = Independent wheelchair mobility or full mobility

/// CHARMI Assessment widget providing structured mobility evaluation.
/// Extends base assessment to maintain consistent behavior across assessments.
class CharmiAssessment extends BaseAssessment {
  const CharmiAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<CharmiAssessment> createState() => _CharmiAssessmentState();
}

/// State management for CHARMI mobility assessment.
/// Handles mobility scoring and progression tracking.
class _CharmiAssessmentState extends BaseAssessmentState<CharmiAssessment> {
  // Form state
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  int? _selectedMobilityScore;
  final TextEditingController _commentController = TextEditingController();

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
  String get assessmentName => 'CHARMI Assessment';

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
    if (_selectedAnamnese == null || _selectedMobilityScore == null) {
      showError('Bitte füllen Sie alle erforderlichen Felder aus.');
      return false;
    }
    return true;
  }

  Map<String, String> _prepareDataForSave() {
    return {
      'anamnese': _selectedAnamnese.toString(),
      'anamnese_kommentar': _anamneseKommentar.text,
      'mobility_score': _selectedMobilityScore.toString(),
      'comment': _commentController.text,
    };
  }

  @override
  Widget buildAssessmentContent() {
    return Column(
      children: [
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildMobilitySection(),
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

  Widget _buildMobilitySection() {
    return buildButtonSection(
      'Mobilität',
      [
        ...mobilityInfo.entries.map((entry) => RadioListTile<int>(
          title: Text(entry.value),
          value: entry.key,
          groupValue: _selectedMobilityScore,
          onChanged: (value) => setState(() => _selectedMobilityScore = value),
        )),
        const SizedBox(height: 16),
        TextField(
          controller: _commentController,
          decoration: const InputDecoration(
            labelText: 'Kommentar',
            border: OutlineInputBorder(),
            hintText: 'Zusätzliche Informationen zur Mobilität',
          ),
          maxLines: 3,
        ),
      ],
      'Bewerten Sie die maximale Mobilität in den letzten 24 Stunden',
      isAnswered: _selectedMobilityScore != null,
    );
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    _commentController.dispose();
    super.dispose();
  }
}
