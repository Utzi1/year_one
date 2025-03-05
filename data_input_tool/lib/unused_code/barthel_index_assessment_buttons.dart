import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BarthelIndexAssessmentButtons extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> assessmentData;

  const BarthelIndexAssessmentButtons({required this.patientId, required this.assessmentData, super.key});

  @override
  _BarthelIndexAssessmentButtonsState createState() => _BarthelIndexAssessmentButtonsState();
}

class _BarthelIndexAssessmentButtonsState extends State<BarthelIndexAssessmentButtons> {
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

  Future<void> _saveAssessment() async {
    final data = {
      'anamnese': _selectedAnamnese,
      'anamnese_kommentar': _selectedAnamneseKommentar.text,
      'essen': _selectedEssen,
      'aufstehen': _selectedAufstehen,
      'waschen': _selectedWaschen,
      'toilette': _selectedToilette,
      'baden': _selectedBaden,
      'aufstehengehen': _selectedAufstehenGehen,
      'treppensteigen': _selectedTreppensteigen,
      'kleiden': _selectedKleiden,
      'stuhlkontrollen': _selectedStuhlkontrollen,
      'harnkontrollen': _selectedHarnkontrollen,
    };

    if (data.values.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte füllen Sie alle Felder aus.')),
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
        title: const Text('Barthel Index (Buttons)'),
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
                            'Letztes Assessment:',
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
                  const Text(
                    'Neues Assessment:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Anamnese',
                  'Anamnese Information:\n0 = Eigenanamnese\n2 = Fremdanamnese\n3 = Aktenanamnese\n4 = Auskunft verweigert\n5 = keine Auskunft möglich',
                  [
                    _buildActionButtonField(
                      label: 'Anamnese',
                      value: _selectedAnamnese,
                      items: const [0, 1, 3, 4, 5],
                      onChanged: (value) => setState(() => _selectedAnamnese = value),
                    ),
                    TextField(
                      controller: _selectedAnamneseKommentar,
                      decoration: const InputDecoration(labelText: 'Anamnese Kommentar'),
                    ),
                  ],
                ),
                _buildButtonSection(
                  'Essen',
                  'Essen Information:\n10 = Komplett selbstständig oder selbstständige PEG-Beschickung/-Versorgung\n5 = Hilfe bei mundgerechter Vorbereitung, aber selbstständiges Einnehmen oder Hilfe bei PEG-Beschickung/-Versorgung\n0 = Kein selbstständiges Einnehmen und keine MS/PEG-Ernährung',
                  [
                    _buildActionButtonField(
                      label: 'Essen',
                      value: _selectedEssen,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedEssen = value),
                    ),
                  ],
                ),
                _buildButtonSection(
                  'Aufstehen',
                  'Aufstehen Information:\n10 = Aufsicht oder geringe Hilfe (ungeschulte Laienhilfe)\n5 = Erhebliche Hilfe (geschulte Laienhilfe oder professionelle Hilfe)\n0 = Wird faktisch nicht aus dem Bett transferiert',
                  [
                    _buildActionButtonField(
                      label: 'Aufstehen',
                      value: _selectedAufstehen,
                      items: const [0, 5, 10, 15],
                      onChanged: (value) => setState(() => _selectedAufstehen = value),
                    ),
                  ],
                ),
                _buildButtonSection(
                  'Waschen',
                  'Waschen Information:\n5 = Vor Ort komplett selbstständig inkl. Zähneputzen, Rasieren und Frisieren\n0 = Hilfe bei der Körperpflege erforderlich',
                  [
                    _buildActionButtonField(
                      label: 'Waschen',
                      value: _selectedWaschen,
                      items: const [0, 5],
                      onChanged: (value) => setState(() => _selectedWaschen = value),
                    ),
                  ],
                ),
                _buildButtonSection(
                  'Toilette',
                  'Toilette Information:\n10 = Komplett selbstständig\n5 = Hilfe bei der Benutzung erforderlich\n0 = Hilfe bei der Benutzung erforderlich',
                  [
                    _buildActionButtonField(
                      label: 'Toilette',
                      value: _selectedToilette,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedToilette = value),
                    ),
                  ],
                ),
                _buildButtonSection(
                  'Baden',
                  'Baden Information:\n5 = Vor Ort komplett selbstständig\n0 = Hilfe beim Baden erforderlich',
                  [
                    _buildActionButtonField(
                      label: 'Baden',
                      value: _selectedBaden,
                      items: const [0, 5],
                      onChanged: (value) => setState(() => _selectedBaden = value),
                    ),
                  ],
                ),
                _buildButtonSection(
                  'Aufstehen und Gehen',
                  'Aufstehen und Gehen Information:\n15 = Komplett selbstständig\n10 = Aufsicht oder geringe Hilfe (ungeschulte Laienhilfe)\n5 = Erhebliche Hilfe (geschulte Laienhilfe oder professionelle Hilfe)\n0 = Wird faktisch nicht aus dem Bett transferiert',
                  [
                    _buildActionButtonField(
                      label: 'Aufstehen und Gehen',
                      value: _selectedAufstehenGehen,
                      items: const [0, 5, 10, 15],
                      onChanged: (value) => setState(() => _selectedAufstehenGehen = value),
                    ),
                  ],
                ),
                _buildButtonSection(
                  'Treppensteigen',
                  'Treppensteigen Information:\n10 = Komplett selbstständig\n5 = Hilfe beim Treppensteigen erforderlich\n0 = Hilfe beim Treppensteigen erforderlich',
                  [
                    _buildActionButtonField(
                      label: 'Treppensteigen',
                      value: _selectedTreppensteigen,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedTreppensteigen = value),
                    ),
                  ],
                ),
                _buildButtonSection(
                  'Kleiden',
                  'Kleiden Information:\n10 = Komplett selbstständig\n5 = Hilfe beim An- und Auskleiden erforderlich\n0 = Hilfe beim An- und Auskleiden erforderlich',
                  [
                    _buildActionButtonField(
                      label: 'Kleiden',
                      value: _selectedKleiden,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedKleiden = value),
                    ),
                  ],
                ),
                _buildButtonSection(
                  'Stuhlkontrollen',
                  'Stuhlkontrollen Information:\n10 = Komplett selbstständig\n5 = Hilfe bei der Stuhlkontrolle erforderlich\n0 = Hilfe bei der Stuhlkontrolle erforderlich',
                  [
                    _buildActionButtonField(
                      label: 'Stuhlkontrollen',
                      value: _selectedStuhlkontrollen,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedStuhlkontrollen = value),
                    ),
                  ],
                ),
                _buildButtonSection(
                  'Harnkontrollen',
                  'Harnkontrollen Information:\n10 = Komplett selbstständig\n5 = Hilfe bei der Harnkontrolle erforderlich\n0 = Hilfe bei der Harnkontrolle erforderlich',
                  [
                    _buildActionButtonField(
                      label: 'Harnkontrollen',
                      value: _selectedHarnkontrollen,
                      items: const [0, 5, 10],
                      onChanged: (value) => setState(() => _selectedHarnkontrollen = value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveAssessment,
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
    required String label,
    required int? value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items.map((item) {
            return ChoiceChip(
              label: Text(item.toString()),
              selected: value == item,
              onSelected: (selected) {
                onChanged(selected ? item : null);
              },
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
    return Container(
      constraints: const BoxConstraints(
        minHeight: 100,  // Adjust as needed
        maxWidth: 600,   // Adjust as needed
      ),
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
  }

  Widget _buildButtonSection(String title, String infoText, List<Widget> buttons) {
    return Center(
      child: Container(
        width: 600, // Fixed width instead of maxWidth constraint
        margin: const EdgeInsets.only(bottom: 24.0),
        padding: const EdgeInsets.all(16.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(title),
            _buildInfoText(infoText),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.start,
              children: buttons,
            ),
          ],
        ),
      ),
    );
  }
}
