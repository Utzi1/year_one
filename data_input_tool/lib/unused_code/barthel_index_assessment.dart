/// Implements the Barthel Index assessment.
import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// A widget representing the Barthel Index assessment form for a patient.
class BarthelIndexAssessment extends StatefulWidget {
  /// The ID of the patient.
  final String patientId;

  /// The initial data for the assessment.
  final Map<String, dynamic> assessmentData;

  /// Creates an instance of [BarthelIndexAssessment].
  const BarthelIndexAssessment({required this.patientId, required this.assessmentData, super.key});

  @override
  _BarthelIndexAssessmentState createState() => _BarthelIndexAssessmentState();
}

class _BarthelIndexAssessmentState extends State<BarthelIndexAssessment> {
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
        // Handle both numeric strings and null values
        if (value.toLowerCase() == 'null') return null;
        return int.tryParse(value);
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if available
    if (widget.assessmentData.isNotEmpty) {
      _initializeFromExistingData(widget.assessmentData);
    }
    _initializeData();
  }

  void _initializeFromExistingData(Map<String, dynamic> data) {
    setState(() {
      // If data is nested under 'data' key, extract it
      final assessmentData = data['data'] ?? data;
      
      // Parse values, ensuring to handle both string and int values
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
          // Store the complete response for display
          _lastAssessmentData = Map<String, dynamic>.from(data['data'] ?? {});
          // Initialize form with the last assessment data
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

  Future<bool> _showConfirmationDialog() async {
    bool hasUnansweredQuestions = [
      _selectedAnamnese,
      _selectedEssen,
      _selectedAufstehen,
      _selectedAufstehenGehen,
      _selectedWaschen,
      _selectedToilette,
      _selectedBaden,
      _selectedTreppensteigen,
      _selectedKleiden,
      _selectedStuhlkontrollen,
      _selectedHarnkontrollen,
    ].contains(null);

    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Speichern bestätigen'),
          content: Text(
            hasUnansweredQuestions
                ? 'Es gibt unbeantwortete Fragen. Möchten Sie das Assessment trotzdem speichern?'
                : 'Möchten Sie das Assessment speichern?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Nein'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ja'),
            ),
          ],
        );
      },
    ) ?? false;
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
    final confirm = await _showConfirmationDialog();
    if (confirm) {
      if (!mounted) return;
      final result = await ApiService.saveAssessment(widget.patientId, 'Barthel Index', data.map((key, value) => MapEntry(key, value.toString())));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to save assessment')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Das Assessment sollte später noch komplettiert werden.')),
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
             // Display last assessment data if available
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
             const SizedBox(height: 16), // Placeholder
             _buildDropdownField(
               label: 'Anamnese',
               value: _selectedAnamnese,
               items: const [0, 1, 3, 4, 5],
               onChanged: (value) => setState(() => _selectedAnamnese = value),
             ),
             GestureDetector(
               onTap: () {
               showDialog(
                 context: context,
                 builder: (BuildContext context) {
                 return AlertDialog(
                   title: const Text('Anamnese Information'),
                   content: const Text(
                   '0 = Eigenanamnese,\n2 = Fremdanamnese,\n3 = Aktenanamnese, \n4 = Auskunft verweigert,\n5 = keine Auskunft möglich.',
                   ),
                   actions: <Widget>[
                   TextButton(
                     onPressed: () => Navigator.of(context).pop(),
                     child: const Text('OK'),
                   ),
                   ],
                 );
                 },
               );
               },
               child: Align(
               alignment: Alignment.centerLeft,
               child: RichText(
                 textAlign: TextAlign.left,
                 text: const TextSpan(
                 text: 'Anamnese Information',
                 style: TextStyle(
                   color: Colors.blue,
                   decoration: TextDecoration.underline,
                 ),
                 ),
               ),
               ),
             ),
             const SizedBox(height: 16), // Placeholder
            TextField(
              controller: _selectedAnamneseKommentar,
              decoration: const InputDecoration(labelText: 'Anamnese Kommentar'),
            ),
             const SizedBox(height: 16),
             _buildDropdownField(
               label: 'Essen',
               value: _selectedEssen,
               items: const [0, 5, 10],
               onChanged: (value) => setState(() => _selectedEssen = value),
             ),
             GestureDetector(
               onTap: () {
               showDialog(
                 context: context,
                 builder: (BuildContext context) {
                 return AlertDialog(
                   title: const Text('Essen Information'),
                   content: const Text(
                   '10 = Komplett selbstständig oder selbstständige PEG-Beschickung/-Versorgung,\n'
                   '5 = Hilfe bei mundgerechter Vorbereitung, aber selbstständiges Einnehmen oder Hilfe bei PEG-Beschickung/-Versorgung,\n'
                   '0 = Kein selbstständiges Einnehmen und keine MS/PEG-Ernährung',
                   ),
                   actions: <Widget>[
                   TextButton(
                     onPressed: () => Navigator.of(context).pop(),
                     child: const Text('OK'),
                   ),
                   ],
                 );
                 },
               );
               },
               child: Align(
               alignment: Alignment.centerLeft,
               child: RichText(
                 textAlign: TextAlign.left,
                 text: const TextSpan(
                 text: 'Essen Information',
                 style: TextStyle(
                   color: Colors.blue,
                   decoration: TextDecoration.underline,
                 ),
                 ),
               ),
               ),
             ),
            const SizedBox(height: 16), // Placeholder
            _buildDropdownField(
              label: 'Aufstehen',
              value: _selectedAufstehen,
              items: const [0, 5, 10, 15],
              onChanged: (value) => setState(() => _selectedAufstehen = value),
            ),
            GestureDetector(
              onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Aufstehen Information'),
                  content: const Text(
                  '10 = Aufsicht oder geringe Hilfe (ungeschulte Laienhilfe),\n'
                  '5 = Erhebliche Hilfe (geschulte Laienhilfe oder professionelle Hilfe),\n'
                  '0 = Wird faktisch nicht aus dem Bett transferiert',
                  ),
                  actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                  ],
                );
                },
              );
              },
              child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                textAlign: TextAlign.left,
                text: const TextSpan(
                text: 'Aufstehen Information',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                ),
              ),
              ),
            ),
            const SizedBox(height: 16), // Placeholder
            _buildDropdownField(
              label: 'Waschen',
              value: _selectedWaschen,
              items: const [0, 5],
              onChanged: (value) => setState(() => _selectedWaschen = value),
            ),
            GestureDetector(
              onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Waschen Information'),
                  content: const Text(
                  '5 = Vor Ort komplett selbstständig inkl. Zähneputzen, Rasieren und Frisieren,\n'
                  '0 = Erfüllt „5“ nicht',
                  ),
                  actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                  ],
                );
                },
              );
              },
              child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                textAlign: TextAlign.left,
                text: const TextSpan(
                text: 'Waschen Information',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                ),
              ),
              ),
            ),
            const SizedBox(height: 16), // Placeholder
            _buildDropdownField(
              label: 'Toilette',
              value: _selectedToilette,
              items: const [0, 5, 10],
              onChanged: (value) => setState(() => _selectedToilette = value),
            ),
            GestureDetector(
              onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Toilette Information'),
                  content: const Text(
                  '10= Vor Ort komplett selbstständige Nutzung von Toilette oder Toilettenstuhl inkl. Spülung/Reinigung,\n'
                  '5 = Vor Ort Hilfe oder Aufsicht bei Toiletten- oder Toilettenstuhlbenutzung oder deren Spülung/Reinigung erforderlich,\n'
                  '0 = Benutzung faktisch weder Toilette noch Toilettenstuhl',
                  ),
                  actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                  ],
                );
                },
              );
              },
              child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                textAlign: TextAlign.left,
                text: const TextSpan(
                text: 'Toilette Information',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                ),
              ),
              ),
            ),
            const SizedBox(height: 16), // Placeholder
            _buildDropdownField(
              label: 'Baden',
              value: _selectedBaden,
              items: const [0, 5],
              onChanged: (value) => setState(() => _selectedBaden = value),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Baden Information'),
                      content: const Text(
                        '5 = Selbstständiges Baden oder Duschen inkl. Ein-/Ausstieg, sich reinigen und abtrocknen,\n'
                        '0 = Erfüllt „5“ nicht',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  textAlign: TextAlign.left,
                  text: const TextSpan(
                    text: 'Baden Information',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // Placeholder
            _buildDropdownField(
              label: 'Aufstehen und Gehen',
              value: _selectedAufstehenGehen,
              items: const [0, 5, 10, 15],
              onChanged: (value) => setState(() => _selectedAufstehenGehen = value),
            ),
            GestureDetector(
              onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Aufstehen und Gehen Information'),
                  content: const Text(
                  '15 = Ohne Aufsicht oder personelle Hilfe vom Sitz in den Stand kommen und mindestens 50m ohne Gehwagen (aber ggf. Stöcken/Gehstützen) gehen,\n'
                  '10 = Ohne Aufsicht oder personelle Hilfe vom Sitz in den Stand kommen und mindestens 50m mit Hilfe eines Gehwagens gehen,\n'
                  '5 = Mit Laienhilfe oder Gehwagen vom Sitz in den Stand kommen und Strecken im Wohnbereich bewältigen. Alternativ: Im Wohnbereich komplett selbstständig mit Rollstuhl,\n'
                  '0 = Erfüllt „5“ nicht',
                  ),
                  actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                  ],
                );
                },
              );
              },
              child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                textAlign: TextAlign.left,
                text: const TextSpan(
                text: 'Aufstehen und Gehen Information',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                ),
              ),
              ),
            ),
            const SizedBox(height: 16), // Placeholder
            _buildDropdownField(
              label: 'Treppensteigen',
              value: _selectedTreppensteigen,
              items: const [0, 5, 10],
              onChanged: (value) => setState(() => _selectedTreppensteigen = value),
            ),
            GestureDetector(
              onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Treppensteigen Information'),
                  content: const Text(
                  '10 = Ohne Aufsicht oder personelle Hilfe (ggf. Stöcken/Gehstützen) mindestens ein Stockwerk hinauf und hinuntersteigen,\n'
                  '5 = Mit Aufsicht oder Laienhilfe mind. Ein Stockwerk hinauf und hinuntersteigen,\n'
                  '0 = Erfüllt „5“ nicht',
                  ),
                  actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                  ],
                );
                },
              );
              },
              child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                textAlign: TextAlign.left,
                text: const TextSpan(
                text: 'Treppensteigen Information',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                ),
              ),
              ),
            ),
            const SizedBox(height: 16), // Placeholder
            _buildDropdownField(
              label: 'Kleiden',
              value: _selectedKleiden,
              items: const [0, 5, 10],
              onChanged: (value) => setState(() => _selectedKleiden = value),
            ),
            GestureDetector(
              onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Kleiden Information'),
                  content: const Text(
                  '10 = Zieht sich in angemessener Zeit selbstständig Tageskleidung, Schuhe (und ggf. benötigte Hilfsmittel z.B. ATS, Prothesen) an und aus,\n'
                  '5 = Kleidet mindestens den Oberkörper in angemessener Zeit selbstständig an und aus, sofern die Utensilien in greifbarer Nähe sind, \n'
                  '0 = Erfüllt „5“ nicht',
                  ),
                  actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                  ],
                );
                },
              );
              },
              child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                textAlign: TextAlign.left,
                text: const TextSpan(
                text: 'Kleiden Information',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                ),
              ),
              ),
            ),
            const SizedBox(height: 16), // Placeholder
            _buildDropdownField(
              label: 'Stuhlkontrollen',
              value: _selectedStuhlkontrollen,
              items: const [0, 5, 10],
              onChanged: (value) => setState(() => _selectedStuhlkontrollen = value),
            ),
            GestureDetector(
              onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Stuhlkontrollen Information'),
                  content: const Text(
                  '10 = Ist stuhlkontinent, ggf. selbstständig bei rektalen Abführmaßnahmen oder AP-Versorgung,\n'
                  '5 = Ist durchschnittlich nicht mehr als 1x/Woche stuhlinkontinent oder benötigt Hilfe bei rektalen Abführmaßnahmen/AP-Versorgung,\n'
                  '0 = Ist durchschnittlich mehr als 1x/Woche stuhlinkontinent',
                  ),
                  actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                  ],
                );
                },
              );
              },
              child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                textAlign: TextAlign.left,
                text: const TextSpan(
                text: 'Stuhlkontrollen Information',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                ),
              ),
              ),
            ),
            const SizedBox(height: 16), // Placeholder
            _buildDropdownField(
              label: 'Harnkontrollen',
              value: _selectedHarnkontrollen,
              items: const [0, 5, 10],
              onChanged: (value) => setState(() => _selectedHarnkontrollen = value),
            ),
            GestureDetector(
              onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Harnkontrollen Information'),
                  content: const Text(
                  '10 = Ist harnkontinent oder kompensiert seine Harninkontinenz/versorgt seinen DK komplett selbstständig mit Erfolg (kein Einnässen von Kleidung oder Bettwäsche),\n'
                  '5 = Kompensiert seine Harninkontinenz selbstständig und mit überwiegendem Erfolg (durchschnittlich nicht mehr als 1x/Tag Einnässen von Kleidung oder Bettwäsche) oder benötigt Hilfe bei der Versorgung seines Harnkathetersystems,\n'
                  '0 = Ist durchschnittlich mehr als 1x/Tag harninkontinent',
                  ),
                  actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                  ],
                );
                },
              );
              },
              child: Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                textAlign: TextAlign.left,
                text: const TextSpan(
                text: 'Harnkontrollen Information',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                ),
              ),
              ),
            ),
            const SizedBox(height: 16), // Placeholder
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

  Widget _buildDropdownField({
    required String label,
    required int? value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    final bool isUnassigned = value == null;
    
    return DropdownButtonFormField<int?>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        fillColor: isUnassigned ? Colors.orange.withOpacity(0.1) : null,
        filled: isUnassigned,
      ),
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text(
            'keine Angabe',
            style: TextStyle(
              color: Colors.orange,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        ...items.map((int item) {
          return DropdownMenuItem<int?>(
            value: item,
            child: Text(
              item.toString(),
              style: const TextStyle(color: Colors.black),
            ),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }
}
