import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

class SozialanamneseAssessment extends BaseAssessment {
  const SozialanamneseAssessment({
    required super.patientId, 
    required super.assessmentData,
  });

  @override
  State<SozialanamneseAssessment> createState() => _SozialanamneseAssessmentState();
}

class _SozialanamneseAssessmentState extends BaseAssessmentState<SozialanamneseAssessment> {
  // Last assessment data
  Map<String, dynamic> _lastAssessmentData = {};

  // Anamnese information
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();
  
  // Care level
  int? _careLevel;
  int? _careLevelNumber;  // 1-5 when careLevel is 0 (Yes)
  
  // Living situation
  int? _livingPlace;
  final TextEditingController _livingPlaceOther = TextEditingController();
  
  // Living companions (multiple choice)
  final Set<int> _livingWith = {};
  final TextEditingController _livingWithOther = TextEditingController();
  
  // Stairs
  int? _hasStairs;
  final TextEditingController _numberOfStairs = TextEditingController();
  
  // Social contacts
  int? _regularContacts;
  
  // Aids and help
  int? _usesAids;
  final Set<int> _selectedAids = {};
  final TextEditingController _aidsOther = TextEditingController();
  int? _receivesHelp;
  final Set<int> _helpSources = {};
  final TextEditingController _helpSourceOther = TextEditingController();

  // Option maps
  final Map<int, String> anamneseInfo = {
    0: 'Eigenanamnese',
    1: 'Fremdanamnese',
    2: 'Aktenanamnese',
    3: 'Auskunft verweigert',
    4: 'keine Auskunft möglich',
  };

  final Map<int, String> careLevelInfo = {
    0: 'Ja',
    1: 'Nein',
    2: 'Beantragt',
    99: 'Teilnehmer:in weiß es nicht',
    100: 'Teilnehmer:in verweigert Antwort',
  };

  final Map<int, String> livingPlaceInfo = {
    0: 'Haus',
    1: 'Wohnung',
    2: 'Betreutes/seniorengerechtes Wohnen',
    3: 'Senioren-/Pflegeheim',
    98: 'Anderes',
    99: 'Teilnehmer:in weiß es nicht',
    100: 'Teilnehmer:in verweigert Antwort',
  };

  final Map<int, String> livingWithInfo = {
    0: 'Alleine',
    1: '(Ehe-)Partner/Partnerin',
    2: '(Enkel-)Kinder',
    3: 'Sonstige Familienangehörige',
    4: '24h-Pflegekraft/Betreuungskraft',
    98: 'Anderes',
    99: 'Teilnehmer:in weiß es nicht',
    100: 'Teilnehmer:in verweigert Antwort',
  };

  final Map<int, String> stairsInfo = {
    0: 'Ja',
    1: 'Nein',
    99: 'Teilnehmer:in weiß es nicht',
    100: 'Teilnehmer:in verweigert Antwort',
  };

  final Map<int, String> contactsInfo = {
    0: 'Keine regelmäßigen Kontakte',
    1: 'Mit 1-2 Menschen',
    2: 'Mit > 2 Menschen',
    99: 'Teilnehmer:in weiß es nicht',
    100: 'Teilnehmer:in verweigert Antwort',
  };

  final Map<int, String> aidsInfo = {
    0: 'Gehstock',
    1: 'Unterarmgehstütze (Krücke)',
    2: 'Rollator',
    3: 'Rollstuhl',
    4: 'Hausnotruf',
    5: 'Haltegriffe',
    6: 'Toilettensitzerhöhung',
    7: 'Toilettenstuhl',
    8: 'Duschhocker',
    9: 'Badewannenlift',
    10: 'Pflegebett',
    11: 'Dekubitusmatratze',
    12: 'Heim-O2',
    13: 'Andere',
  };

