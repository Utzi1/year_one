import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StandardAssessment extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> assessmentData;
  final String assessmentName;

  const StandardAssessment({
    required this.patientId,
    required this.assessmentData,
    required this.assessmentName,
    super.key,
  });

  @override
  _StandardAssessmentState createState() => _StandardAssessmentState();
}

class _StandardAssessmentState extends State<StandardAssessment> {
  // Standard properties
  bool _isLoading = false;
  Map<String, dynamic> _lastAssessmentData = {};
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _dataSourceController = TextEditingController();

  // Standard methods
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
      _commentController.text = assessmentData['comment']?.toString() ?? '';
      _dataSourceController.text = assessmentData['data_source']?.toString() ?? '';
      // Add specific initialization here
    });
  }

  Future<void> _initializeData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final data = await ApiService.getLastAssessment(widget.patientId, widget.assessmentName);
      if (data.isNotEmpty && !data.containsKey('error')) {
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
      _showError('Fehler beim Laden: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
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
  }

  Widget _buildLastAssessment() {
    if (_lastAssessmentData.isEmpty) return const SizedBox.shrink();

    final timestamp = _lastAssessmentData['timestamp'] ?? 'Unbekannt';
    final assessmentData = Map<String, dynamic>.from(_lastAssessmentData)
      ..removeWhere((key, value) => ['timestamp', 'unix_timestamp', 'key'].contains(key));

    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vorheriges Assessment (${timestamp}):',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...assessmentData.entries.map(
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
    );
  }

  Widget _buildDataSourceField() {
    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datenquelle',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _dataSourceController,
            decoration: const InputDecoration(
              labelText: 'Quelle der Daten',
              border: OutlineInputBorder(),
              hintText: 'z.B. Patient, Angehörige, Krankenakte',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentField() {
    return _buildContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kommentar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Zusätzliche Informationen',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
