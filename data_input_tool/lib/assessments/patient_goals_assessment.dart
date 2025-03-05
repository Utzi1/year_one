import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

class PatientGoalsAssessment extends BaseAssessment {
  const PatientGoalsAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<PatientGoalsAssessment> createState() => _PatientGoalsAssessmentState();
}

class _PatientGoalsAssessmentState extends BaseAssessmentState<PatientGoalsAssessment> {
  Map<String, dynamic> _lastAssessmentData = {};
  
  // Information source
  int? _selectedAnamnese;
  final TextEditingController _anamneseKommentar = TextEditingController();

  // Treatment goals
  final Set<int> _treatmentGoals = {};
  final TextEditingController _otherTreatmentGoal = TextEditingController();

  // Activity goals
  final Set<int> _activityGoals = {};
  final TextEditingController _otherActivityGoal = TextEditingController();

  // Healthcare proxy
  int? _hasProxy;
  final Set<int> _proxyDocuments = {};
  final TextEditingController _otherProxyDocument = TextEditingController();
  int? _documentAvailable;

  // Living will
  int? _hasLivingWill;

  // Option maps
  final Map<int, String> anamneseInfo = {
    0: 'Eigenanamnese',
    1: 'Fremdanamnese',
    2: 'Aktenanamnese',
    3: 'Auskunft verweigert',
    4: 'keine Auskunft möglich',
  };

  final Map<int, String> treatmentGoalsInfo = {
    0: 'Verringerung der Belastung durch bestimmte Symptome',
    1: 'Verlängerung von Lebenszeit',
    2: 'Verhinderung von weiteren Erkrankungen',
    3: 'Minimierung von Medikamentennebenwirkungen',
    4: 'Wiedererlangung von Selbstständigkeit und Mobilität im Alltag',
    5: 'Möglichst rasche Rückkehr in das gewohnte Lebensumfeld',
    6: 'Erleben spezifischer Anlässe',
    98: 'Anderes',
  };

  final Map<int, String> activityGoalsInfo = {
    0: 'Selbstversorgung, z.B. selbstständig einkaufen gehen können',
    1: 'In der eigenen Wohnung mit Unterstützung leben können',
    2: 'In der eigenen Wohnung ohne Unterstützung leben können',
    3: 'Selbstständig die Toilette besuchen können',
    4: 'Mit den (Ur-)Enkelkindern spielen können',
    5: 'Den Partner/die Partnerin mit versorgen/pflegen können',
    6: 'Berufliche oder ehrenamtliche Tätigkeit ausüben',
    7: 'Hobbys und Freizeitaktivitäten ausüben',
    98: 'Anderes',
  };

  final Map<int, String> hasProxyInfo = {
    1: 'Ja',
    2: 'Nein, ich würde aber gerne jemanden benennen',
    0: 'Nein, möchte ich auch nicht',
    99: 'Weiß nicht/unklar',
  };

  final Map<int, String> proxyDocumentsInfo = {
    0: 'Vollmacht (z.B. General- oder Vorsorgevollmacht)',
    1: 'Gesetzliche Betreuung',
    2: 'Betreuungsverfügung',
    98: 'Andere',
  };

  final Map<int, String> documentAvailableInfo = {
    1: 'Ja, liegt in der Klinik vor',
    0: 'Nein, liegt nicht vor',
    99: 'Weiß nicht/unklar',
  };

  final Map<int, String> livingWillInfo = {
    1: 'Ja, liegt in der Klinik vor',
    2: 'Ja, liegt aber nicht vor',
    0: 'Nein, will auch keine erstellen',
    3: 'Nein, würde aber gerne in der Klinik eine erstellen',
    4: 'Nein, würde aber gerne eine nach dem Klinikaufenthalt erstellen',
    99: 'Weiß nicht/unklar',
  };

  @override
  String get assessmentName => 'Patient:innenzentrierte Ziele';

  @override
  Future<Map<String, dynamic>> loadAssessment() async {
    try {
      final data = await ApiService.getLastAssessment(widget.patientId, assessmentName);
      setState(() {
        _lastAssessmentData = data;
      });
      return data;
    } catch (e) {
      if (mounted) {
        showError('Fehler beim Laden des letzten Assessments: $e');
      }
      return {};
    }
  }

