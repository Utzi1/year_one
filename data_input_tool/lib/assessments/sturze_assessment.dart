import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

/// The Falls Assessment evaluates a patient's fall history and consciousness.
/// Collects information about:
/// * Fall frequency in the last three months
/// * Loss of consciousness during falls
/// 
/// Scoring:
/// * Fall frequency: 0 (none) to 2 (twice)
/// * Additional options for unknown/refused responses
/// * Consciousness tracking for fall-related injuries

class SturzeAssessment extends BaseAssessment {
  const SturzeAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<SturzeAssessment> createState() => _SturzeAssessmentState();
}

class _SturzeAssessmentState extends BaseAssessmentState<SturzeAssessment> {
  // Form state
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  int? _selectedFallFrequency;
  int? _selectedUnconsciousness;

  static const Map<int, String> _anamneseOptions = {
    0: 'Durchführung mit Teilnehmer:in',
    1: 'Krankenhausakte',
    2: 'Teilnehmer:in verweigert',
    3: 'Keine Durchführung möglich',
  };

  static const Map<int, String> _fallFrequencyInfo = {
    0: 'Kein Mal',
    1: 'Einmal',
    2: 'Zweimal',
    3: 'Ich weiß es nicht',
    4: 'Teilnehmer:in verweigert Antwort',
    5: 'Teilnehmer:in kann nicht antworten',
  };

  static const Map<int, String> _unconsciousnessInfo = {
    0: 'Ja',
    1: 'Nein',
    2: 'Ich weiß es nicht',
    3: 'Teilnehmer:in verweigert Antwort',
    4: 'Teilnehmer:in kann nicht antworten',
  };

  @override
  String get assessmentName => 'Stürze Assessment';

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
      _selectedFallFrequency = _parseIntValue(assessmentData, 'fall_frequency');
      _selectedUnconsciousness = _parseIntValue(assessmentData, 'unconsciousness');
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
    if (_selectedAnamnese == null) {
      showError('Bitte wählen Sie eine Assessmentquelle aus.');
      return false;
    }
    return true;
  }

  Map<String, String> _prepareDataForSave() {
    return {
      'anamnese': _selectedAnamnese.toString(),
      'anamnese_kommentar': _anamneseKommentar.text,
      'fall_frequency': _selectedFallFrequency?.toString() ?? 'None',
      'unconsciousness': _selectedUnconsciousness?.toString() ?? 'None',
    };
  }

  @override
  Widget buildAssessmentContent() {
    return Column(
      children: [
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildFallFrequencySection(),
        const SizedBox(height: 16),
        _buildUnconsciousnessSection(),
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
      'Assessmentquelle',
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
            labelText: 'Kommentar zur Assessmentquelle',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
      'Bitte wählen Sie die Quelle der Informationen aus.',
      isAnswered: _selectedAnamnese != null,
    );
  }

  Widget _buildFallFrequencySection() {
    return buildButtonSection(
      'Sturzfrequenz',
      [
        buildActionButtonField<int>(
          value: _selectedFallFrequency,
          items: _fallFrequencyInfo.keys.toList(),
          onChanged: (value) => setState(() => _selectedFallFrequency = value),
          itemInfo: _fallFrequencyInfo,
        ),
      ],
      'Wie oft sind Sie in den letzten drei Monaten gestürzt?',
      isAnswered: _selectedFallFrequency != null,
    );
  }

  Widget _buildUnconsciousnessSection() {
    return buildButtonSection(
      'Bewusstlosigkeit',
      [
        buildActionButtonField<int>(
          value: _selectedUnconsciousness,
          items: _unconsciousnessInfo.keys.toList(),
          onChanged: (value) => setState(() => _selectedUnconsciousness = value),
          itemInfo: _unconsciousnessInfo,
        ),
      ],
      'Waren Sie dabei schon einmal bewusstlos?',
      isAnswered: _selectedUnconsciousness != null,
    );
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    super.dispose();
  }
}
