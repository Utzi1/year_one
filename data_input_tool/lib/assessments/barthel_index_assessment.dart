import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

/// The Barthel Index Assessment measures daily living activities and mobility.
/// It evaluates ten different areas:
/// * Eating
/// * Transfers (bed to chair and back)
/// * Personal hygiene
/// * Toilet use
/// * Bathing
/// * Walking/Wheelchair use
/// * Stair climbing
/// * Dressing
/// * Bowel control
/// * Bladder control
///
/// Each area is scored with points (0-15), with higher scores indicating greater independence.
/// Maximum total score is 100 points.

/// Barthel Index Assessment widget that extends the base assessment class.
/// Provides structured evaluation of activities of daily living.
class BarthelIndexAssessment extends BaseAssessment {
  const BarthelIndexAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<BarthelIndexAssessment> createState() => _BarthelIndexAssessmentState();
}

/// State management class for the Barthel Index Assessment.
/// Handles data collection, validation, and UI presentation for all ten assessment areas.
class _BarthelIndexAssessmentState extends BaseAssessmentState<BarthelIndexAssessment> {
  // Form state variables for each assessment area
  // Each variable corresponds to a specific activity score
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  int? _selectedEssen;
  int? _selectedAufstehen;
  int? _selectedAufstehenGehen;
  int? _selectedWaschen;
  int? _selectedToilette;
  int? _selectedBaden;
  int? _selectedTreppensteigen;
  int? _selectedKleiden;
  int? _selectedStuhlkontrollen;
  int? _selectedHarnkontrollen;

  @override
  String get assessmentName => 'Barthel Index';

  /// Initializes the assessment with existing data if available.
  /// Data can come from a previous assessment or partial save.
  @override
  void initState() {
    super.initState();
    if (widget.assessmentData.isNotEmpty) {
      _initializeFromData(widget.assessmentData);
    }
  }