  final Map<int, String> helpSourcesInfo = {
    0: 'Pflegedienst (ambulant)',
    1: 'Partner/Partnerin',
    2: 'Angehörige',
    3: 'Freunde',
    4: '24h-Pflegekraft',
    5: 'Anderes',
  };

  @override
  String get assessmentName => 'Sozialanamnese Assessment';

  @override
  void initState() {
    super.initState();
    if (widget.assessmentData.isNotEmpty) {
      _initializeFromExistingData(widget.assessmentData);
    }
    _initializeData();
  }

  void _initializeFromExistingData(Map<String, dynamic> data) {
    final assessmentData = data['data'] ?? data;
    setState(() {
      _selectedAnamnese = _parseIntValue(assessmentData, 'anamnese');
      _anamneseKommentar.text = assessmentData['anamnese_kommentar']?.toString() ?? '';
      
      _careLevel = _parseIntValue(assessmentData, 'care_level');
      _careLevelNumber = _parseIntValue(assessmentData, 'care_level_number');
      
      _livingPlace = _parseIntValue(assessmentData, 'living_place');
      _livingPlaceOther.text = assessmentData['living_place_other']?.toString() ?? '';
      
      _livingWith.clear();
      if (assessmentData['living_with'] is List) {
        _livingWith.addAll((assessmentData['living_with'] as List).cast<int>());
      }
      _livingWithOther.text = assessmentData['living_with_other']?.toString() ?? '';
      
      _hasStairs = _parseIntValue(assessmentData, 'has_stairs');
      _numberOfStairs.text = assessmentData['number_of_stairs']?.toString() ?? '';
      
      _regularContacts = _parseIntValue(assessmentData, 'regular_contacts');
      
      _usesAids = _parseIntValue(assessmentData, 'uses_aids');
      _selectedAids.clear();
      if (assessmentData['selected_aids'] is List) {
        _selectedAids.addAll((assessmentData['selected_aids'] as List).cast<int>());
      }
      _aidsOther.text = assessmentData['aids_other']?.toString() ?? '';
      
      _receivesHelp = _parseIntValue(assessmentData, 'receives_help');
      _helpSources.clear();
      if (assessmentData['help_sources'] is List) {
        _helpSources.addAll((assessmentData['help_sources'] as List).cast<int>());
      }
      _helpSourceOther.text = assessmentData['help_source_other']?.toString() ?? '';
    });
  }

  /// Safely parses an integer value from assessment data
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

  /// Initialize data from API and handle errors
  void _initializeData() async {
    try {
      final data = await loadAssessment();
      if (mounted && data.isNotEmpty) {
        setState(() {
          _lastAssessmentData = Map<String, dynamic>.from({
            'timestamp': data['timestamp'],
            'unix_timestamp': data['unix_timestamp'],
            'key': data['key'],
            ...data['data'] ?? {},
          });
          _initializeFromExistingData(data);
        });
      }
    } catch (e) {
      if (mounted) {
        showError('Fehler beim Laden des Assessments: $e');
      }
    }
  }

  bool validateForm() {
    if (_selectedAnamnese == null) {
      showError('Bitte wählen Sie eine Informationsquelle aus.');
      return false;
    }

    if (_careLevel == 0 && (_careLevelNumber == null || _careLevelNumber! < 1 || _careLevelNumber! > 5)) {
      showError('Bitte geben Sie einen gültigen Pflegegrad (1-5) ein.');
      return false;
    }

    if (_hasStairs == 0) {
      final stairs = int.tryParse(_numberOfStairs.text);
      if (stairs == null || stairs < 1 || stairs > 200) {
        showError('Bitte geben Sie eine gültige Anzahl von Stufen (1-200) ein.');
        return false;
      }
    }

    return true;
  }

