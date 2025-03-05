import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BarthelIndexAssessment extends BaseAssessment {
  const BarthelIndexAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<BarthelIndexAssessment> createState() => _BarthelIndexAssessmentState();
}

class _BarthelIndexAssessmentState extends BaseAssessmentState<BarthelIndexAssessment> {
  int? _selectedAnamnese;
  final TextEditingController _selectedAnamneseKommentar = TextEditingController();
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
      _selectedAnamneseKommentar.text = assessmentData['anamnese_kommentar']?.toString() ?? '';
      _selectedEssen = _parseValue(assessmentData, 'essen');
      _selectedAufstehen = _parseValue(assessmentData, 'aufstehen');
      _selectedAufstehenGehen = _parseValue(assessmentData, 'aufstehengehen');
      _selectedWaschen = _parseValue(assessmentData, 'waschen');
      _selectedToilette = _parseValue(assessmentData, 'toilette');
      _selectedBaden = _parseValue(assessmentData, 'baden');
      _selectedTreppensteigen = _parseValue(assessmentData, 'treppensteigen');
      _selectedKleiden = _parseValue(assessmentData, 'kleiden');
      _selectedStuhlkontrollen = _parseValue(assessmentData, 'stuhlkontrollen');
      _selectedHarnkontrollen = _parseValue(assessmentData, 'harnkontrollen');
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

  @override
  String get assessmentName => 'Barthel Index';

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
  Widget buildAssessmentContent() {
    return Column(
      children: [
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildEssenSection(),
        const SizedBox(height: 16),
        _buildAufstehenSection(),
        // ... other sections ...
        ElevatedButton(
          onPressed: saveAssessment,
          child: const Text('Assessment Speichern'),
        ),
      ],
    );
  }

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
      '10 = Komplett selbstständig oder selbstständige PEG-Beschickung/-Versorgung\n'
      '5 = Hilfe bei mundgerechter Vorbereitung\n'
      '0 = Kein selbstständiges Einnehmen',
      isAnswered: _selectedEssen != null,
    );
  }

  // ... implement similar sections for other areas ...

  @override
  Future<void> saveAssessment() async {
    final data = {
      'anamnese': _selectedAnamnese,
      'anamnese_kommentar': _selectedAnamneseKommentar.text,
      'essen': _selectedEssen,
      'aufstehen': _selectedAufstehen,
      // ... other fields ...
    };

    if (data.values.contains(null)) {
      showError('Bitte füllen Sie alle Felder aus.');
      return;
    }

    try {
      final result = await ApiService.saveAssessment(
        widget.patientId, 
        assessmentName,
        data.map((key, value) => MapEntry(key, value.toString())),
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

  Widget _buildContainer({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.only(bottom: 16.0),
          child: child,
        );
      },
    );
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
                                style: const TextStyle(fontSize: 16),
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
                  'Anamnese',
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
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Aufstehen und Gehen',
                  [
                    _buildActionButtonField(
                      value: _selectedAufstehenGehen,
                      items: const [0, 5, 10, 15],
                      onChanged: (value) => setState(() => _selectedAufstehenGehen = value),
                      itemInfo: {
                        0: 'Erfüllt „5“ nicht',
                        5: 'Mit Laienhilfe oder Gehwagen vom Sitz in den Stand kommen und Strecken im Wohnbereich bewältigen. Alternativ: Im Wohnbereich komplett selbstständig mit Rollstuhl',
                        10: 'Ohne Aufsicht oder personelle Hilfe vom Sitz in den Stand kommen und mindestens 50m mit Hilfe eines Gehwagens gehen',
                        15: 'Ohne Aufsicht oder personelle Hilfe vom Sitz in den Stand kommen und mindestens 50m ohne Gehwagen (aber ggf. Stöcken/Gehstützen) gehen',
                      },
                    ),
                  ],
                  '15 = Ohne Aufsicht oder personelle Hilfe vom Sitz in den Stand kommen und mindestens 50m ohne Gehwagen (aber ggf. Stöcken/Gehstützen) gehen,\n'
                  '10 = Ohne Aufsicht oder personelle Hilfe vom Sitz in den Stand kommen und mindestens 50m mit Hilfe eines Gehwagens gehen,\n'
                  '5 = Mit Laienhilfe oder Gehwagen vom Sitz in den Stand kommen und Strecken im Wohnbereich bewältigen. Alternativ: Im Wohnbereich komplett selbstständig mit Rollstuhl,\n'
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
                        0: 'Hilfe beim Treppensteigen erforderlich',
                        5: 'Hilfe beim Treppensteigen erforderlich',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Komplett selbstständig,\n'
                  '5 = Hilfe beim Treppensteigen erforderlich,\n'
                  '0 = Hilfe beim Treppensteigen erforderlich',
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
                        0: 'Hilfe beim An- und Auskleiden erforderlich',
                        5: 'Hilfe beim An- und Auskleiden erforderlich',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Komplett selbstständig,\n'
                  '5 = Hilfe beim An- und Auskleiden erforderlich,\n'
                  '0 = Hilfe beim An- und Auskleiden erforderlich',
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
                        0: 'Hilfe bei der Stuhlkontrolle erforderlich',
                        5: 'Hilfe bei der Stuhlkontrolle erforderlich',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Komplett selbstständig,\n'
                  '5 = Hilfe bei der Stuhlkontrolle erforderlich,\n'
                  '0 = Hilfe bei der Stuhlkontrolle erforderlich',
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
                        0: 'Hilfe bei der Harnkontrolle erforderlich',
                        5: 'Hilfe bei der Harnkontrolle erforderlich',
                        10: 'Komplett selbstständig',
                      },
                    ),
                  ],
                  '10 = Komplett selbstständig,\n'
                  '5 = Hilfe bei der Harnkontrolle erforderlich,\n'
                  '0 = Hilfe bei der Harnkontrolle erforderlich',
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: saveAssessment,
                  child: const Text('Assessment Speichern'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonField({
    required int? value,
    required List<int> items,
    required ValueChanged<int?> onChanged,  
    required Map<int, String> itemInfo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ChoiceChip(
                label: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(itemInfo[item] ?? ''),  // Description of the option
                    Text(
                      item.toString(),  // Numeric value
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                selected: value == item,  // Is this the currently selected value?
                onSelected: (selected) {
                  onChanged(selected ? item : null);  // Update selection
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          margin: const EdgeInsets.symmetric(vertical: 12.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.grey.shade50,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF616161),
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonSection(String title, List<Widget> buttons, String infoText) {
    bool isAnswered = false;
    
    // Determine if section is answered based on the title
    switch (title) {
      case 'Essen':
        isAnswered = _selectedEssen != null;
        break;
      case 'Aufstehen':
        isAnswered = _selectedAufstehen != null;
        break;
      case 'Waschen':
        isAnswered = _selectedWaschen != null;
        break;
      // ... add cases for other sections ...
    }

    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isAnswered ? Colors.green.shade900 : Colors.orange.shade900,
            ),
          ),
          _buildInfoText(infoText),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: buttons,
          ),
        ],
      ),
    );
  }
}
