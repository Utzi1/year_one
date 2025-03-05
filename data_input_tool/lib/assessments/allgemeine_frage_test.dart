import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../assessments/allgemeine_frage.dart';
import 'package:surgeahead_data_input_tool/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  Widget createWidgetUnderTest({required Map<String, dynamic> assessmentData}) {
    return MaterialApp(
      home: Scaffold(
        body: Provider<ApiService>(
          create: (_) => mockApiService,
          child: AllgemeinesAssessment(
            patientId: '123',
            assessmentData: assessmentData,
          ),
        ),
      ),
    );
  }

  testWidgets('AllgemeinesAssessment loads data correctly', (WidgetTester tester) async {
    final assessmentData = {
      'alter': 30,
      'geschlecht': 'Männlich',
      'operation': 'Appendektomie',
      'isar_score': 50,
    };

    await tester.pumpWidget(createWidgetUnderTest(assessmentData: assessmentData));

    expect(find.text('30'), findsOneWidget);
    expect(find.text('Männlich'), findsOneWidget);
    expect(find.text('Appendektomie'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
  });

  testWidgets('AllgemeinesAssessment shows error message on invalid input', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(assessmentData: {}));

    await tester.enterText(find.byType(TextField).at(0), '200'); // Invalid age
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Bitte geben Sie gültige Werte ein!'), findsOneWidget);
  });

  testWidgets('AllgemeinesAssessment saves data correctly', (WidgetTester tester) async {
    final assessmentData = {
      'alter': 30,
      'geschlecht': 'Männlich',
      'operation': 'Appendektomie',
      'isar_score': 50,
    };

    when(mockApiService.postHashMap(any, any, any)).thenAnswer((_) async => {'message': 'Success'});

    await tester.pumpWidget(createWidgetUnderTest(assessmentData: assessmentData));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(mockApiService.postHashMap('123', 'Allgemeines Assessment', {
      'alter': '30',
      'geschlecht': 'Männlich',
      'operation': 'Appendektomie',
      'isar_score': '50',
    })).called(1);

    expect(find.text('Success'), findsOneWidget);
  });
}