import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import '../services/api_service.dart';
import '../assessments/counter_stopwatch_page.dart'; // Add this import

class MoCA5MinAssessment extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> assessmentData;

  const MoCA5MinAssessment({required this.patientId, required this.assessmentData, super.key});

  @override
  MoCA5MinAssessmentState createState() => MoCA5MinAssessmentState();
}

class MoCA5MinAssessmentState extends State<MoCA5MinAssessment> {
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

    // Helper function to check if a section is unfilled
    bool isWordRecognitionUnfilled() => _wordRecognition.values.every((v) => v == null);
    bool isOrientationUnfilled() => _orientation.values.every((v) => v == null);
    bool isMemoryRecallUnfilled() => _memoryRecall.values.every((list) => list.every((v) => v == null));

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoCA 5min Assessment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_lastAssessmentData.isNotEmpty) ...[
                const Text(
                  'Geladene Daten:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 24),
                const Divider(),
              ],
              const Text(
                'Anamnese:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Informationsquelle',
                value: _selectedAnamnese,
                items: const [0, 1, 2],
                onChanged: (value) => setState(() => _selectedAnamnese = value),
              ),
              GestureDetector(
                onTap: () => _showInfoDialog(context, 'Informationsquelle', 
                  '0 = Eigenanamnese\n1 = Auskunft verweigert\n2 = keine Auskunft möglich'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Information zur Informationsquelle',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _selectedAnamneseKommentar,
                decoration: InputDecoration(
                  labelText: 'Anamnese Kommentar',
                  fillColor: _selectedAnamneseKommentar.text.isEmpty ? Colors.orange.withAlpha(25) : null,
                  filled: _selectedAnamneseKommentar.text.isEmpty,
                ),
                maxLength: 1000,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isWordRecognitionUnfilled() ? Colors.orange.withAlpha(25) : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wortwiedererkennung:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showInfoDialog(
                        context,
                        'Wortwiedererkennung',
                        'Hinweis Interviewer:in: Lesen Sie die komplette folgende Wortliste laut vor uns lassen Sie den Patienten/die Patientin die Wörter wiederholen. Bitte markieren Sie, welche Wörter korrekt wiederholt wurden. Etwas verzögert soll der Patient/die Patientin die Worte erneut wiederholen, dieser zweite Durchgang wird nicht gewertet.'
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Information zur Wortwiedererkennung',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._wordRecognition.keys.map((word) {
                      return Row(
                        children: [
                          Expanded(child: Text(word)),
                          Checkbox(
                            value: _wordRecognition[word] == true,
                            onChanged: (value) {
                              setState(() {
                                _wordRecognition[word] = value == true ? true : null;
                              });
                            },
                          ),
                          const Text('Richtig'),
                          Checkbox(
                            value: _wordRecognition[word] == false,
                            onChanged: (value) {
                              setState(() {
                                _wordRecognition[word] = value == true ? false : null;
                              });
                            },
                          ),
                          const Text('Falsch'),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _counterStopwatch == null ? Colors.orange.withAlpha(25) : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sprache:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Erreichte Punkte',
                        border: OutlineInputBorder(),
                        fillColor: _counterStopwatch == null ? Colors.orange.withAlpha(25) : null,
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
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _showInfoDialog(context, 'Hinweis Interviewer:in', 
                        'Bitten Sie den Patienten/die Patientin innerhalb von einer Minute möglichst viele Tiernamen zu nennen. Jedes korrekt benannte Tier Wort gibt 0,5 Punkte bis zu einem Maximum von 9 Punkten. Es dürfen keine Begriffe doppelt genannt werden. Bitte setzen Sie für jeden korrekten Begriff ein Kreuz. Stoppuhr 60s Zeit nehmen.'),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Information zur Aufgabe',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isOrientationUnfilled() ? Colors.orange.withAlpha(25) : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ORIENTIERUNG:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showInfoDialog(
                        context,
                        'ORIENTIERUNG',
                        'Hinweis für Interviewer:in: Fragen Sie nach dem aktuellen Datum (Tag, Monat, Jahr), dem Wochentag, dem Ort und der Stadt. Jede korrekte Antwort gibt 1 Punkt. Bitte setzen Sie für jede korrekte Antwort ein Kreuz. Wenn zuvor zum gleichen Erhebungszeitpunkt der 4AT erhoben wurde, können die dort gegebenen Antworten zu Ort und Kalenderjahr übernommen werden.\n\n"Nennen Sie mir das ganze Datum des heutigen Tages."\nWenn nicht komplettes Datum genannt, dann weiter fragen:\n"Nennen Sie mir bitte das exakte Datum mit Monat, Jahr und Wochentag."\n"Nun nennen Sie mir bitte den Namen des Ortes (jeweiliges Krankenhaus) und der Stadt, in der wir gerade sind."'
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Information zur ORIENTIERUNG',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._orientation.keys.map((key) {
                      return Row(
                        children: [
                          Expanded(child: Text(key)),
                          Checkbox(
                            value: _orientation[key] == true,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _orientation[key] = true;
                                } else {
                                  _orientation[key] = null;
                                }
                              });
                            },
                          ),
                          const Text('Richtig'),
                          Checkbox(
                            value: _orientation[key] == false,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _orientation[key] = false;
                                } else {
                                  _orientation[key] = null;
                                }
                              });
                            },
                          ),
                          const Text('Falsch'),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMemoryRecallUnfilled() ? Colors.orange.withAlpha(25) : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GEDÄCHTNIS:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showInfoDialog(
                        context,
                        'GEDÄCHTNIS',
                        'Hinweis für Interviewer:in: Bitten Sie den Patienten/die Patientin, die zu Beginn genannten Begriffe erneut zu wiederholen. Jede korrekte Antwort gibt 2 Punkte. Für fehlende Begriffe dürfen Sie Kategorie-Hinweise (Formulierung in der Tabelle) geben. Jede anschließende korrekte Antwort gibt 1 Punkt. Bitte setzen Sie für jeden korrekten Begriff ein Kreuz (je nachdem, ob mit oder ohne Hinweis).\n\n"Zu Beginn habe ich Ihnen einige Wörter genannt, die Sie sich merken sollten. Bitte nennen Sie mir so viele Wörter wie möglich, an die Sie sich erinnern."\n\nMit Kategorie-Hinweis: „Unter den Wörtern war ein Teil des Körpers, eine Stoffart, ein Gebäude, eine Blumenart, eine Farbe“'
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Information zur GEDÄCHTNIS',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._memoryRecall.keys.map((word) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(word),
                          Row(
                            children: [
                              const Text('3. Durchgang'),
                              Checkbox(
                                value: _memoryRecall[word]?[0] == true,
                                onChanged: (value) {
                                  setState(() {
                                    _memoryRecall[word]?[0] = value == true ? true : null;
                                  });
                                },
                              ),
                              const Text('Mit Kategorie-Hinweis'),
                              Checkbox(
                                value: _memoryRecall[word]?[1] == true,
                                onChanged: (value) {
                                  setState(() {
                                    _memoryRecall[word]?[1] = value == true ? true : null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _saveAssessment,
                  child: const Text('Assessment speichern'),
                ),
              ),
            ],
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
        fillColor: isUnassigned ? Colors.orange.withAlpha(25) : null,
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

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