  @override
  Future<void> saveAssessment() async {
    if (!validateForm()) return;

    try {
      final result = await ApiService.saveAssessment(
        widget.patientId,
        assessmentName,
        {
          'anamnese': _selectedAnamnese.toString(),
          'anamnese_kommentar': _anamneseKommentar.text,
          'care_level': _careLevel?.toString() ?? 'None',
          'care_level_number': _careLevelNumber?.toString() ?? 'None',
          'living_place': _livingPlace?.toString() ?? 'None',
          'living_place_other': _livingPlaceOther.text,
          'living_with': _livingWith.toList(),
          'living_with_other': _livingWithOther.text,
          'has_stairs': _hasStairs?.toString() ?? 'None',
          'number_of_stairs': _numberOfStairs.text,
          'regular_contacts': _regularContacts?.toString() ?? 'None',
          'uses_aids': _usesAids?.toString() ?? 'None',
          'selected_aids': _selectedAids.toList(),
          'aids_other': _aidsOther.text,
          'receives_help': _receivesHelp?.toString() ?? 'None',
          'help_sources': _helpSources.toList(),
          'help_source_other': _helpSourceOther.text,
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
        if (_lastAssessmentData.isNotEmpty) ...[
          buildLastAssessment(),
          const SizedBox(height: 24),
          const Divider(),
        ],
        const SizedBox(height: 16),
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildCareLevelSection(),
        const SizedBox(height: 16),
        _buildLivingSection(),
        const SizedBox(height: 16),
        _buildStairsSection(),
        const SizedBox(height: 16),
        _buildContactsSection(),
        const SizedBox(height: 16),
        _buildAidsSection(),
        const SizedBox(height: 16),
        _buildHelpSection(),
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
          items: anamneseInfo.keys.toList(),
          onChanged: (value) => setState(() => _selectedAnamnese = value),
          itemInfo: anamneseInfo,
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

  Widget _buildCareLevelSection() {
    return buildButtonSection(
      'Pflegegrad',
      [
        ...careLevelInfo.entries.map((entry) => RadioListTile<int>(
          title: Text(entry.value),
          value: entry.key,
          groupValue: _careLevel,
          onChanged: (value) => setState(() => _careLevel = value),
        )),
        if (_careLevel == 0) ...[  // Show number input only if "Ja" is selected
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Pflegegrad (1-5)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final number = int.tryParse(value);
              if (number != null && number >= 1 && number <= 5) {
                setState(() => _careLevelNumber = number);
              }
            },
          ),
        ],
      ],
      'Haben Sie einen Pflegegrad?',
      isAnswered: _careLevel != null,
    );
  }

  Widget _buildLivingSection() {
    return buildButtonSection(
      'Wohnsituation',
      [
        ...livingPlaceInfo.entries.map((entry) => RadioListTile<int>(
          title: Text(entry.value),
          value: entry.key,
          groupValue: _livingPlace,
          onChanged: (value) => setState(() => _livingPlace = value),
        )),
        if (_livingPlace == 98) ...[  // Show text input if "Anderes" is selected
          const SizedBox(height: 16),
          TextField(
            controller: _livingPlaceOther,
            decoration: const InputDecoration(
              labelText: 'Andere Wohnform',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
      'Wo leben Sie?',
      isAnswered: _livingPlace != null,
    );
  }

  Widget _buildStairsSection() {
    return buildButtonSection(
      'Treppen',
      [
        ...stairsInfo.entries.map((entry) => RadioListTile<int>(
          title: Text(entry.value),
          value: entry.key,
          groupValue: _hasStairs,
          onChanged: (value) => setState(() => _hasStairs = value),
        )),
        if (_hasStairs == 0) ...[  // Show number input if "Ja" is selected
          const SizedBox(height: 16),
          TextField(
            controller: _numberOfStairs,
            decoration: const InputDecoration(
              labelText: 'Anzahl der Stufen (1-200)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ],
      'Müssen Sie eine Treppe steigen, um in Ihre Wohnung/Ihr Haus zu kommen, und/oder innerhalb Ihres Hauses oder Ihrer Wohnung Treppen steigen?\n\nHinweis: Es zählen nur Stufen, die gestiegen werden müssen, nicht Stufen, für die ein Treppenlift oder Aufzug vorhanden ist.',
      isAnswered: _hasStairs != null,
    );
  }

  Widget _buildContactsSection() {
    return buildButtonSection(
      'Soziale Kontakte',
      [
        ...contactsInfo.entries.map((entry) => RadioListTile<int>(
          title: Text(entry.value),
          value: entry.key,
          groupValue: _regularContacts,
          onChanged: (value) => setState(() => _regularContacts = value),
        )),
      ],
      'Mit wie vielen Angehörigen und/oder Freunden/Bekannten haben Sie regelmäßig Kontakt (≥ 1 x/Woche)?',
      isAnswered: _regularContacts != null,
    );
  }

  Widget _buildAidsSection() {
    return buildButtonSection(
      'Hilfsmittel',
      [
        RadioListTile<int>(
          title: const Text('Ja'),
          value: 0,
          groupValue: _usesAids,
          onChanged: (value) => setState(() => _usesAids = value),
        ),
        if (_usesAids == 0) ...[
          ...aidsInfo.entries.map((entry) => CheckboxListTile(
            title: Text(entry.value),
            value: _selectedAids.contains(entry.key),
            onChanged: (bool? checked) {
              setState(() {
                if (checked ?? false) {
                  _selectedAids.add(entry.key);
                } else {
                  _selectedAids.remove(entry.key);
                }
              });
            },
          )),
          if (_selectedAids.contains(13)) ...[  // Show text input if "Andere" is selected
            TextField(
              controller: _aidsOther,
              decoration: const InputDecoration(
                labelText: 'Andere Hilfsmittel',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
        ...{1: 'Keine', 99: 'Weiß nicht', 100: 'Verweigert'}.entries.map((entry) => 
          RadioListTile<int>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: _usesAids,
            onChanged: (value) => setState(() {
              _usesAids = value;
              _selectedAids.clear();
            }),
          ),
        ),
      ],
      'Nutzen Sie Hilfsmittel, z.B. einen Gehstock, Hausnotruf, Haltegriffe, Duschhocker, oder Heim-Sauerstoff?',
      isAnswered: _usesAids != null,
    );
  }

  Widget _buildHelpSection() {
    return buildButtonSection(
      'Unterstützung',
      [
        RadioListTile<int>(
          title: const Text('Ja'),
          value: 0,
          groupValue: _receivesHelp,
          onChanged: (value) => setState(() => _receivesHelp = value),
        ),
        if (_receivesHelp == 0) ...[
          ...helpSourcesInfo.entries.map((entry) => CheckboxListTile(
            title: Text(entry.value),
            value: _helpSources.contains(entry.key),
            onChanged: (bool? checked) {
              setState(() {
                if (checked ?? false) {
                  _helpSources.add(entry.key);
                } else {
                  _helpSources.remove(entry.key);
                }
              });
            },
          )),
          if (_helpSources.contains(5)) ...[  // Show text input if "Andere" is selected
            TextField(
              controller: _helpSourceOther,
              decoration: const InputDecoration(
                labelText: 'Andere Unterstützung',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
        ...{1: 'Nein', 99: 'Weiß nicht', 100: 'Verweigert'}.entries.map((entry) => 
          RadioListTile<int>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: _receivesHelp,
            onChanged: (value) => setState(() {
              _receivesHelp = value;
              _helpSources.clear();
            }),
          ),
        ),
      ],
      'Erhalten Sie Hilfe bei der alltäglichen Versorgung?',
      isAnswered: _receivesHelp != null,
    );
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    _livingPlaceOther.dispose();
    _livingWithOther.dispose();
    _numberOfStairs.dispose();
    _aidsOther.dispose();
    _helpSourceOther.dispose();
    super.dispose();
  }
}
