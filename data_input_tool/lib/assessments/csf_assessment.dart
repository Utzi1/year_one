import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

/// The Clinical Frailty Scale (CSF) Assessment
/// Evaluates overall fitness and frailty in elderly patients.
/// Uses a 9-point scale ranging from very fit to terminally ill.
///
/// Key Categories:
/// 1. Very Fit
/// 2. Well
/// 3. Managing Well
/// 4. Vulnerable
/// 5. Mildly Frail
/// 6. Moderately Frail
/// 7. Severely Frail
/// 8. Very Severely Frail
/// 9. Terminally Ill
///
/// Each level has specific criteria and implications for care.

/// CSF Assessment widget for evaluating patient frailty.
/// Provides structured frailty evaluation using standardized scale.
class CSFAssessment extends BaseAssessment {
  const CSFAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<CSFAssessment> createState() => _CSFAssessmentState();
}

/// State management for Clinical Frailty Scale Assessment.
/// Handles frailty scoring and detailed descriptions.
class _CSFAssessmentState extends BaseAssessmentState<CSFAssessment> {
  // Form state
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  int? _frailtyScore;
  final TextEditingController _commentController = TextEditingController();

  static const Map<int, String> _anamneseOptions = {
    0: 'Eigenanamnese',
    1: 'Fremdanamnese',
    2: 'Aktenanamnese',
    3: 'Auskunft verweigert',
    4: 'keine Auskunft möglich',
  };

  /// Detailed frailty descriptions for each score level.
  /// Includes comprehensive criteria for accurate assessment.
  static const List<FrailtyOption> _frailtyOptions = [
    FrailtyOption(
      value: 1,
      description: 'Sehr fit',
      details: 'Personen in dieser Kategorie sind robust, aktiv, voller Energie und motiviert. Sie trainieren üblicherweise regelmäßig und sind mit die Fittesten innerhalb ihrer Altersgruppe.',
    ),
    FrailtyOption(
      value: 2,
      description: 'Durchschnittlich aktiv',
      details: 'Personen in dieser Kategorie zeigen keine aktiven Krankheitssymptome, sind aber nicht so fit wie Personen in Kategorie 1. Sie sind durchschnittlich aktiv oder zeitweilig sehr aktiv, z.B. saisonal.',
    ),
    FrailtyOption(
      value: 3,
      description: 'Gut zurechtkommend',
      details: 'Die Krankheitssymptome dieser Personengruppe sind gut kontrolliert, aber außer Gehen im Rahmen von Alltagsaktivitäten bewegen sie sich nicht regelmäßig.',
    ),
    FrailtyOption(
      value: 4,
      description: 'Vulnerabel',
      details: 'Auch wenn sie nicht auf externe Hilfen im Alltag angewiesen sind, sind Personen in dieser Kategorie aufgrund ihrer Krankheitssymptome oft in ihren Aktivitäten eingeschränkt. Häufig klagen sie über Tagesmüdigkeit und/oder berichten, dass Alltagsaktivitäten mehr Zeit benötigen.',
    ),
    FrailtyOption(
      value: 5,
      description: 'Geringgradig frail',
      details: 'Personen in dieser Kategorie sind offensichtlich in ihren Aktivitäten verlangsamt und benötigen Hilfe bei anspruchsvollen Alltagsaktivitäten, wie finanziellen Angelegenheiten, Transport, schwerer Hausarbeit und im Umgang mit Medikamenten. Geringgradige Frailty beeinträchtigt das selbständige Einkaufen, Spazierengehen sowie die Essenszubereitung und Haushaltstätigkeiten.',
    ),
    FrailtyOption(
      value: 6,
      description: 'Mittelgradig frail',
      details: 'Personen in dieser Kategorie benötigen Hilfe bei allen außerhäuslichen Tätigkeiten und bei der Haushaltsführung. Im Haus haben sie oft Schwierigkeiten mit Treppen, benötigen Hilfe beim Baden/Duschen und eventuell Anleitung oder minimale Unterstützung beim Ankleiden.',
    ),
    FrailtyOption(
      value: 7,
      description: 'Ausgeprägt frail',
      details: 'Personen in dieser Kategorie sind aufgrund körperlicher oder kognitiver Einschränkungen bei der Körperpflege komplett auf externe Hilfe angewiesen. Dennoch sind sie gesundheitlich stabil. Die Wahrscheinlichkeit, dass sie innerhalb der nächsten 6 Monate sterben, ist gering.',
    ),
    FrailtyOption(
      value: 8,
      description: 'Extrem frail',
      details: 'Komplett von Unterstützung abhängig und sich ihrem Lebensende nähernd. Oft erholen sich Personen in dieser Kategorie auch von leichten Erkrankungen nicht.',
    ),
    FrailtyOption(
      value: 9,
      description: 'Terminal erkrankt',
      details: 'Personen in dieser Kategorie haben eine Lebenserwartung <6 Monate. Die Kategorie bezieht sich auf Personen, die anderweitig keine Zeichen von Frailty aufweisen.',
    ),
  ];

  @override
  String get assessmentName => 'CSF Assessment';

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
      _frailtyScore = _parseIntValue(assessmentData, 'frailty_score');
      _commentController.text = assessmentData['comment']?.toString() ?? '';
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
    if (_selectedAnamnese == null || _frailtyScore == null) {
      showError('Bitte füllen Sie alle Felder aus.');
      return false;
    }
    return true;
  }

  Map<String, String> _prepareDataForSave() {
    return {
      'anamnese': _selectedAnamnese.toString(),
      'anamnese_kommentar': _anamneseKommentar.text,
      'frailty_score': _frailtyScore.toString(),
      'comment': _commentController.text,
    };
  }

  @override
  Widget buildAssessmentContent() {
    return Column(
      children: [
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildFrailtySection(),
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

  Widget _buildFrailtySection() {
    return buildButtonSection(
      'Frailty Score',
      [
        ..._frailtyOptions.map((option) => RadioListTile<int>(
          title: Text('${option.value} - ${option.description}'),
          subtitle: Text(option.details),
          value: option.value,
          groupValue: _frailtyScore,
          onChanged: (value) => setState(() => _frailtyScore = value),
        )),
        const SizedBox(height: 16),
        TextField(
          controller: _commentController,
          decoration: const InputDecoration(
            labelText: 'Kommentar',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
      'Bitte schätzen Sie den Grad der Gebrechlichkeit/Frailty ein.',
      isAnswered: _frailtyScore != null,
    );
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    _commentController.dispose();
    super.dispose();
  }
}

class FrailtyOption {
  final int value;
  final String description;
  final String details;

  const FrailtyOption({
    required this.value,
    required this.description,
    required this.details,
  });
}
