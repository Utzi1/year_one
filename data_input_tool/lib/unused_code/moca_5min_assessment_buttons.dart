/// A StatefulWidget that implements the MoCA 5-minute assessment interface using buttons.
///
/// This widget provides a comprehensive interface for conducting and recording
/// the Montreal Cognitive Assessment (MoCA) 5-minute version. It includes sections for:
/// * Anamnesis source selection
/// * Word recognition testing
/// * Language assessment with animal naming task
/// * Orientation assessment
/// * Memory recall testing
///
/// The widget manages state for all assessment components and provides data validation
/// before saving. It also displays previous assessment data when available.
///
/// Features:
/// * Real-time score calculation
/// * Data persistence through API service
/// * Previous assessment data display
/// * Input validation
/// * Integrated stopwatch for timed tasks
///
/// The assessment includes multiple sections with specific scoring criteria:
/// * Word Recognition: 1 point per correct word
/// * Language (Animal Naming): 0.5 points per animal up to 9 points
/// * Orientation: 1 point per correct answer
/// * Memory Recall: 2 points for unprompted recall, 1 point with category hint
///
/// Required parameters:
/// * [patientId] - Unique identifier for the patient
/// * [assessmentData] - Map containing any existing assessment data
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../assessments/counter_stopwatch_page.dart';

class MoCA5MinAssessmentButtons extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> assessmentData;

  const MoCA5MinAssessmentButtons({required this.patientId, required this.assessmentData, super.key});

  @override
  _MoCA5MinAssessmentButtonsState createState() => _MoCA5MinAssessmentButtonsState();
}

class _MoCA5MinAssessmentButtonsState extends State<MoCA5MinAssessmentButtons> {
  int? _selectedAnamnese;
  final TextEditingController _selectedAnamneseKommentar = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic> _lastAssessmentData = {};
  Map<String, bool?> _wordRecognition = {
    'Gesicht': null,
    'Samt': null,
    'Kirche': null,
    'Tulpe': null,
    'Rot': null,
  };
  num? _counterStopwatch;
  Map<String, bool?> _orientation = {
    'Tag': null,
    'Monat': null,
    'Jahr': null,
    'Wochentag': null,
    'Ort': null,
    'Stadt': null,
  };
  Map<String, List<bool?>> _memoryRecall = {
    'Gesicht': [null, null],
    'Samt': [null, null],
    'Kirche': [null, null],
    'Tulpe': [null, null],
    'Rot': [null, null],
  };

  @override
  void initState() {
    super.initState();
    if (widget.assessmentData.isNotEmpty) {
      _initializeFromExistingData(widget.assessmentData);
    }
    _initializeData();
    _counterStopwatch = _parseValue(widget.assessmentData, 'counter_stopwatch');
  }

