import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// A widget that allows users to create patients by selecting a department.
class CreatePatientByDepartment extends StatefulWidget {
  const CreatePatientByDepartment({super.key});

  @override
  CreatePatientByDepartmentState createState() => CreatePatientByDepartmentState();
}

/// The state for the CreatePatientByDepartment widget.
class CreatePatientByDepartmentState extends State<CreatePatientByDepartment> {
  // Controllers for the text fields
  final TextEditingController _ageController = TextEditingController();
  // Key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Map to store patient counters by department
  final Map<String, int> _patientCounters = {
    '21': 1,
    '22': 1,
    '23': 1,
    '99': 1,
  };
  // Map to store patient IDs by department
  final Map<String, List<String>> _patientIdsByDepartment = {
    '21': [],
    '22': [],
    '23': [],
    '99': [],
  };
  // Variable to store the selected department
  String? _selectedDepartment;
  // Variable to store the selected gender
  String? _selectedGender;
  // Variable to store the created patient ID
  String? _createdPatientId;
  // Variable to store loading state
  bool _isLoading = false;

  /// Creates a new patient and adds it to the selected department.
  void _createPatient() async {
    if (_formKey.currentState!.validate() && _selectedDepartment != null && _selectedGender != null) {
      setState(() => _isLoading = true);
      
      try {
        final department = _selectedDepartment!;
        final gender = _selectedGender!;
        final age = int.parse(_ageController.text);
        String patientId;

        // Generate unique patient ID
        while (true) {
          patientId = '$department${_patientCounters[department]!.toString().padLeft(3, '0')}';
          final response = await ApiService.getPatient(patientId);
          if (response.containsKey('error')) {
            break;
          }
          _patientCounters[department] = _patientCounters[department]! + 1;
        }

        print('Attempting to create patient with ID: $patientId');
        final response = await ApiService.initializePatient(patientId, gender, age);
        
        if (response['success'] == true) {
          setState(() {
            _patientCounters[department] = _patientCounters[department]! + 1;
            _patientIdsByDepartment[department]!.add(patientId);
            _createdPatientId = patientId;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Patient created successfully. ID: $patientId'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception(response['message'] ?? 'Failed to initialize patient');
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating patient: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Patient by Department'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Increased padding
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display the created patient ID at the top
                if (_createdPatientId != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Patient ID Created:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          _createdPatientId!,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Department selection buttons with updated styling
                Wrap(
                  spacing: 16.0, // Horizontal spacing between buttons
                  runSpacing: 16.0, // Vertical spacing between rows
                  alignment: WrapAlignment.center,
                  children: [
                    _buildDepartmentButton('UCH', '21'),
                    _buildDepartmentButton('AVC', '22'),
                    _buildDepartmentButton('URO', '23'),
                    _buildDepartmentButton('Test', '99'),
                  ],
                ),
                
                const SizedBox(height: 32), // Increased spacing

                // Gender selection buttons with updated styling
                Wrap(
                  spacing: 16.0,
                  runSpacing: 16.0,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildGenderButton('Male'),
                    _buildGenderButton('Female'),
                    _buildGenderButton('Other'),
                  ],
                ),

                const SizedBox(height: 32),

                // Age input field with updated styling
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an age';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Create Patient button with updated styling
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createPatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Create Patient',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentButton(String label, String value) {
    return SizedBox(
      width: 120, // Fixed width for consistent sizing
      height: 50,
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedDepartment = value),
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedDepartment == value 
              ? Colors.blue 
              : Colors.grey[200],
          foregroundColor: _selectedDepartment == value 
              ? Colors.white 
              : Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: _selectedDepartment == value ? 4 : 1,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    return SizedBox(
      width: 120,
      height: 50,
      child: ElevatedButton(
        onPressed: () => setState(() => _selectedGender = gender),
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedGender == gender 
              ? Colors.blue 
              : Colors.grey[200],
          foregroundColor: _selectedGender == gender 
              ? Colors.white 
              : Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: _selectedGender == gender ? 4 : 1,
        ),
        child: Text(
          gender,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }
}
