/// A service class to handle API requests.
///
/// This class provides methods to send and receive data from a backend API.
///
/// Methods:
/// - `postKeyValue(String key, String value)`: Sends a key-value pair to the API.
/// - `postHashMap(String identifier, String patientName, Map<String, String> data)`: Sends a hashmap along with an identifier and patient name to the API.
/// - `getHashMap(String identifier)`: Retrieves a hashmap from the API using an identifier.
/// - `createPatient(String id, String name)`: Creates a new patient record in the API.
/// - `getAssessments(String id)`: Retrieves a list of assessments for a given patient ID.
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Use localhost for macOS
  static const String baseUrl = 'http://127.0.0.1:5000/api';

  /// Retrieves a patient record from the API using an identifier.
  ///
  /// Parameters:
  /// - `id`: The identifier for the patient.
  ///
  /// Returns a map containing the status code and response body.
  static Future<Map<String, dynamic>> getPatient(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');
      if (response.statusCode == 404) {
        return {'error': 'Patient ID does not exist or might need to be created'};
      }
      return responseData;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Creates a new patient record in the API.
  ///
  /// Parameters:
  /// - `id`: The identifier for the patient.
  /// - `gender`: The gender of the patient.
  /// - `age`: The age of the patient.
  ///
  /// Returns a map containing the status code and response body.
  static Future<Map<String, dynamic>> createPatient(String id, String gender, int age) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': id, 'gender': gender, 'age': age}),
      );
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');
      print('Status code: ${response.statusCode}');
      
      // Updated success check
      final bool isSuccess = response.statusCode == 201 || response.statusCode == 200;
      
      return {
        'statusCode': response.statusCode,
        'body': responseData,
        'success': isSuccess,
        'message': responseData['message'] ?? 'Unknown error',
        'identifier': id,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Initializes a new patient with timestamp and returns the generated ID
  static Future<Map<String, dynamic>> initializePatient(String id, String gender, int age) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': id,
          'gender': gender,
          'age': age,
        }),
      );

      print('Initialize Patient - Request Body: ${jsonEncode({
        'identifier': id,
        'gender': gender,
        'age': age,
      })}');
      print('Initialize Patient - Response Status: ${response.statusCode}');
      print('Initialize Patient - Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);
      
      // Check for successful status codes (both 200 and 201 are acceptable)
      final bool isSuccess = response.statusCode == 201 || response.statusCode == 200;
      
      return {
        'statusCode': response.statusCode,
        'success': isSuccess,
        'message': responseData['message'] ?? 'Unknown error',
        'identifier': id,
      };
    } catch (e) {
      print('Initialize Patient - Error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to initialize patient: $e'
      };
    }
  }

  /// Retrieves all assessments for a given patient ID.
  ///
  /// Parameters:
  /// - `patientID`: The identifier for the patient.
  ///
  /// Returns a map containing the status code and response body.
  static Future<Map<String, dynamic>> getAssessments(String patientID) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$patientID/assessments'));
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');
      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 404) {
        return {};
      } else {
        throw Exception('Failed to load assessments');
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Saves an assessment for a given patient.
  ///
  /// Parameters:
  /// - `patientID`: The identifier for the patient.
  /// - `assessmentName`: The name of the assessment.
  /// - `data`: The assessment data to be sent.
  ///
  /// Returns a map containing the status code and response body.
  static Future<Map<String, dynamic>> saveAssessment(
    String patientID, 
    String assessmentName, 
    Map<String, dynamic> data
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$patientID/$assessmentName'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');
      return {
        'statusCode': response.statusCode,
        'success': response.statusCode == 200,
        'message': response.statusCode == 200 
          ? 'Assessment saved successfully' 
          : responseData['message'] ?? 'Failed to save assessment',
        'data': responseData
      };
    } catch (e) {
      return {
        'statusCode': 500,
        'success': false,
        'message': e.toString()
      };
    }
  }

  /// Retrieves all data associated with a given ID.
  ///
  /// Parameters:
  /// - `id`: The identifier for the request.
  ///
  /// Returns a map containing the status code and response body.
  static Future<Map<String, dynamic>> getAllData(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id/all'));
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');
      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 404) {
        return {};
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Retrieves a hashmap from the API using an identifier.
  ///
  /// Parameters:
  /// - `identifier`: The identifier for the request.
  ///
  /// Returns a map containing the status code and response body.
  static Future<Map<String, dynamic>> getHashMap(String identifier) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$identifier'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      print('Response body: ${response.body}');
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      print('Response data: $responseBody');
      return {'statusCode': response.statusCode, 'body': responseBody};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Sends a hashmap along with an identifier and patient name to the API.
  ///
  /// Parameters:
  /// - `patientID`: The identifier for the patient.
  /// - `assessmentName`: The name of the assessment.
  /// - `data`: The hashmap data to be sent.
  ///
  /// Returns a map containing the status code and response body.
  static Future<Map<String, dynamic>> postHashMap(
    String patientID, 
    String assessmentName, 
    Map<String, dynamic> data
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$patientID/$assessmentName'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');
      return {
        'statusCode': response.statusCode,
        'body': responseData,
        'message': response.statusCode == 200 ? 'Data posted successfully' : 'Failed to post data',
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Generic method to get the latest assessment
  static Future<Map<String, dynamic>> getLastAssessment(String patientID, String assessmentName) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$patientID/$assessmentName/latest'));
      print('Response body: ${response.body}');
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');
      if (response.statusCode == 200) {
        return {
          'success': true,
          'timestamp': responseData['timestamp'],
          'unix_timestamp': responseData['unix_timestamp'],
          'data': Map<String, dynamic>.from(responseData['data'] ?? {}),
          'key': responseData['key']
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'No assessment found'};
      } else {
        throw Exception('Failed to load $assessmentName');
      }
    } catch (e) {
      print('Error in getLastAssessment: $e');
      return {'error': e.toString()};
    }
  }

  /// Due to an inconsistency:

  /// Retrieves the latest MoCA 5-minute assessment for a patient
  static Future<Map<String, dynamic>> getMoCA5MinAssessment(String patientId) async {
    return await getLastAssessment(patientId, 'MoCA 5min');
  }

  /// Retrieves the latest Barthel Index assessment for a patient
  static Future<Map<String, dynamic>> getBarthelAssessment(String patientId) async {
    return await getLastAssessment(patientId, 'Barthel Index');
  }

  /// Retrieves the latest Ernährung/Malnutrition assessment for a patient
  static Future<Map<String, dynamic>> getErnaehrungAssessment(String patientId) async {
    return await getLastAssessment(patientId, 'Ernährung/Malnutrition');
  }

  // Get list of unfilled assessments
  static Future<List<Map<String, dynamic>>> getUnfilledAssessments() async {
    final url = Uri.parse('$baseUrl/unfilled_assessments');
    
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['unfilled_assessments']);
      } else {
        throw Exception('Failed to load unfilled assessments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
  
  // Get patient data completion stats
  static Future<List<Map<String, dynamic>>> getPatientCompletionStats() async {
    final url = Uri.parse('$baseUrl/patient_completion_stats');
    
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['patient_stats']);
      } else {
        throw Exception('Failed to load patient completion stats: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }
}


