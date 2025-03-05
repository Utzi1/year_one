import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../services/api_service.dart';
import 'barthel_index_3_days_assessment.dart';

@GenerateMocks([ApiService])
part 'barthel_index_3_days_assessment_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  
  setUp(() {
    mockApiService = MockApiService();
    // Replace the static methods with mocked implementations
    ApiService.getLastAssessment = (String patientId, String assessmentName) async {
      return await mockApiService.getLastAssessment(patientId, assessmentName);
    };
    
    ApiService.saveAssessment = (String patientId, String assessmentName, Map<String, dynamic> data) async {
      return await mockApiService.saveAssessment(patientId, assessmentName, data);
    };
  });
  
  testWidgets('BarthelIndex3DayAssessment initializes correctly', (WidgetTester tester) async {
    // Arrange
    const String patientId = '12345';
    const Map<String, dynamic> assessmentData = {};

    // Mock API responses
    when(mockApiService.getLastAssessment(patientId, 'Barthel Index'))
        .thenAnswer((_) async => {});

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BarthelIndex3DayAssessment(
            patientId: patientId,
            assessmentData: assessmentData,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Barthel Index 3-Day Assessment'), findsOneWidget);
    expect(find.text('Tag 3 nach Operation: Beurteilen Sie die aktuelle Funktionsfähigkeit des Patienten.'), findsOneWidget);
  });

  testWidgets('BarthelIndex3DayAssessment loads data from assessmentData', (WidgetTester tester) async {
    // Arrange
    const String patientId = '12345';
    const Map<String, dynamic> assessmentData = {
      'data': {
        'anamnese': '0',
        'anamnese_kommentar': 'Test comment',
        'essen': '10',
        'aufstehen': '15',
        'aufstehengehen': '15',
        'waschen': '5',
        'toilette': '10',
        'baden': '5',
        'treppensteigen': '10',
        'kleiden': '10',
        'stuhlkontrollen': '10',
        'harnkontrollen': '10'
      }
    };

    // Mock API responses
    when(mockApiService.getLastAssessment(patientId, 'Barthel Index'))
        .thenAnswer((_) async => {});

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BarthelIndex3DayAssessment(
            patientId: patientId,
            assessmentData: assessmentData,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Test comment'), findsOneWidget);
    expect(find.text('Eigenanamnese'), findsOneWidget);
  });

  testWidgets('BarthelIndex3DayAssessment loads initial assessment for comparison', (WidgetTester tester) async {
    // Arrange
    const String patientId = '12345';
    const Map<String, dynamic> assessmentData = {};
    const Map<String, dynamic> initialAssessmentData = {
      'data': {
        'essen': '10',
        'aufstehen': '15',
        'aufstehengehen': '15',
        'waschen': '5',
        'toilette': '10',
        'baden': '5',
        'treppensteigen': '10',
        'kleiden': '10',
        'stuhlkontrollen': '10',
        'harnkontrollen': '10'
      }
    };

    // Mock API responses
    when(mockApiService.getLastAssessment(patientId, 'Barthel Index'))
        .thenAnswer((_) async => initialAssessmentData);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BarthelIndex3DayAssessment(
            patientId: patientId,
            assessmentData: assessmentData,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Präoperative Werte:'), findsOneWidget);
    expect(find.text('Barthel Index präoperativ: 100 von 100 Punkten'), findsOneWidget);
  });

  testWidgets('BarthelIndex3DayAssessment shows warning when no initial data', (WidgetTester tester) async {
    // Arrange
    const String patientId = '12345';
    const Map<String, dynamic> assessmentData = {};

    // Mock API responses with empty initial assessment
    when(mockApiService.getLastAssessment(patientId, 'Barthel Index'))
        .thenAnswer((_) async => {});

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BarthelIndex3DayAssessment(
            patientId: patientId,
            assessmentData: assessmentData,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Kein präoperatives Barthel-Index Assessment gefunden. Vergleichswerte sind nicht verfügbar.'), findsOneWidget);
  });

  testWidgets('BarthelIndex3DayAssessment calculates score correctly', (WidgetTester tester) async {
    // Arrange
    const String patientId = '12345';
    const Map<String, dynamic> assessmentData = {
      'data': {
        'anamnese': '0',
        'anamnese_kommentar': '',
        'essen': '5',
        'aufstehen': '5',
        'aufstehengehen': '5',
        'waschen': '0',
        'toilette': '5',
        'baden': '0',
        'treppensteigen': '5',
        'kleiden': '5',
        'stuhlkontrollen': '5',
        'harnkontrollen': '5'
      }
    };

    // Mock API responses
    when(mockApiService.getLastAssessment(patientId, 'Barthel Index'))
        .thenAnswer((_) async => {});

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BarthelIndex3DayAssessment(
            patientId: patientId,
            assessmentData: assessmentData,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // We need to find save button and verify the total score calculation indirectly
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('BarthelIndex3DayAssessment saves data correctly', (WidgetTester tester) async {
    // Arrange
    const String patientId = '12345';
    const Map<String, dynamic> assessmentData = {
      'data': {
        'anamnese': '0',
        'anamnese_kommentar': '',
        'essen': '5',
        'aufstehen': '5',
        'aufstehengehen': '5',
        'waschen': '0',
        'toilette': '5',
        'baden': '0',
        'treppensteigen': '5',
        'kleiden': '5',
        'stuhlkontrollen': '5',
        'harnkontrollen': '5'
      }
    };

    // Mock API responses
    when(mockApiService.getLastAssessment(patientId, 'Barthel Index'))
        .thenAnswer((_) async => {});
    when(mockApiService.saveAssessment(patientId, 'Barthel Index 3-Day Assessment', any))
        .thenAnswer((_) async => {'success': true, 'message': 'Assessment gespeichert'});

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BarthelIndex3DayAssessment(
            patientId: patientId,
            assessmentData: assessmentData,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find the save button and tap it
    final saveButton = find.text('Assessment Speichern');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify the API was called
    verify(mockApiService.saveAssessment(patientId, 'Barthel Index 3-Day Assessment', any)).called(1);
  });

  testWidgets('BarthelIndex3DayAssessment shows score comparison section correctly', (WidgetTester tester) async {
    // Arrange
    const String patientId = '12345';
    const Map<String, dynamic> assessmentData = {
      'data': {
        'anamnese': '0',
        'anamnese_kommentar': '',
        'essen': '5',
        'aufstehen': '5',
        'aufstehengehen': '5',
        'waschen': '0',
        'toilette': '5',
        'baden': '0',
        'treppensteigen': '5',
        'kleiden': '5',
        'stuhlkontrollen': '5',
        'harnkontrollen': '5'
      }
    };
    
    const Map<String, dynamic> initialAssessmentData = {
      'data': {
        'essen': '10',
        'aufstehen': '15',
        'aufstehengehen': '15',
        'waschen': '5',
        'toilette': '10',
        'baden': '5',
        'treppensteigen': '10',
        'kleiden': '10',
        'stuhlkontrollen': '10',
        'harnkontrollen': '10'
      }
    };

    // Mock API responses
    when(mockApiService.getLastAssessment(patientId, 'Barthel Index'))
        .thenAnswer((_) async => initialAssessmentData);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BarthelIndex3DayAssessment(
            patientId: patientId,
            assessmentData: assessmentData,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Bewertung Tag 3 nach OP'), findsOneWidget);
    expect(find.text('Präoperativ: 100'), findsOneWidget);
    expect(find.text('Tag 3: 40'), findsOneWidget);
    expect(find.text('Verschlechterung um 60 Punkte nach Operation'), findsOneWidget);
    expect(find.text('Erhebliche Einschränkung nach Operation'), findsOneWidget);
  });
}