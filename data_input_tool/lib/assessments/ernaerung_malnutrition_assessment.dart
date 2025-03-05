/// The Malnutrition Assessment evaluates a patient's nutritional status and malnutrition risk.
///
/// This assessment tool collects and validates key nutritional parameters:
/// * Weight (in kg, range 10-300)
/// * Height (in m, range 1.00-3.00)
/// * Albumin levels (in g/dl, range 1.0-7.0)
/// * BMI (automatically calculated)
/// * Anamnesis source (self-reported, third-party, medical records, etc.)
///
/// Features:
/// * Automatic BMI calculation based on weight/height inputs
/// * Input validation with appropriate ranges for all measurements
/// * Normal range indicators for clinical interpretation
/// * Historical data comparison when available
/// * Comprehensive form with guided input sections
///
/// This assessment extends [BaseAssessment] and follows standard nutrition
/// screening protocols for clinical evaluation of nutritional status.


import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'base_assessment.dart';

class MalnutritionAssessment extends BaseAssessment {
  const MalnutritionAssessment({
    required super.patientId,
    required super.assessmentData,
  });

  @override
  State<MalnutritionAssessment> createState() => _MalnutritionAssessmentState();
}

class _MalnutritionAssessmentState extends BaseAssessmentState<MalnutritionAssessment> {
  // Form state variables
  int? _selectedAnamnese; // Stores the selected anamnese option
  final TextEditingController _anamneseKommentar = TextEditingController(); // Controller for anamnese comment
  final TextEditingController _weightController = TextEditingController(); // Controller for weight input
  final TextEditingController _heightController = TextEditingController(); // Controller for height input
  final TextEditingController _albuminController = TextEditingController(); // Controller for albumin input
  double? _selectedWeight; // Stores the selected weight
  double? _selectedHeight; // Stores the selected height
  double? _selectedAlbumin; // Stores the selected albumin level
  double? _bmi; // Stores the calculated BMI

  // Options for anamnese selection
  static const Map<int, String> _anamneseOptions = {
    0: 'Eigenanamnese',
    1: 'Fremdanamnese',
    2: 'Aktenanamnese',
    3: 'Auskunft verweigert',
    4: 'keine Auskunft möglich',
  };

  @override
  String get assessmentName => 'Malnutrition Assessment'; // Name of the assessment

  @override
  void initState() {
    super.initState();
    // Initialize form data if assessment data is provided
    if (widget.assessmentData.isNotEmpty) {
      _initializeFromData(widget.assessmentData);
    }
  }

  // Initialize form fields from provided assessment data
  void _initializeFromData(Map<String, dynamic> data) {
    final assessmentData = data['data'] ?? data;
    setState(() {
      _selectedAnamnese = _parseIntValue(assessmentData, 'anamnese');
      _anamneseKommentar.text = assessmentData['anamnese_kommentar']?.toString() ?? '';
      _selectedWeight = _parseDoubleValue(assessmentData, 'weight');
      _selectedHeight = _parseDoubleValue(assessmentData, 'height');
      _selectedAlbumin = _parseDoubleValue(assessmentData, 'albumin');
      _weightController.text = _selectedWeight?.toString() ?? '';
      _heightController.text = _selectedHeight?.toString() ?? '';
      _albuminController.text = _selectedAlbumin?.toString() ?? '';
      _calculateBMI();
    });
  }

