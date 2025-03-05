import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BarthelIndexAssessmentButtonsHorizontalRecode extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> assessmentData;

  const BarthelIndexAssessmentButtonsHorizontalRecode({required this.patientId, required this.assessmentData, super.key});

  @override
  _BarthelIndexAssessmentButtonsHorizontalRecodeState createState() => _BarthelIndexAssessmentButtonsHorizontalRecodeState();
}

class _BarthelIndexAssessmentButtonsHorizontalRecodeState extends State<BarthelIndexAssessmentButtonsHorizontalRecode> {
  int? _selectedAnamnese;
  int? _selectedAnamnese2Weeks;
  final TextEditingController _selectedAnamneseKommentar = TextEditingController();
  int? _selectedEssen;
  int? _selectedEssen2Weeks;
  int? _selectedAufstehen;
  int? _selectedAufstehen2Weeks;
  int? _selectedAufstehenGehen;
  int? _selectedAufstehenGehen2Weeks;
  int? _selectedWaschen;
  int? _selectedWaschen2Weeks;
  int? _selectedToilette;
  int? _selectedToilette2Weeks;
  int? _selectedBaden;
  int? _selectedBaden2Weeks;
  int? _selectedTreppensteigen;
  int? _selectedTreppensteigen2Weeks;
  int? _selectedKleiden;
  int? _selectedKleiden2Weeks;
  int? _selectedStuhlkontrollen;
  int? _selectedStuhlkontrollen2Weeks;
  int? _selectedHarnkontrollen;
  int? _selectedHarnkontrollen2Weeks;
  bool _isLoading = false;
  Map<String, dynamic> _lastAssessmentData = {};

  int? _parseValue(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) {
      final value = data[key];
      if (value is int) return value;
      if (value is String) {
        if (value.toLowerCase() == 'null') return null;
        return int.tryParse(value);
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.assessmentData.isNotEmpty) {
      _initializeFromExistingData(widget.assessmentData);
    }
    _initializeData();
  }

  void _initializeFromExistingData(Map<String, dynamic> data) {
    setState(() {
      final assessmentData = data['data'] ?? data;
      _selectedAnamnese = _parseValue(assessmentData, 'anamnese');
      _selectedAnamnese2Weeks = _parseValue(assessmentData, 'anamnese_2_weeks');
      _selectedAnamneseKommentar.text = assessmentData['anamnese_kommentar']?.toString() ?? '';
      _selectedEssen = _parseValue(assessmentData, 'essen');
      _selectedEssen2Weeks = _parseValue(assessmentData, 'essen_2_weeks');
      _selectedAufstehen = _parseValue(assessmentData, 'aufstehen');
      _selectedAufstehen2Weeks = _parseValue(assessmentData, 'aufstehen_2_weeks');
      _selectedAufstehenGehen = _parseValue(assessmentData, 'aufstehengehen');
      _selectedAufstehenGehen2Weeks = _parseValue(assessmentData, 'aufstehengehen_2_weeks');
      _selectedWaschen = _parseValue(assessmentData, 'waschen');
      _selectedWaschen2Weeks = _parseValue(assessmentData, 'waschen_2_weeks');
      _selectedToilette = _parseValue(assessmentData, 'toilette');
      _selectedToilette2Weeks = _parseValue(assessmentData, 'toilette_2_weeks');
      _selectedBaden = _parseValue(assessmentData, 'baden');
      _selectedBaden2Weeks = _parseValue(assessmentData, 'baden_2_weeks');
      _selectedTreppensteigen = _parseValue(assessmentData, 'treppensteigen');
      _selectedTreppensteigen2Weeks = _parseValue(assessmentData, 'treppensteigen_2_weeks');
      _selectedKleiden = _parseValue(assessmentData, 'kleiden');
      _selectedKleiden2Weeks = _parseValue(assessmentData, 'kleiden_2_weeks');
      _selectedStuhlkontrollen = _parseValue(assessmentData, 'stuhlkontrollen');
      _selectedStuhlkontrollen2Weeks = _parseValue(assessmentData, 'stuhlkontrollen_2_weeks');
      _selectedHarnkontrollen = _parseValue(assessmentData, 'harnkontrollen');
      _selectedHarnkontrollen2Weeks = _parseValue(assessmentData, 'harnkontrollen_2_weeks');
    });
  }

