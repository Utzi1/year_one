import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'counter_stopwatch_page.dart';
import 'base_assessment.dart';

class MoCA5MinAssessmentButtonsRecode extends BaseAssessment {
  const MoCA5MinAssessmentButtonsRecode({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<MoCA5MinAssessmentButtonsRecode> createState() => _MoCA5MinAssessmentButtonsRecodeState();
}

class _MoCA5MinAssessmentButtonsRecodeState extends BaseAssessmentState<MoCA5MinAssessmentButtonsRecode> {
  // Form state variables
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  Map<String, bool> _wordRecognition = {
    'Gesicht': false,
    'Samt': false,
    'Kirche': false,
    'Tulpe': false,
    'Rot': false,
  };
  num? _counterStopwatch;
  Map<String, bool> _orientation = {
    'Tag': false,
    'Monat': false,
    'Jahr': false,
    'Wochentag': false,
    'Ort': false,
    'Stadt': false,
  };
  Map<String, List<bool>> _memoryRecall = {
    'Gesicht': [false, false],
    'Samt': [false, false],
    'Kirche': [false, false],
    'Tulpe': [false, false],
    'Rot': [false, false],
  };

  @override
  String get assessmentName => 'MoCA 5min';

  @override
  void initState() {
    super.initState();
    if (widget.assessmentData.isNotEmpty) {
      _initializeFromData(widget.assessmentData);
    }
  }

  // Helper methods
  void _initializeFromData(Map<String, dynamic> data) {
    final assessmentData = data['data'] ?? data;
    setState(() {
      _selectedAnamnese = _parseIntValue(assessmentData, 'anamnese');
      _anamneseKommentar.text = assessmentData['anamnese_kommentar']?.toString() ?? '';
      
      if (assessmentData.containsKey('word_recognition')) {
        final wordRecognitionData = List<bool>.from(assessmentData['word_recognition']);
        _wordRecognition = {
          'Gesicht': wordRecognitionData[0],
          'Samt': wordRecognitionData[1],
          'Kirche': wordRecognitionData[2],
          'Tulpe': wordRecognitionData[3],
          'Rot': wordRecognitionData[4],
        };
      }

      if (assessmentData.containsKey('orientation')) {
        final orientationData = List<bool>.from(assessmentData['orientation']);
        _orientation = {
          'Tag': orientationData[0],
          'Monat': orientationData[1],
          'Jahr': orientationData[2],
          'Wochentag': orientationData[3],
          'Ort': orientationData[4],
          'Stadt': orientationData[5],
        };
      }

      if (assessmentData.containsKey('memory_recall')) {
        final memoryRecallData = assessmentData['memory_recall'] as List<dynamic>;
        _memoryRecall = {
          'Gesicht': _convertToBoolList(memoryRecallData[0]),
          'Samt': _convertToBoolList(memoryRecallData[1]),
          'Kirche': _convertToBoolList(memoryRecallData[2]),
          'Tulpe': _convertToBoolList(memoryRecallData[3]),
          'Rot': _convertToBoolList(memoryRecallData[4]),
        };
      }
      
      _counterStopwatch = _parseIntValue(assessmentData, 'counter_stopwatch');
    });
  }

  List<bool> _convertToBoolList(dynamic value) {
    if (value is List) {
      return value.map((item) {
        if (item is bool) return item;
        if (item is String) return item.toLowerCase() == 'true';
        return false;
      }).toList();
    }
    return [false, false];
  }

  int? _parseIntValue(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) {
      final value = data[key];
      if (value is int) return value;
      if (value is String) {
        if (value.toLowerCase() == 'null' || value == 'None') return null;
        return int.tryParse(value);
      }
    }
    return null;
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

  @override
  Future<void> saveAssessment() async {
    if (_selectedAnamnese == null) {
      showError('Bitte wählen Sie eine Informationsquelle aus.');
      return;
    }

    try {
      final totalScore = _calculateTotalScore();
      final result = await ApiService.saveAssessment(
        widget.patientId,
        assessmentName,
        {
          'anamnese': _selectedAnamnese?.toString() ?? '',
          'anamnese_kommentar': _anamneseKommentar.text,
          'word_recognition': _wordRecognition.values.toList(),
          'counter_stopwatch': _counterStopwatch?.toString() ?? '',
          'orientation': _orientation.values.toList(),
          'memory_recall': _memoryRecall.values.map((list) => list.map((e) => e).toList()).toList(),
          'total_score': totalScore?.toString() ?? 'None',
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

  @override
  Future<Map<String, dynamic>> loadAssessment() async {
    try {
      return await ApiService.getLastAssessment(
        widget.patientId,
        assessmentName,
      );
    } catch (e) {
      showError('Fehler beim Laden des Assessments: $e');
      return {};
    }
  }

  @override
  Widget buildAssessmentContent() {
    return Column(
      children: [
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildWordRecognitionSection(),
        const SizedBox(height: 16),
        _buildLanguageSection(),
        const SizedBox(height: 16),
        _buildOrientationSection(),
        const SizedBox(height: 16),
        _buildMemoryRecallSection(),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: saveAssessment,
          child: const Text('Assessment Speichern'),
        ),
      ],
    );
  }

  // Section builders
  Widget _buildAnamneseSection() {
    return buildButtonSection(
      'Anamnese-Quelle',
      [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          controller: _anamneseKommentar,
          decoration: const InputDecoration(labelText: 'Anamnese-Quelle Kommentar'),
        ),
      ],
      'Anamnese Information:\n0 = Eigenanamnese\n1 = Auskunft verweigert\n2 = keine Auskunft möglich',
      isAnswered: _selectedAnamnese != null,
    );
  }

  Widget _buildWordRecognitionSection() {
    return buildButtonSection(
      'Wortwiedererkennung',
      _wordRecognition.keys.map((word) => 
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(word, style: const TextStyle(fontSize: 16)),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                      label: const Text('Richtig'),
                      selected: _wordRecognition[word] == true,
                      selectedColor: Colors.green.shade100,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _wordRecognition[word] = true);
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Falsch'),
                      selected: _wordRecognition[word] == false,
                      selectedColor: Colors.red.shade100,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _wordRecognition[word] = false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).toList(),
      'Hinweis Interviewer:in: Lesen Sie die komplette folgende Wortliste laut vor und lassen Sie den Patienten/die Patientin die Wörter wiederholen. Bitte markieren Sie, welche Wörter korrekt wiederholt wurden.',
      isAnswered: true,
    );
  }

  Widget _buildLanguageSection() {
    return buildButtonSection(
      'Sprache',
      [
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Erreichte Punkte',
            border: const OutlineInputBorder(),
            fillColor: _counterStopwatch == null ? Colors.orange.withOpacity(0.1) : null,
            filled: _counterStopwatch == null,
          ),
          controller: TextEditingController(text: _counterStopwatch?.toString() ?? ''),
          onChanged: (value) {
            setState(() => _counterStopwatch = int.tryParse(value));
          },
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      _counterStopwatch = count > 9 ? 9 : count;
                    });
                  },
                ),
              ),
            );
          },
          child: const Text('Zur Stoppuhr'),
        ),
      ],
      'Bitten Sie den Patienten/die Patientin innerhalb von einer Minute möglichst viele Tiernamen zu nennen. Jedes korrekt benannte Tier gibt 0,5 Punkte bis zu einem Maximum von 9 Punkten.',
      isAnswered: _counterStopwatch != null,
    );
  }

  Widget _buildOrientationSection() {
    return buildButtonSection(
      'Orientierung',
      _orientation.keys.map((item) => 
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(item, style: const TextStyle(fontSize: 16)),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                      label: const Text('Richtig'),
                      selected: _orientation[item] == true,
                      selectedColor: Colors.green.shade100,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _orientation[item] = true);
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Falsch'),
                      selected: _orientation[item] == false,
                      selectedColor: Colors.red.shade100,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _orientation[item] = false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).toList(),
      'Hinweis für Interviewer:in: Fragen Sie nach dem aktuellen Datum (Tag, Monat, Jahr), dem Wochentag, dem Ort und der Stadt.',
      isAnswered: true,
    );
  }

  Widget _buildMemoryRecallSection() {
    return buildButtonSection(
      'Gedächtnis',
      _memoryRecall.keys.map((word) => 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
              child: Text(word, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            // Without hint row
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text('Ohne Hinweis:', style: TextStyle(fontSize: 14)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ChoiceChip(
                          label: const Text('Richtig'),
                          selected: _memoryRecall[word]![0] == true,
                          selectedColor: Colors.green.shade100,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _memoryRecall[word]![0] = true);
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Falsch'),
                          selected: _memoryRecall[word]![0] == false,
                          selectedColor: Colors.red.shade100,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _memoryRecall[word]![0] = false);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // With hint row
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text('Mit Hinweis:', style: TextStyle(fontSize: 14)),
                  ),
                  Expanded(
                    flex: 3, 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ChoiceChip(
                          label: const Text('Richtig'),
                          selected: _memoryRecall[word]![1] == true,
                          selectedColor: Colors.green.shade100,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _memoryRecall[word]![1] = true);
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Falsch'),
                          selected: _memoryRecall[word]![1] == false,
                          selectedColor: Colors.red.shade100,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _memoryRecall[word]![1] = false);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ).toList(),
      'Hinweis für Interviewer:in: Bitten Sie den Patienten/die Patientin, die zu Beginn genannten Begriffe erneut zu wiederholen.',
      isAnswered: true,
    );
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    super.dispose();
  }
}