  void _initializeFromExistingData(Map<String, dynamic> data) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedAnamnese = _parseValue(data, 'anamnese');
        _selectedAnamneseKommentar.text = data['anamnese_kommentar']?.toString() ?? '';
        if (data.containsKey('word_recognition')) {
          final wordRecognitionData = List<bool>.from(data['word_recognition']);
          _wordRecognition = {
            'Gesicht': wordRecognitionData[0],
            'Samt': wordRecognitionData[1],
            'Kirche': wordRecognitionData[2],
            'Tulpe': wordRecognitionData[3],
            'Rot': wordRecognitionData[4],
          };
        }
        if (data.containsKey('orientation')) {
          final orientationData = List<bool>.from(data['orientation']);
          _orientation = {
            'Tag': orientationData[0],
            'Monat': orientationData[1],
            'Jahr': orientationData[2],
            'Wochentag': orientationData[3],
            'Ort': orientationData[4],
            'Stadt': orientationData[5],
          };
        }
        if (data.containsKey('memory_recall')) {
          final memoryRecallData = data['memory_recall'] as List<dynamic>;
          _memoryRecall = {
            'Gesicht': _convertToBoolList(memoryRecallData[0]),
            'Samt': _convertToBoolList(memoryRecallData[1]),
            'Kirche': _convertToBoolList(memoryRecallData[2]),
            'Tulpe': _convertToBoolList(memoryRecallData[3]),
            'Rot': _convertToBoolList(memoryRecallData[4]),
          };
        }
        _counterStopwatch = _parseValue(data, 'counter_stopwatch');
      });
    });
  }

  List<bool?> _convertToBoolList(dynamic value) {
    if (value is List) {
      return value.map((item) {
        if (item is bool) return item;
        if (item is String) return item.toLowerCase() == 'true';
        return null;
      }).toList();
    }
    return [null, null];
  }

  int? _parseValue(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) {
      final value = data[key];
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
    }
    return null;
  }

  Future<void> _initializeData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    
    try {
      final data = await ApiService.getMoCA5MinAssessment(widget.patientId);
      if (data.isNotEmpty) {
        setState(() {
          _lastAssessmentData = data;
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

  int? _calculateTotalScore() {
    if (_selectedAnamnese == 1 || _selectedAnamnese == 2) {
      return null;
    }

    int attentionMemoryScore = _wordRecognition.values.where((v) => v == true).length;
    double languageScore = (_counterStopwatch ?? 0) * 0.5;
    int orientationScore = _orientation.values.where((v) => v == true).length;
    int memoryScore = _memoryRecall.values.fold(0, (sum, list) {
      return sum + (list[0] == true ? 2 : 0) + (list[1] == true ? 1 : 0);
    });

    return (attentionMemoryScore + languageScore + orientationScore + memoryScore).toInt();
  }

  Future<void> _saveAssessment() async {
    if (_selectedAnamnese == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wählen Sie eine Informationsquelle aus.')),
      );
      return;
    }

    if (_wordRecognition.values.contains(null) ||
        _orientation.values.contains(null) ||
        _memoryRecall.values.any((list) => list.where((v) => v == null).length > 1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte füllen Sie alle Felder aus.')),
      );
      return;
    }

    final totalScore = _calculateTotalScore();

    final data = {
      'anamnese': _selectedAnamnese?.toString() ?? '',
      'anamnese_kommentar': _selectedAnamneseKommentar.text,
      'word_recognition': _wordRecognition.values.toList(),
      'counter_stopwatch': _counterStopwatch?.toString() ?? '',
      'orientation': _orientation.values.toList(),
      'memory_recall': _memoryRecall.values.map((list) => list.map((e) => e ?? false).toList()).toList(),
      'total_score': totalScore?.toString() ?? 'None',
    };

    final result = await ApiService.saveAssessment(widget.patientId, 'MoCA 5min', data);
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
        title: const Text('MoCA 5min Assessment (Buttons)'),
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
                    'MoCA 5-min Assessment:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 16),
                _buildButtonSection(
                  'Anamnese-Quelle',
                  'Anamnese Information:\n0 = Eigenanamnese\n1 = Auskunft verweigert\n2 = keine Auskunft möglich',
                  [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const Text(
                      'Anamnese-Quelle',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [0, 1, 2].map((item) {
                      return ChoiceChip(
                        label: Text(item.toString()),
                        selected: _selectedAnamnese == item,
                        onSelected: (selected) {
                        setState(() => _selectedAnamnese = selected ? item : null);
                        },
                      );
                      }).toList(),
                    ),
                    ],
                  ),
                  TextField(
                    controller: _selectedAnamneseKommentar,
                    decoration: const InputDecoration(labelText: 'Anamnese-Quelle Kommentar'),
                  ),
                  ],
                ),
                _buildButtonSection(
                  'Wortwiedererkennung',
                  'Hinweis Interviewer:in: Lesen Sie die komplette folgende Wortliste laut vor uns lassen Sie den Patienten/die Patientin die Wörter wiederholen. Bitte markieren Sie, welche Wörter korrekt wiederholt wurden. Etwas verzögert soll der Patient/die Patientin die Worte erneut wiederholen, dieser zweite Durchgang wird nicht gewertet.',
                  _wordRecognition.keys.map((word) {
                    return _buildActionButtonField(
                      label: word,
                      value: _wordRecognition[word] == true ? 1 : _wordRecognition[word] == false ? 0 : null,
                      items: const [1, 0],
                      onChanged: (value) {
                        setState(() {
                          _wordRecognition[word] = value == 1 ? true : value == 0 ? false : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                _buildButtonSection(
                  'Sprache',
                  'Bitten Sie den Patienten/die Patientin innerhalb von einer Minute möglichst viele Tiernamen zu nennen. Jedes korrekt benannte Tier Wort gibt 0,5 Punkte bis zu einem Maximum von 9 Punkten. Es dürfen keine Begriffe doppelt genannt werden. Bitte setzen Sie für jeden korrekten Begriff ein Kreuz. Stoppuhr 60s Zeit nehmen.',
                  [
                    TextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Erreichte Punkte',
                        border: OutlineInputBorder(),
                        fillColor: _counterStopwatch == null ? Colors.orange.withOpacity(0.1) : null,
                        filled: _counterStopwatch == null,
                      ),
                      controller: TextEditingController(text: _counterStopwatch?.toString() ?? ''),
                      onChanged: (value) {
                        setState(() {
                          _counterStopwatch = int.tryParse(value);
                        });
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CounterStopwatchPage(
                              onCounterChanged: (value) {
                                setState(() {
                                  num count = value / 2;
                                  if (value > 9) {
                                    _counterStopwatch = 9;
                                  } else {
                                    _counterStopwatch = count;
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text('Zur Stoppuhr'),
                    ),
                  ],
                ),
                _buildButtonSection(
                  'ORIENTIERUNG',
                  'Hinweis für Interviewer:in: Fragen Sie nach dem aktuellen Datum (Tag, Monat, Jahr), dem Wochentag, dem Ort und der Stadt. Jede korrekte Antwort gibt 1 Punkt. Bitte setzen Sie für jede korrekte Antwort ein Kreuz. Wenn zuvor zum gleichen Erhebungszeitpunkt der 4AT erhoben wurde, können die dort gegebenen Antworten zu Ort und Kalenderjahr übernommen werden.\n\n"Nennen Sie mir das ganze Datum des heutigen Tages."\nWenn nicht komplettes Datum genannt, dann weiter fragen:\n"Nennen Sie mir bitte das exakte Datum mit Monat, Jahr und Wochentag."\n"Nun nennen Sie mir bitte den Namen des Ortes (jeweiliges Krankenhaus) und der Stadt, in der wir gerade sind."',
                  _orientation.keys.map((key) {
                    return _buildActionButtonField(
                      label: key,
                      value: _orientation[key] == true ? 1 : _orientation[key] == false ? 0 : null,
                      items: const [1, 0],
                      onChanged: (value) {
                        setState(() {
                          _orientation[key] = value == 1 ? true : value == 0 ? false : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                _buildButtonSection(
                  'GEDÄCHTNIS',
                  'Hinweis für Interviewer:in: Bitten Sie den Patienten/die Patientin, die zu Beginn genannten Begriffe erneut zu wiederholen. Jede korrekte Antwort gibt 2 Punkte. Für fehlende Begriffe dürfen Sie Kategorie-Hinweise (Formulierung in der Tabelle) geben. Jede anschließende korrekte Antwort gibt 1 Punkt. Bitte setzen Sie für jeden korrekten Begriff ein Kreuz (je nachdem, ob mit oder ohne Hinweis).\n\n"Zu Beginn habe ich Ihnen einige Wörter genannt, die Sie sich merken sollten. Bitte nennen Sie mir so viele Wörter wie möglich, an die Sie sich erinnern."\n\nMit Kategorie-Hinweis: „Unter den Wörtern war ein Teil des Körpers, eine Stoffart, ein Gebäude, eine Blumenart, eine Farbe“',
                  _memoryRecall.keys.map((word) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActionButtonField(
                          label: '$word (Ohne Kategorie-Hinweis):',
                          value: _memoryRecall[word]?[0] == true ? 1 : _memoryRecall[word]?[0] == false ? 0 : null,
                          items: const [1, 0],
                          onChanged: (value) {
                            setState(() {
                              _memoryRecall[word]?[0] = value == 1 ? true : value == 0 ? false : null;
                            });
                          },
                        ),
                        _buildActionButtonField(
                          label: '$word (Mit Kategorie-Hinweis):',
                          value: _memoryRecall[word]?[1] == true ? 1 : _memoryRecall[word]?[1] == false ? 0 : null,
                          items: const [1, 0],
                          onChanged: (value) {
                            setState(() {
                              _memoryRecall[word]?[1] = value == 1 ? true : value == 0 ? false : null;
                            });
                          },
                        ),
                      ],
                    );
                  }).toList(),
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
            final labelText = (item == 1) ? 'richtig' : (item == 0) ? 'falsch' : item.toString();
            return ChoiceChip(
              label: Text(labelText),
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(title),
            _buildInfoText(infoText),
            ...buttons,
          ],
        ),
      ),
    );
  }
}