  /// Loads assessment data from storage and initializes form fields.
  /// Maps raw data to appropriate form fields and handles data type conversion.
  void _initializeFromData(Map<String, dynamic> data) {
    final assessmentData = data['data'] ?? data;
    setState(() {
      _selectedAnamnese = _parseIntValue(assessmentData, 'anamnese');
      _anamneseKommentar.text = assessmentData['anamnese_kommentar']?.toString() ?? '';
      _selectedEssen = _parseIntValue(assessmentData, 'essen');
      _selectedAufstehen = _parseIntValue(assessmentData, 'aufstehen');
      _selectedAufstehenGehen = _parseIntValue(assessmentData, 'aufstehengehen');
      _selectedWaschen = _parseIntValue(assessmentData, 'waschen');
      _selectedToilette = _parseIntValue(assessmentData, 'toilette');
      _selectedBaden = _parseIntValue(assessmentData, 'baden');
      _selectedTreppensteigen = _parseIntValue(assessmentData, 'treppensteigen');
      _selectedKleiden = _parseIntValue(assessmentData, 'kleiden');
      _selectedStuhlkontrollen = _parseIntValue(assessmentData, 'stuhlkontrollen');
      _selectedHarnkontrollen = _parseIntValue(assessmentData, 'harnkontrollen');
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
      return await ApiService.getBarthelAssessment(widget.patientId);
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

  /// Validates all required fields are filled.
  /// Ensures each assessment area has a valid score before saving.
  /// Returns false if any required field is missing.
  bool _validateForm() {
    if (_selectedAnamnese == null ||
        _selectedEssen == null ||
        _selectedAufstehen == null ||
        _selectedAufstehenGehen == null ||
        _selectedWaschen == null ||
        _selectedToilette == null ||
        _selectedBaden == null ||
        _selectedTreppensteigen == null ||
        _selectedKleiden == null ||
        _selectedStuhlkontrollen == null ||
        _selectedHarnkontrollen == null) {
      showError('Bitte füllen Sie alle Felder aus.');
      return false;
    }
    return true;
  }

  /// Prepares assessment data for saving.
  /// Converts all scores to proper format and includes comments.
  /// Returns a map ready for API submission.
  Map<String, String> _prepareDataForSave() {
    return {
      'anamnese': _selectedAnamnese.toString(),
      'anamnese_kommentar': _anamneseKommentar.text,
      'essen': _selectedEssen.toString(),
      'aufstehen': _selectedAufstehen.toString(),
      'aufstehengehen': _selectedAufstehenGehen.toString(),
      'waschen': _selectedWaschen.toString(),
      'toilette': _selectedToilette.toString(),
      'baden': _selectedBaden.toString(),
      'treppensteigen': _selectedTreppensteigen.toString(),
      'kleiden': _selectedKleiden.toString(),
      'stuhlkontrollen': _selectedStuhlkontrollen.toString(),
      'harnkontrollen': _selectedHarnkontrollen.toString(),
    };
  }

  @override
  Widget buildAssessmentContent() {
    return Column(
      children: [
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildEssenSection(),
        const SizedBox(height: 16),
        _buildAufstehenSection(),
        const SizedBox(height: 16),
        _buildWaschenSection(),
        const SizedBox(height: 16),
        _buildToiletteSection(),
        const SizedBox(height: 16),
        _buildBadenSection(),
        const SizedBox(height: 16),
        _buildTreppensteigenSection(),
        const SizedBox(height: 16),
        _buildKleidenSection(),
        const SizedBox(height: 16),
        _buildStuhlkontrollenSection(),
        const SizedBox(height: 16),
        _buildHarnkontrollenSection(),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: saveAssessment,
          child: const Text('Assessment Speichern'),
        ),
      ],
    );
  }

  /// Builds the section for the Anamnese assessment.
  /// Provides options for selecting the source of information and adding comments.
  Widget _buildAnamneseSection() {
    return buildButtonSection(
      'Informationsquelle',
      [
        buildActionButtonField<int>(
          value: _selectedAnamnese,
          items: const [0, 1, 3, 4, 5],
          onChanged: (value) => setState(() => _selectedAnamnese = value),
          itemInfo: {
            0: 'Eigenanamnese',
            1: 'Fremdanamnese',
            3: 'Aktenanamnese',
            4: 'Auskunft verweigert',
            5: 'keine Auskunft möglich',
          },
        ),
        TextField(
          controller: _anamneseKommentar,
          decoration: const InputDecoration(labelText: 'Anamnese Kommentar'),
        ),
      ],
      'Bitte wählen Sie die Quelle der Informationen aus.',
      isAnswered: _selectedAnamnese != null,
    );
  }

  /// Builds the section for the Essen assessment.
  /// Provides options for selecting the level of independence in eating.
  Widget _buildEssenSection() {
    return buildButtonSection(
      'Essen',
      [
        buildActionButtonField<int>(
          value: _selectedEssen,
          items: const [0, 5, 10],
          onChanged: (value) => setState(() => _selectedEssen = value),
          itemInfo: {
            0: 'Kein selbstständiges Einnehmen',
            5: 'Hilfe bei mundgerechter Vorbereitung',
            10: 'Komplett selbstständig',
          },
        ),
      ],
      '10 = Komplett selbstständig\n5 = Hilfe bei mundgerechter Vorbereitung\n0 = Kein selbstständiges Einnehmen',
      isAnswered: _selectedEssen != null,
    );
  }

  /// Builds the section for the Aufstehen assessment.
  /// Provides options for selecting the level of independence in getting up.
  Widget _buildAufstehenSection() {
    return buildButtonSection(
      'Aufstehen',
      [
        buildActionButtonField<int>(
          value: _selectedAufstehen,
          items: const [0, 5, 10, 15],
          onChanged: (value) => setState(() => _selectedAufstehen = value),
          itemInfo: {
            0: 'Wird faktisch nicht aus dem Bett transferiert',
            5: 'Erhebliche Hilfe',
            10: 'Aufsicht oder geringe Hilfe',
            15: 'Komplett selbstständig',
          },
        ),
      ],
      '15 = Komplett selbstständig\n'
      '10 = Aufsicht oder geringe Hilfe\n'
      '5 = Erhebliche Hilfe\n'
      '0 = Wird nicht aus dem Bett transferiert',
      isAnswered: _selectedAufstehen != null,
    );
  }

  /// Builds the section for the Waschen assessment.
  /// Provides options for selecting the level of independence in washing.
  Widget _buildWaschenSection() {
    return buildButtonSection(
      'Waschen',
      [
        buildActionButtonField<int>(
          value: _selectedWaschen,
          items: const [0, 5],
          onChanged: (value) => setState(() => _selectedWaschen = value),
          itemInfo: {
            0: 'Hilfe bei der Körperpflege erforderlich',
            5: 'Komplett selbstständig',
          },
        ),
      ],
      '5 = Vor Ort komplett selbstständig\n'
      '0 = Benötigt Hilfe bei der Körperpflege',
      isAnswered: _selectedWaschen != null,
    );
  }

  /// Builds the section for the Toilette assessment.
  /// Provides options for selecting the level of independence in toilet use.
  Widget _buildToiletteSection() {
    return buildButtonSection(
      'Toilette',
      [
        buildActionButtonField<int>(
          value: _selectedToilette,
          items: const [0, 5, 10],
          onChanged: (value) => setState(() => _selectedToilette = value),
          itemInfo: {
            0: 'Benutzung weder Toilette noch Toilettenstuhl',
            5: 'Hilfe oder Aufsicht erforderlich',
            10: 'Komplett selbstständig',
          },
        ),
      ],
      '10 = Selbstständige Nutzung mit Reinigung\n'
      '5 = Hilfe oder Aufsicht erforderlich\n'
      '0 = Keine selbstständige Nutzung möglich',
      isAnswered: _selectedToilette != null,
    );
  }

  /// Builds the section for the Baden assessment.
  /// Provides options for selecting the level of independence in bathing.
  Widget _buildBadenSection() {
    return buildButtonSection(
      'Baden',
      [
        buildActionButtonField<int>(
          value: _selectedBaden,
          items: const [0, 5],
          onChanged: (value) => setState(() => _selectedBaden = value),
          itemInfo: {
            0: 'Erfüllt "5" nicht',
            5: 'Komplett selbstständig',
          },
        ),
      ],
      '5 = Selbstständiges Baden/Duschen\n'
      '0 = Benötigt Hilfe beim Baden/Duschen',
      isAnswered: _selectedBaden != null,
    );
  }

  /// Builds the section for the Treppensteigen assessment.
  /// Provides options for selecting the level of independence in climbing stairs.
  Widget _buildTreppensteigenSection() {
    return buildButtonSection(
      'Treppensteigen',
      [
        buildActionButtonField<int>(
          value: _selectedTreppensteigen,
          items: const [0, 5, 10],
          onChanged: (value) => setState(() => _selectedTreppensteigen = value),
          itemInfo: {
            0: 'Treppensteigen nicht möglich',
            5: 'Hilfe erforderlich',
            10: 'Komplett selbstständig',
          },
        ),
      ],
      '10 = Selbstständiges Treppensteigen\n'
      '5 = Mit Hilfe oder Unterstützung\n'
      '0 = Nicht möglich',
      isAnswered: _selectedTreppensteigen != null,
    );
  }

  /// Builds the section for the Kleiden assessment.
  /// Provides options for selecting the level of independence in dressing.
  Widget _buildKleidenSection() {
    return buildButtonSection(
      'Kleiden',
      [
        buildActionButtonField<int>(
          value: _selectedKleiden,
          items: const [0, 5, 10],
          onChanged: (value) => setState(() => _selectedKleiden = value),
          itemInfo: {
            0: 'Unfähig sich selbst zu kleiden',
            5: 'Hilfe erforderlich',
            10: 'Komplett selbstständig',
          },
        ),
      ],
      '10 = Selbstständiges An-/Auskleiden\n'
      '5 = Hilfe erforderlich\n'
      '0 = Vollständig abhängig',
      isAnswered: _selectedKleiden != null,
    );
  }

  /// Builds the section for the Stuhlkontrollen assessment.
  /// Provides options for selecting the level of independence in bowel control.
  Widget _buildStuhlkontrollenSection() {
    return buildButtonSection(
      'Stuhlkontrolle',
      [
        buildActionButtonField<int>(
          value: _selectedStuhlkontrollen,
          items: const [0, 5, 10],
          onChanged: (value) => setState(() => _selectedStuhlkontrollen = value),
          itemInfo: {
            0: 'Inkontinent',
            5: 'Gelegentlich inkontinent',
            10: 'Kontinent',
          },
        ),
      ],
      '10 = Vollständig kontinent\n'
      '5 = Gelegentlich inkontinent\n'
      '0 = Inkontinent oder wird eingeführt',
      isAnswered: _selectedStuhlkontrollen != null,
    );
  }

  /// Builds the section for the Harnkontrollen assessment.
  /// Provides options for selecting the level of independence in bladder control.
  Widget _buildHarnkontrollenSection() {
    return buildButtonSection(
      'Harnkontrolle',
      [
        buildActionButtonField<int>(
          value: _selectedHarnkontrollen,
          items: const [0, 5, 10],
          onChanged: (value) => setState(() => _selectedHarnkontrollen = value),
          itemInfo: {
            0: 'Inkontinent',
            5: 'Gelegentlich inkontinent',
            10: 'Kontinent',
          },
        ),
      ],
      '10 = Vollständig kontinent\n'
      '5 = Gelegentlich inkontinent\n'
      '0 = Inkontinent oder DK',
      isAnswered: _selectedHarnkontrollen != null,
    );
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    super.dispose();
  }
}
