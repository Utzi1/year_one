import 'package:flutter/material.dart';

class IsarScoreAssessment extends StatefulWidget {
  const IsarScoreAssessment({Key? key}) : super(key: key);

  @override
  State<IsarScoreAssessment> createState() => _IsarScoreAssessmentState();
}

class _IsarScoreAssessmentState extends State<IsarScoreAssessment> {
  final List<bool?> _answers = List.filled(6, null);

  static const List<Question> _questions = [
    Question(
      title: 'Hilfebedarf',
      text: 'Waren Sie vor der Erkrankung oder Verletzung, die Sie in die Klinik geführt hat, auf regelmäßige Hilfe angewiesen?',
      help: 'Hinweis an Interviewer:in: Es geht um die Zeit unmittelbar vor dem aktuellen Krankenhausaufenthalt.',
    ),
    Question(
      title: 'Akute Veränderung des Hilfebedarfs',
      text: 'Benötigten Sie in den letzten 24 Stunden mehr Hilfe als zuvor?',
      help: 'Hinweis an Interviewer:in: Es geht um den Vergleich des aktuellen Hilfebedarfs mit dem üblichen Hilfebedarf.',
    ),
    Question(
      title: 'Hospitalisation',
      text: 'Waren Sie innerhalb der letzten 6 Monate für einen oder mehrere Tage im Krankenhaus?',
      help: 'Hinweis an Interviewer:in: Alle stationären Krankenhausaufenthalte zählen, unabhängig von der Ursache.',
    ),
    Question(
      title: 'Sensorische Einschränkung',
      text: 'Haben Sie unter normalen Umständen erhebliche Probleme mit dem Sehen, die nicht mit einer Brille korrigiert werden können?',
      help: 'Hinweis an Interviewer:in: Es geht um die verbleibende Sehbeeinträchtigung trotz optimaler Korrektur (z.B. mit Brille).',
    ),
    Question(
      title: 'Kognitive Einschränkungen',
      text: 'Haben Sie ernsthafte Probleme mit dem Gedächtnis?',
      help: 'Hinweis an Interviewer:in: Bei Fremdanamnese fragen Sie nach beobachteten Gedächtnisproblemen.',
    ),
    Question(
      title: 'Multimorbidität',
      text: 'Nehmen Sie pro Tag sechs oder mehr verschiedene Medikamente ein?',
      help: 'Hinweis an Interviewer:in: Alle regelmäßig eingenommenen Medikamente zählen, unabhängig von der Darreichungsform.',
    ),
  ];

  int get _totalScore => _answers.where((answer) => answer == true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISAR Score Assessment'),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._questions.asMap().entries.map((entry) => _buildQuestionSection(entry.key, entry.value)),
              _buildScoreSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionSection(int index, Question question) {
    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(question.text),
          if (question.help != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.help!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('JA (1)'),
                selected: _answers[index] == true,
                onSelected: (selected) => setState(() => _answers[index] = selected ? true : null),
              ),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('NEIN (0)'),
                selected: _answers[index] == false,
                onSelected: (selected) => setState(() => _answers[index] = selected ? false : null),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection() {
    final score = _totalScore;
    final bool isStudyEligible = score >= 2;

    return _buildContainer(
      backgroundColor: isStudyEligible ? Colors.green.shade50 : Colors.red.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Gesamtpunktzahl'),
          Text(
            'ISAR-Score: $score/6',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!isStudyEligible) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Einschlusskriterium Studie nicht erfüllt.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContainer({required Widget child, Color? backgroundColor}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class Question {
  final String title;
  final String text;
  final String? help;

  const Question({
    required this.title,
    required this.text,
    this.help,
  });
}