  // Parse integer value from data
  int? _parseIntValue(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) {
      final value = data[key];
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
    }
    return null;
  }

  // Parse double value from data
  double? _parseDoubleValue(Map<String, dynamic> data, String key) {
    if (data.containsKey(key)) {
      final value = data[key];
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
    }
    return null;
  }

  // Calculate BMI based on weight and height
  void _calculateBMI() {
    if (_selectedWeight == null || _selectedHeight == null) {
      _bmi = null;
      return;
    }
    
    if (_selectedHeight! <= 0) {
      showError('Ungültige Körpergröße');
      _bmi = null;
      return;
    }

    setState(() {
      _bmi = _selectedWeight! / (_selectedHeight! * _selectedHeight!);
    });
  }

  @override
  Future<Map<String, dynamic>> loadAssessment() async {
    try {
      return await ApiService.getErnaehrungAssessment(widget.patientId);
    } catch (e) {
      showError('Fehler beim Laden: $e');
      return {};
    }
  }

  @override
  Future<void> saveAssessment() async {
    if (!_validateForm()) return;

    try {
      final result = await ApiService.saveAssessment(
        widget.patientId,
        assessmentName,
        _prepareDataForSave(),
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

  // Validate form fields before saving
  bool _validateForm() {
    if (_selectedAnamnese == null) {
      showError('Bitte wählen Sie eine Informationsquelle aus');
      return false;
    }

    if (_selectedWeight == null) {
      showError('Bitte geben Sie ein gültiges Gewicht ein');
      return false;
    }

    if (_selectedHeight == null) {
      showError('Bitte geben Sie eine gültige Größe ein');
      return false;
    }

    return true;
  }

  // Prepare data for saving
  Map<String, String> _prepareDataForSave() {
    return {
      'anamnese': _selectedAnamnese.toString(),
      'anamnese_kommentar': _anamneseKommentar.text,
      'weight': _selectedWeight.toString(),
      'height': _selectedHeight.toString(),
      'albumin': _selectedAlbumin?.toString() ?? '',
      'bmi': _bmi?.toString() ?? '',
    };
  }

  @override
  Widget buildAssessmentContent() {
    return Column(
      children: [
        _buildAnamneseSection(),
        const SizedBox(height: 16),
        _buildWeightSection(),
        const SizedBox(height: 16),
        _buildHeightSection(),
        const SizedBox(height: 16),
        _buildAlbuminSection(),
        const SizedBox(height: 16),
        _buildBMISection(),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: saveAssessment,
          child: const Text('Assessment Speichern'),
        ),
      ],
    );
  }

  // Build the anamnese section of the form
  Widget _buildAnamneseSection() {
    return buildButtonSection(
      'Informationsquelle',
      [
        buildActionButtonField<int>(
          value: _selectedAnamnese,
          items: _anamneseOptions.keys.toList(),
          onChanged: (value) => setState(() => _selectedAnamnese = value),
          itemInfo: _anamneseOptions,
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

  // Build the weight section of the form
  Widget _buildWeightSection() {
    return buildButtonSection(
      'Körpergewicht',
      [
        TextField(
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Gewicht in kg',
            border: const OutlineInputBorder(),
            suffixText: 'kg',
            helperText: 'Gültiger Bereich: 10 - 300 kg',
            errorText: _selectedWeight == null && _weightController.text.isNotEmpty 
                ? 'Ungültiges Gewicht' 
                : null,
          ),
          onChanged: (text) {
            final weight = double.tryParse(text);
            setState(() {
              _selectedWeight = (weight != null && weight >= 10 && weight <= 300) 
                  ? weight 
                  : null;
              _calculateBMI();
            });
          },
        ),
      ],
      'Bitte geben Sie das aktuelle Körpergewicht ein.',
      isAnswered: _selectedWeight != null,
    );
  }

  // Build the height section of the form
  Widget _buildHeightSection() {
    return buildButtonSection(
      'Körpergröße',
      [
        TextField(
          controller: _heightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Größe in m',
            border: const OutlineInputBorder(),
            suffixText: 'm',
            helperText: 'Gültiger Bereich: 1.00 - 3.00 m',
            errorText: _selectedHeight == null && _heightController.text.isNotEmpty 
                ? 'Ungültige Größe' 
                : null,
          ),
          onChanged: (text) {
            final height = double.tryParse(text);
            setState(() {
              _selectedHeight = (height != null && height >= 1.0 && height <= 3.0) 
                  ? height 
                  : null;
              _calculateBMI();
            });
          },
        ),
      ],
      'Bitte geben Sie die Körpergröße in Metern ein.',
      isAnswered: _selectedHeight != null,
    );
  }

  // Build the albumin section of the form
  Widget _buildAlbuminSection() {
    return buildButtonSection(
      'Albumin',
      [
        TextField(
          controller: _albuminController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Albumin in g/dl',
            border: const OutlineInputBorder(),
            suffixText: 'g/dl',
            helperText: 'Gültiger Bereich: 1.0 - 7.0 g/dl',
            errorText: _selectedAlbumin == null && _albuminController.text.isNotEmpty 
                ? 'Ungültiger Albuminwert' 
                : null,
          ),
          onChanged: (text) {
            final albumin = double.tryParse(text);
            setState(() {
              _selectedAlbumin = (albumin != null && albumin >= 1.0 && albumin <= 7.0) 
                  ? albumin 
                  : null;
            });
          },
        ),
      ],
      'Optional: Geben Sie den Albuminwert ein.',
      isAnswered: true, // Optional field
    );
  }

  // Build the BMI section of the form
  Widget _buildBMISection() {
    final String bmiText = _bmi != null 
        ? '${_bmi!.toStringAsFixed(1)} kg/m²'
        : 'Nicht verfügbar';

    return buildButtonSection(
      'BMI',
      [
        Text(
          bmiText,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
      'BMI = Gewicht (kg) / (Größe (m))²',
      isAnswered: _bmi != null,
    );
  }

  @override
  void dispose() {
    _anamneseKommentar.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _albuminController.dispose();
    super.dispose();
  }
}