  Future<void> _initializeData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    try {
      final data = await ApiService.getBarthelAssessment(widget.patientId);
      if (data.isNotEmpty) {
        setState(() {
          _lastAssessmentData = Map<String, dynamic>.from(data['data'] ?? {});
          _initializeFromExistingData(data);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _selectedAnamneseKommentar.dispose();
    super.dispose();
  }

  Future<void> _saveAssessment() async {
    final data = {
      'anamnese': _selectedAnamnese,
      'anamnese_2_weeks': _selectedAnamnese2Weeks,
      'anamnese_kommentar': _selectedAnamneseKommentar.text,
      'essen': _selectedEssen,
      'essen_2_weeks': _selectedEssen2Weeks,
      'aufstehen': _selectedAufstehen,
      'aufstehen_2_weeks': _selectedAufstehen2Weeks,
      'waschen': _selectedWaschen,
      'waschen_2_weeks': _selectedWaschen2Weeks,
      'toilette': _selectedToilette,
      'toilette_2_weeks': _selectedToilette2Weeks,
      'baden': _selectedBaden,
      'baden_2_weeks': _selectedBaden2Weeks,
      'aufstehengehen': _selectedAufstehenGehen,
      'aufstehengehen_2_weeks': _selectedAufstehenGehen2Weeks,
      'treppensteigen': _selectedTreppensteigen,
      'treppensteigen_2_weeks': _selectedTreppensteigen2Weeks,
      'kleiden': _selectedKleiden,
      'kleiden_2_weeks': _selectedKleiden2Weeks,
      'stuhlkontrollen': _selectedStuhlkontrollen,
      'stuhlkontrollen_2_weeks': _selectedStuhlkontrollen2Weeks,
      'harnkontrollen': _selectedHarnkontrollen,
      'harnkontrollen_2_weeks': _selectedHarnkontrollen2Weeks,
    };

    final nullFields = data.entries.where((entry) => entry.value == null || (entry.value is String && (entry.value as String?)?.isEmpty == true)).map((entry) => entry.key).toList();

    if (nullFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bitte füllen Sie alle Felder aus: ${nullFields.join(', ')}')),
      );
      return;
    }

    final result = await ApiService.saveAssessment(widget.patientId, 'Barthel Index', data.map((key, value) => MapEntry(key, value.toString())));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to save assessment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barthel Index'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          primary: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_lastAssessmentData.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Vorheriges Assessment:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._lastAssessmentData.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                '${entry.key}: ${entry.value}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: (entry.value == null || entry.value.toString().isEmpty)
                                      ? Colors.red // Color for unanswered questions
                                      : Colors.black, // Default color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                ],
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Anamnese-Quelle',
                  [
                    _buildActionButtonField(
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
                      controller: _selectedAnamneseKommentar,
                      decoration: const InputDecoration(labelText: 'Anamnese Kommentar'),
                    ),
                  ],
                  '0 = Eigenanamnese,\n2 = Fremdanamnese,\n3 = Aktenanamnese, \n4 = Auskunft verweigert,\n5 = keine Auskunft möglich.',
                ),
                _buildButtonSection(
                  'Anamnese-Quelle (vor 2 Wochen)',
                  [
                    _buildActionButtonField(
                      value: _selectedAnamnese2Weeks,
                      items: const [0, 1, 3, 4, 5],
                      onChanged: (value) => setState(() => _selectedAnamnese2Weeks = value),
                      itemInfo: {
                        0: 'Eigenanamnese',
                        1: 'Fremdanamnese',
                        3: 'Aktenanamnese',
                        4: 'Auskunft verweigert',
                        5: 'keine Auskunft möglich',
                      },
                    ),
                    TextField(
                    controller: _selectedAnamneseKommentar,
                    decoration: const InputDecoration(labelText: 'Anamnese Kommentar'),
                  ),
                  ],
                  '0 = Eigenanamnese,\n2 = Fremdanamnese,\n3 = Aktenanamnese, \n4 = Auskunft verweigert,\n5 = keine Auskunft möglich.',
                ),
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Essen',
                  [
                    _buildActionButtonField(
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
                  '10 = Komplett selbstständig oder selbstständige PEG-Beschickung/-Versorgung,\n'
                  '5 = Hilfe bei mundgerechter Vorbereitung, aber selbstständiges Einnehmen oder Hilfe bei PEG-Beschickung/-Versorgung,\n'
                  '0 = Kein selbstständiges Einnehmen und keine MS/PEG-Ernährung',
                ),
                _buildButtonSection(
                  'Essen (vor 2 Wochen)',
                  [
                    _buildActionButtonField(
                      value: _selectedEssen2Weeks,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedEssen2Weeks = value),
                      itemInfo: {
                        0: 'Kein selbstständiges Einnehmen',
                        5: 'Hilfe bei mundgerechter Vorbereitung',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Komplett selbstständig oder selbstständige PEG-Beschickung/-Versorgung,\n'
                  '5 = Hilfe bei mundgerechter Vorbereitung, aber selbstständiges Einnehmen oder Hilfe bei PEG-Beschickung/-Versorgung,\n'
                  '0 = Kein selbstständiges Einnehmen und keine MS/PEG-Ernährung',
                ),
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Aufstehen',
                  [
                    _buildActionButtonField(
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
                  '10 = Aufsicht oder geringe Hilfe (ungeschulte Laienhilfe),\n'
                  '5 = Erhebliche Hilfe (geschulte Laienhilfe oder professionelle Hilfe),\n'
                  '0 = Wird faktisch nicht aus dem Bett transferiert',
                ),
                _buildButtonSection(
                  'Aufstehen (vor 2 Wochen)',
                  [
                    _buildActionButtonField(
                      value: _selectedAufstehen2Weeks,
                      items: const [0, 5, 10, 15],
                      onChanged: (value) => setState(() => _selectedAufstehen2Weeks = value),
                      itemInfo: {
                        0: 'Wird faktisch nicht aus dem Bett transferiert',
                        5: 'Erhebliche Hilfe',
                        10: 'Aufsicht oder geringe Hilfe',
                        15: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Aufsicht oder geringe Hilfe (ungeschulte Laienhilfe),\n'
                  '5 = Erhebliche Hilfe (geschulte Laienhilfe oder professionelle Hilfe),\n'
                  '0 = Wird faktisch nicht aus dem Bett transferiert',
                ),
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Aufstehen und Gehen',
                  [
                    _buildActionButtonField(
                      value: _selectedAufstehenGehen,
                      items: const [0, 5, 10, 15],
                      onChanged: (value) => setState(() => _selectedAufstehenGehen = value),
                      itemInfo: {
                        0: 'Immobil oder < 50m',
                        5: 'Rollstuhl unabhängig',
                        10: 'Mit Hilfe eines Menschen',
                        15: 'Selbstständiges Gehen',
                      },
                    ),
                  ],
                  '15 = Selbstständiges Gehen (auch mit Stock) über mindestens 50 m,\n'
                  '10 = Mit Hilfe eines Menschen gehen über mindestens 50 m,\n'
                  '5 = Rollstuhl unabhängig inkl. Ecken über mindestens 50 m,\n'
                  '0 = Immobil oder < 50m',
                ),
                _buildButtonSection(
                  'Aufstehen und Gehen (vor 2 Wochen)',
                  [
                    _buildActionButtonField(
                      value: _selectedAufstehenGehen2Weeks,
                      items: const [0, 5, 10, 15],
                      onChanged: (value) => setState(() => _selectedAufstehenGehen2Weeks = value),
                      itemInfo: {
                        0: 'Immobil oder < 50m',
                        5: 'Rollstuhl unabhängig',
                        10: 'Mit Hilfe eines Menschen',
                        15: 'Selbstständiges Gehen',
                      },
                    ),
                  ],
                  '15 = Selbstständiges Gehen (auch mit Stock) über mindestens 50 m,\n'
                  '10 = Mit Hilfe eines Menschen gehen über mindestens 50 m,\n'
                  '5 = Rollstuhl unabhängig inkl. Ecken über mindestens 50 m,\n'
                  '0 = Immobil oder < 50m',
                ),
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Waschen',
                  [
                    _buildActionButtonField(
                      value: _selectedWaschen,
                      items: const [0, 5],
                      onChanged: (value) => setState(() => _selectedWaschen = value),
                      itemInfo: {
                        0: 'Hilfe bei der Körperpflege erforderlich',
                        5: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '5 = Vor Ort komplett selbstständig inkl. Zähneputzen, Rasieren und Frisieren,\n'
                  '0 = Erfüllt „5“ nicht',
                ),
                _buildButtonSection(
                  'Waschen (vor 2 Wochen)',
                  [
                    _buildActionButtonField(
                      value: _selectedWaschen2Weeks,
                      items: const [0, 5],
                      onChanged: (value) => setState(() => _selectedWaschen2Weeks = value),
                      itemInfo: {
                        0: 'Hilfe bei der Körperpflege erforderlich',
                        5: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '5 = Vor Ort komplett selbstständig inkl. Zähneputzen, Rasieren und Frisieren,\n'
                  '0 = Erfüllt „5“ nicht',
                ),
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Toilette',
                  [
                    _buildActionButtonField(
                      value: _selectedToilette,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedToilette = value),
                      itemInfo: {
                        0: 'Benutzung faktisch weder Toilette noch Toilettenstuhl',
                        5: 'Vor Ort Hilfe oder Aufsicht',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10= Vor Ort komplett selbstständige Nutzung von Toilette oder Toilettenstuhl inkl. Spülung/Reinigung,\n'
                  '5 = Vor Ort Hilfe oder Aufsicht bei Toiletten- oder Toilettenstuhlbenutzung oder deren Spülung/Reinigung erforderlich,\n'
                  '0 = Benutzung faktisch weder Toilette noch Toilettenstuhl',
                ),
                _buildButtonSection(
                  'Toilette (vor 2 Wochen)',
                  [
                    _buildActionButtonField(
                      value: _selectedToilette2Weeks,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedToilette2Weeks = value),
                      itemInfo: {
                        0: 'Benutzung faktisch weder Toilette noch Toilettenstuhl',
                        5: 'Vor Ort Hilfe oder Aufsicht',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10= Vor Ort komplett selbstständige Nutzung von Toilette oder Toilettenstuhl inkl. Spülung/Reinigung,\n'
                  '5 = Vor Ort Hilfe oder Aufsicht bei Toiletten- oder Toilettenstuhlbenutzung oder deren Spülung/Reinigung erforderlich,\n'
                  '0 = Benutzung faktisch weder Toilette noch Toilettenstuhl',
                ),
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Baden',
                  [
                    _buildActionButtonField(
                      value: _selectedBaden,
                      items: const [0, 5],
                      onChanged: (value) => setState(() => _selectedBaden = value),
                      itemInfo: {
                        0: 'erfüllt „5“ nicht',
                        5: 'Komplett selbstständig',
                      },
                    ),
                  ],
                        '5 = Selbstständiges Baden oder Duschen inkl. Ein-/Ausstieg, sich reinigen und abtrocknen,\n'
                        '0 = Erfüllt „5“ nicht',
                ),
                _buildButtonSection(
                  'Baden (vor 2 Wochen)',
                  [
                    _buildActionButtonField(
                      value: _selectedBaden2Weeks,
                      items: const [0, 5],
                      onChanged: (value) => setState(() => _selectedBaden2Weeks = value),
                      itemInfo: {
                        0: 'erfüllt „5“ nicht',
                        5: 'Komplett selbstständig',
                      },
                    ),
                  ],
                        '5 = Selbstständiges Baden oder Duschen inkl. Ein-/Ausstieg, sich reinigen und abtrocknen,\n'
                        '0 = Erfüllt „5“ nicht',
                ),
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Treppensteigen',
                  [
                    _buildActionButtonField(
                      value: _selectedTreppensteigen,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedTreppensteigen = value),
                      itemInfo: {
                        0: 'Erfüllt „5“ nicht',
                        5: 'Hilfe erforderlich',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Selbstständiges Treppensteigen,\n'
                  '5 = Hilfe erforderlich,\n'
                  '0 = Erfüllt „5“ nicht',
                ),
                _buildButtonSection(
                  'Treppensteigen (vor 2 Wochen)',
                  [
                    _buildActionButtonField(
                      value: _selectedTreppensteigen2Weeks,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedTreppensteigen2Weeks = value),
                      itemInfo: {
                        0: 'Erfüllt „5“ nicht',
                        5: 'Hilfe erforderlich',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Selbstständiges Treppensteigen,\n'
                  '5 = Hilfe erforderlich,\n'
                  '0 = Erfüllt „5“ nicht',
                ),
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Kleiden',
                  [
                    _buildActionButtonField(
                      value: _selectedKleiden,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedKleiden = value),
                      itemInfo: {
                        0: 'Erfüllt „5“ nicht',
                        5: 'Hilfe erforderlich',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Selbstständiges An- und Auskleiden,\n'
                  '5 = Hilfe erforderlich,\n'
                  '0 = Erfüllt „5“ nicht',
                ),
                _buildButtonSection(
                  'Kleiden (vor 2 Wochen)',
                  [
                    _buildActionButtonField(
                      value: _selectedKleiden2Weeks,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedKleiden2Weeks = value),
                      itemInfo: {
                        0: 'Erfüllt „5“ nicht',
                        5: 'Hilfe erforderlich',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Selbstständiges An- und Auskleiden,\n'
                  '5 = Hilfe erforderlich,\n'
                  '0 = Erfüllt „5“ nicht',
                ),
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Stuhlkontrollen',
                  [
                    _buildActionButtonField(
                      value: _selectedStuhlkontrollen,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedStuhlkontrollen = value),
                      itemInfo: {
                        0: 'Erfüllt „5“ nicht',
                        5: 'Hilfe erforderlich',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Selbstständige Stuhlkontrolle,\n'
                  '5 = Hilfe erforderlich,\n'
                  '0 = Erfüllt „5“ nicht',
                ),
                _buildButtonSection(
                  'Stuhlkontrollen (vor 2 Wochen)',
                  [
                    _buildActionButtonField(
                      value: _selectedStuhlkontrollen2Weeks,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedStuhlkontrollen2Weeks = value),
                      itemInfo: {
                        0: 'Erfüllt „5“ nicht',
                        5: 'Hilfe erforderlich',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Selbstständige Stuhlkontrolle,\n'
                  '5 = Hilfe erforderlich,\n'
                  '0 = Erfüllt „5“ nicht',
                ),
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Harnkontrollen',
                  [
                    _buildActionButtonField(
                      value: _selectedHarnkontrollen,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedHarnkontrollen = value),
                      itemInfo: {
                        0: 'Erfüllt „5“ nicht',
                        5: 'Hilfe erforderlich',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Selbstständige Harnkontrolle,\n'
                  '5 = Hilfe erforderlich,\n'
                  '0 = Erfüllt „5“ nicht',
                ),
                _buildButtonSection(
                  'Harnkontrollen (vor 2 Wochen)',
                  [
                    _buildActionButtonField(
                      value: _selectedHarnkontrollen2Weeks,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedHarnkontrollen2Weeks = value),
                      itemInfo: {
                        0: 'Erfüllt „5“ nicht',
                        5: 'Hilfe erforderlich',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Selbstständige Harnkontrolle,\n'
                  '5 = Hilfe erforderlich,\n'
                  '0 = Erfüllt „5“ nicht',
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveAssessment,
                  child: const Text('Speichern'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonSection(String title, List<Widget> children, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtonField({
    required int? value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
    required Map<int, String> itemInfo,
  }) {
    return Row(
      children: [
        for (final item in items)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(itemInfo[item] ?? ''),
                      content: Text('Information about ${itemInfo[item] ?? ''}'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: ElevatedButton(
                  onPressed: () => onChanged(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: value == item ? Colors.blue : Colors.white,
                  ),
                  child: Text(itemInfo[item] ?? ''),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