  bool validateForm() {
    if (_selectedAnamnese == null) {
      showError('Bitte wählen Sie eine Informationsquelle aus.');
      return false;
    }

    if (_treatmentGoals.contains(98) && _otherTreatmentGoal.text.trim().isEmpty) {
      showError('Bitte geben Sie das andere Behandlungsziel an.');
      return false;
    }

    if (_activityGoals.contains(98) && _otherActivityGoal.text.trim().isEmpty) {
      showError('Bitte geben Sie das andere Aktivitätsziel an.');
      return false;
    }

    if (_proxyDocuments.contains(98) && _otherProxyDocument.text.trim().isEmpty) {
      showError('Bitte geben Sie das andere Dokument an.');
      return false;
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
          'treatment_goals': _treatmentGoals.toList(),
          'other_treatment_goal': _otherTreatmentGoal.text,
          'activity_goals': _activityGoals.toList(),
          'other_activity_goal': _otherActivityGoal.text,
          'has_proxy': _hasProxy?.toString() ?? 'None',
          'proxy_documents': _proxyDocuments.toList(),
          'other_proxy_document': _otherProxyDocument.text,
          'document_available': _documentAvailable?.toString() ?? 'None',
          'has_living_will': _hasLivingWill?.toString() ?? 'None',
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
  Widget buildAssessmentContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_lastAssessmentData.isNotEmpty) ...[
            buildLastAssessment(),
            const SizedBox(height: 24),
            const Divider(),
          ],
          const SizedBox(height: 16),
          _buildAnamneseSection(),
          const SizedBox(height: 16),
          _buildTreatmentGoalsSection(),
          const SizedBox(height: 16),
          _buildActivityGoalsSection(),
          const SizedBox(height: 16),
          _buildProxySection(),
          const SizedBox(height: 16),
          _buildLivingWillSection(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: saveAssessment,
            child: const Text('Assessment Speichern'),
          ),
        ],
      ),
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
    );
  }

  Widget _buildTreatmentGoalsSection() {
    return buildButtonSection(
      'Behandlungsziele',
      [
        const Text(
          'Was sind Ihre wichtigsten Anliegen und Wünsche an die aktuelle Behandlung im Krankenhaus?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...treatmentGoalsInfo.entries.map((entry) => CheckboxListTile(
          title: Text(entry.value),
          value: _treatmentGoals.contains(entry.key),
          onChanged: (checked) {
            setState(() {
              if (checked ?? false) {
                _treatmentGoals.add(entry.key);
              } else {
                _treatmentGoals.remove(entry.key);
              }
            });
          },
        )),
        if (_treatmentGoals.contains(98)) ...[
          TextField(
            controller: _otherTreatmentGoal,
            decoration: const InputDecoration(
              labelText: 'Anderes Behandlungsziel',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
      'Bitte wählen Sie alle zutreffenden Ziele aus.',
    );
  }

  Widget _buildActivityGoalsSection() {
    return buildButtonSection(
      'Aktivitäts- und Teilhabeziele',
      [
        const Text(
          'Was erhoffen Sie sich persönlich, mittelfristig nach dem aktuellen Krankenhausaufenthalt wieder als Aktivitäts-/Teilhabeziel tun zu können, was jetzt aktuell vielleicht nicht möglich ist?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...activityGoalsInfo.entries.map((entry) => CheckboxListTile(
          title: Text(entry.value),
          value: _activityGoals.contains(entry.key),
          onChanged: (checked) {
            setState(() {
              if (checked ?? false) {
                _activityGoals.add(entry.key);
              } else {
                _activityGoals.remove(entry.key);
              }
            });
          },
        )),
        if (_activityGoals.contains(98)) ...[
          TextField(
            controller: _otherActivityGoal,
            decoration: const InputDecoration(
              labelText: 'Anderes Aktivitätsziel',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
      'Bitte wählen Sie alle zutreffenden Aktivitätsziele aus.',
    );
  }

  Widget _buildProxySection() {
    return Column(
      children: [
        buildButtonSection(
          'Gesundheitliche Vollmacht',
          [
            const Text(
              'Gibt es eine Person, die Sie bei Gesundheitsthemen im Rahmen einer Vollmacht oder Betreuung unterstützt?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...hasProxyInfo.entries.map((entry) => RadioListTile<int>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _hasProxy,
              onChanged: (value) => setState(() => _hasProxy = value),
            )),
          ],
          'Vollmacht oder Betreuung umfasst hierbei eine General- oder Vorsorgevollmacht (inkl. Gesundheitsfürsorge), eine Betreuungsverfügung und eine gesetzliche Betreuung.',
        ),
        if (_hasProxy == 1) ...[
          const SizedBox(height: 16),
          buildButtonSection(
            'Dokumente',
            [
              ...proxyDocumentsInfo.entries.map((entry) => CheckboxListTile(
                title: Text(entry.value),
                value: _proxyDocuments.contains(entry.key),
                onChanged: (checked) {
                  setState(() {
                    if (checked ?? false) {
                      _proxyDocuments.add(entry.key);
                    } else {
                      _proxyDocuments.remove(entry.key);
                    }
                  });
                },
              )),
              if (_proxyDocuments.contains(98)) ...[
                TextField(
                  controller: _otherProxyDocument,
                  decoration: const InputDecoration(
                    labelText: 'Anderes Dokument',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Liegt das entsprechende Dokument vor?'),
              ...documentAvailableInfo.entries.map((entry) => RadioListTile<int>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: _documentAvailable,
                onChanged: (value) => setState(() => _documentAvailable = value),
              )),
            ],
            'Bitte wählen Sie alle zutreffenden Dokumente aus.',
          ),
        ],
      ],
    );
  }

  Widget _buildLivingWillSection() {
    return buildButtonSection(
      'Patientenverfügung',
      [
        const Text(
          'Haben Sie eine Patientenverfügung erstellt?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...livingWillInfo.entries.map((entry) => RadioListTile<int>(
          title: Text(entry.value),
          value: entry.key,
          groupValue: _hasLivingWill,
          onChanged: (value) => setState(() => _hasLivingWill = value),
        )),
      ],
      'Bitte wählen Sie eine Option aus.',
    );
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    _otherTreatmentGoal.dispose();
    _otherActivityGoal.dispose();
    _otherProxyDocument.dispose();
    super.dispose();
  }
}
