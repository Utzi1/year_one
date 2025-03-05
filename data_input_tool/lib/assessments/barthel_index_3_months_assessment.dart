import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

/// The Barthel Index 3-Month Follow-up Assessment tracks changes in activities of daily living.
/// 
/// This assessment allows comparison with the initial evaluation and measures:
/// * Activities of daily living (ADL) capabilities after 3 months
/// * Progress or decline in function across ten domains
/// * Changes in overall independence level
/// 
/// The assessment keeps the same structure as the initial Barthel Index but adds:
/// * Comparison with baseline values
/// * Visualization of changes in capabilities
/// * Documentation of interventions effects after 3 months

class BarthelIndex3MonthAssessment extends BaseAssessment {
  const BarthelIndex3MonthAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<BarthelIndex3MonthAssessment> createState() => _BarthelIndex3MonthAssessmentState();
}

class _BarthelIndex3MonthAssessmentState extends BaseAssessmentState<BarthelIndex3MonthAssessment> {
  // Form state variables 
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
  
  // Initial assessment data for comparison
  Map<String, dynamic> _initialAssessmentData = {};

  @override
  String get assessmentName => 'Barthel Index 3-Month Assessment';

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
      final result = await ApiService.getLastAssessment(widget.patientId, 'Barthel Index');
      if (result.isNotEmpty && result['data'] != null) {
        setState(() {
          _initialAssessmentData = result['data'];
        });
      }
    } catch (e) {
      // Silently handle error - initial assessment may not exist
      print('Could not load initial Barthel assessment: $e');
    }
  }

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
  
  int _calculateTotalScore() {
    int total = 0;
    if (_selectedEssen != null) total += _selectedEssen!;
    if (_selectedAufstehen != null) total += _selectedAufstehen!;
    if (_selectedAufstehenGehen != null) total += _selectedAufstehenGehen!;
    if (_selectedWaschen != null) total += _selectedWaschen!;
    if (_selectedToilette != null) total += _selectedToilette!;
    if (_selectedBaden != null) total += _selectedBaden!;
    if (_selectedTreppensteigen != null) total += _selectedTreppensteigen!;
    if (_selectedKleiden != null) total += _selectedKleiden!;
    if (_selectedStuhlkontrollen != null) total += _selectedStuhlkontrollen!;
    if (_selectedHarnkontrollen != null) total += _selectedHarnkontrollen!;
    return total;
  }
  
  int? _getInitialValue(String key) {
    if (_initialAssessmentData.isEmpty) return null;
    return _parseIntValue(_initialAssessmentData, key);
  }
  
  int? _getInitialTotalScore() {
    if (_initialAssessmentData.isEmpty) return null;
    
    int total = 0;
    final fields = [
      'essen', 'aufstehen', 'aufstehengehen', 'waschen',
      'toilette', 'baden', 'treppensteigen', 'kleiden',
      'stuhlkontrollen', 'harnkontrollen'
    ];
    
    bool hasAllFields = true;
    for (final field in fields) {
      final value = _parseIntValue(_initialAssessmentData, field);
      if (value == null) {
        hasAllFields = false;
        break;
      }
      total += value;
    }
    
    return hasAllFields ? total : null;
  }
  
  String _getScoreChangeText() {
    final initialScore = _getInitialTotalScore();
    final currentScore = _calculateTotalScore();
    
    if (initialScore == null) {
      return 'Keine Vergleichsdaten verfügbar';
    }
    
    final difference = currentScore - initialScore;
    if (difference > 0) {
      return 'Verbesserung um $difference Punkte';
    } else if (difference < 0) {
      return 'Verschlechterung um ${-difference} Punkte';
    } else {
      return 'Keine Veränderung';
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
      final totalScore = _calculateTotalScore();
      final result = await ApiService.saveAssessment(
        widget.patientId,
        assessmentName,
        {
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
          'total_score': totalScore.toString(),
          'initial_score': _getInitialTotalScore()?.toString() ?? 'None',
          'score_change': _getScoreChangeText(),
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

  @override
  Widget buildAssessmentContent() {
    return Column(
      children: [
        _buildInitialScoreSection(),
        const SizedBox(height: 16),
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
                'Kein vorheriges Barthel-Index Assessment gefunden. Vergleichswerte sind nicht verfügbar.',
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
                  'Ergebnis des ersten Assessments:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Barthel Index Score: $initialScore von 100 Punkten'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScoreComparisonSection() {
    final currentScore = _calculateTotalScore();
    final initialScore = _getInitialTotalScore();
    
    if (initialScore == null) {
      return const SizedBox.shrink();
    }
    
    final difference = currentScore - initialScore;
    Color color;
    IconData icon;
    
    if (difference > 0) {
      color = Colors.green;
      icon = Icons.arrow_upward;
    } else if (difference < 0) {
      color = Colors.red;
      icon = Icons.arrow_downward;
    } else {
      color = Colors.blue;
      icon = Icons.compare_arrows;
    }
    
    return buildButtonSection(
      'Vergleich nach 3 Monaten',
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Initial: $initialScore',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 16),
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              'Aktuell: $currentScore',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _getScoreChangeText(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
      'Vergleich zum initialen Assessment. Ein höherer Wert zeigt mehr Selbstständigkeit an.',
      isAnswered: true,
    );
  }

  Widget _buildAnamneseSection() {
    return buildButtonSection(
      'Informationsquelle (3-Monatskontrolle)',
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

  Widget _buildEssenSection() {
    final initialValue = _getInitialValue('essen');
    
    return buildButtonSection(
      'Essen (3-Monats-Kontrolle)',
      [
        if (initialValue != null)
          _buildComparisonRow('Vorheriger Wert', initialValue),
        const SizedBox(height: 8),
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
  
  Widget _buildComparisonRow(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('$value Punkte'),
        ],
      ),
    );
  }

  Widget _buildAufstehenSection() {
    final initialValue = _getInitialValue('aufstehen');
    
    return buildButtonSection(
      'Aufstehen (3-Monats-Kontrolle)',
      [
        if (initialValue != null)
          _buildComparisonRow('Vorheriger Wert', initialValue),
        const SizedBox(height: 8),
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
      '15 = Komplett selbstständig\n10 = Aufsicht oder geringe Hilfe\n5 = Erhebliche Hilfe\n0 = Wird nicht aus dem Bett transferiert',
      isAnswered: _selectedAufstehen != null,
    );
  }

  Widget _buildWaschenSection() {
    final initialValue = _getInitialValue('waschen');
    
    return buildButtonSection(
      'Waschen (3-Monats-Kontrolle)',
      [
        if (initialValue != null)
          _buildComparisonRow('Vorheriger Wert', initialValue),
        const SizedBox(height: 8),
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
      '5 = Vor Ort komplett selbstständig\n0 = Benötigt Hilfe bei der Körperpflege',
      isAnswered: _selectedWaschen != null,
    );
  }

  Widget _buildToiletteSection() {
    final initialValue = _getInitialValue('toilette');
    
    return buildButtonSection(
      'Toilette (3-Monats-Kontrolle)',
      [
        if (initialValue != null)
          _buildComparisonRow('Vorheriger Wert', initialValue),
        const SizedBox(height: 8),
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
      '10 = Selbstständige Nutzung mit Reinigung\n5 = Hilfe oder Aufsicht erforderlich\n0 = Keine selbstständige Nutzung möglich',
      isAnswered: _selectedToilette != null,
    );
  }

  // Define similar pattern for remaining sections
  Widget _buildBadenSection() {
    final initialValue = _getInitialValue('baden');
    
    return buildButtonSection(
      'Baden (3-Monats-Kontrolle)',
      [
        if (initialValue != null)
          _buildComparisonRow('Vorheriger Wert', initialValue),
        const SizedBox(height: 8),
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
      '5 = Selbstständiges Baden/Duschen\n0 = Benötigt Hilfe beim Baden/Duschen',
      isAnswered: _selectedBaden != null,
    );
  }

  Widget _buildTreppensteigenSection() {
    final initialValue = _getInitialValue('treppensteigen');
    
    return buildButtonSection(
      'Treppensteigen (3-Monats-Kontrolle)',
      [
        if (initialValue != null)
          _buildComparisonRow('Vorheriger Wert', initialValue),
        const SizedBox(height: 8),
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
      '10 = Selbstständiges Treppensteigen\n5 = Mit Hilfe oder Unterstützung\n0 = Nicht möglich',
      isAnswered: _selectedTreppensteigen != null,
    );
  }

  Widget _buildKleidenSection() {
    final initialValue = _getInitialValue('kleiden');
    
    return buildButtonSection(
      'Kleiden (3-Monats-Kontrolle)',
      [
        if (initialValue != null)
          _buildComparisonRow('Vorheriger Wert', initialValue),
        const SizedBox(height: 8),
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
      '10 = Selbstständiges An-/Auskleiden\n5 = Hilfe erforderlich\n0 = Vollständig abhängig',
      isAnswered: _selectedKleiden != null,
    );
  }

  Widget _buildStuhlkontrollenSection() {
    final initialValue = _getInitialValue('stuhlkontrollen');
    
    return buildButtonSection(
      'Stuhlkontrolle (3-Monats-Kontrolle)',
      [
        if (initialValue != null)
          _buildComparisonRow('Vorheriger Wert', initialValue),
        const SizedBox(height: 8),
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
      '10 = Vollständig kontinent\n5 = Gelegentlich inkontinent\n0 = Inkontinent oder wird eingeführt',
      isAnswered: _selectedStuhlkontrollen != null,
    );
  }

  Widget _buildHarnkontrollenSection() {
    final initialValue = _getInitialValue('harnkontrollen');
    
    return buildButtonSection(
      'Harnkontrolle (3-Monats-Kontrolle)',
      [
        if (initialValue != null)
          _buildComparisonRow('Vorheriger Wert', initialValue),
        const SizedBox(height: 8),
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
      '10 = Vollständig kontinent\n5 = Gelegentlich inkontinent\n0 = Inkontinent oder DK',
      isAnswered: _selectedHarnkontrollen != null,
    );
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    super.dispose();
  }
}
