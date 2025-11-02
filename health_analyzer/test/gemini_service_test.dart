
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Lablens/services/gemini_service.dart';
import 'package:Lablens/services/gemini_model_wrapper.dart';
import 'package:Lablens/utils/constants.dart';

import 'gemini_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage, GenerativeModelWrapper])
void main() {
  late GeminiService geminiService;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockGenerativeModelWrapper mockGenerativeModelWrapper;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    mockGenerativeModelWrapper = MockGenerativeModelWrapper();
    geminiService = GeminiService();

    geminiService.initializeForTest(mockSecureStorage, mockGenerativeModelWrapper);
  });

  group('GeminiService', () {
    test('initialize does not throw when API key exists', () async {
      when(mockSecureStorage.read(key: AppConstants.geminiApiKeyStorage))
          .thenAnswer((_) async => 'test_api_key');
      when(mockSecureStorage.read(key: 'selected_gemini_model'))
          .thenAnswer((_) async => 'gemini-pro');

      expectLater(geminiService.initialize(), completes);
    });

    test('setApiKey writes key to storage', () async {
      when(mockSecureStorage.write(key: AppConstants.geminiApiKeyStorage, value: 'new_api_key'))
          .thenAnswer((_) async {});
      when(mockSecureStorage.read(key: AppConstants.geminiApiKeyStorage))
          .thenAnswer((_) async => 'new_api_key');
      when(mockSecureStorage.read(key: 'selected_gemini_model'))
          .thenAnswer((_) async => 'gemini-pro');

      await geminiService.setApiKey('new_api_key');

      verify(mockSecureStorage.write(key: AppConstants.geminiApiKeyStorage, value: 'new_api_key'))
          .called(1);
    });

    test('extractBloodReportData successfully extracts and parses data', () async {
      final mockFile = MockFile();
      final jsonResponse = {
        "test_date": "2023-10-27",
        "lab_name": "Test Lab",
        "parameters": {
          "rbc_count": {"value": 5.2, "unit": "10^6/uL", "raw_name": "RBC"}
        }
      };

      when(mockFile.readAsBytes()).thenAnswer((_) async => Uint8List(0));
      when(mockFile.path).thenReturn('test.jpg');
      when(mockGenerativeModelWrapper.generateContentText(any,
              generationConfig: anyNamed('generationConfig')))
          .thenAnswer((_) async => json.encode(jsonResponse));

      final result = await geminiService.extractBloodReportData(mockFile);

      expect(result['test_date'], '2023-10-27');
      expect(result['parameters']['rbc_count']['value'], 5.2);
    });

    test('generateHealthInsights provides analysis', () async {
      final insightsResponse = {
        "overall_assessment": "Good",
        "concerns": [],
        "positive_notes": ["All good"],
        "next_steps": ["Keep it up"]
      };

      when(mockGenerativeModelWrapper.generateContentText(any,
              generationConfig: anyNamed('generationConfig')))
          .thenAnswer((_) async => json.encode(insightsResponse));

      final result = await geminiService.generateHealthInsights(
        abnormalParameters: [],
        allParameters: [],
      );

      expect(result['overall_assessment'], 'Good');
    });

    test('testApiKey returns true for a valid key', () async {
      when(mockGenerativeModelWrapper.generateContentText(any))
          .thenAnswer((_) async => 'Hello');

      final isValid = await geminiService.testApiKey('valid_key',
          testModel: mockGenerativeModelWrapper);

      expect(isValid, isTrue);
    });

    test('testApiKey returns false for an invalid key', () async {
      when(mockGenerativeModelWrapper.generateContentText(any))
          .thenThrow(Exception('API Key Invalid'));

      final isValid = await geminiService.testApiKey('invalid_key',
          testModel: mockGenerativeModelWrapper);

      expect(isValid, isFalse);
    });

    test('generateTrendAnalysis returns analysis', () async {
      when(mockGenerativeModelWrapper.generateContentText(any,
              generationConfig: anyNamed('generationConfig')))
          .thenAnswer((_) async => 'Trend analysis');

      final result = await geminiService.generateTrendAnalysis(
        parameterName: 'RBC',
        historicalData: [],
      );

      expect(result, 'Trend analysis');
    });
  });
}

// Mock File class for testing
class MockFile extends Mock implements File {
  @override
  Future<Uint8List> readAsBytes() => super.noSuchMethod(
        Invocation.method(#readAsBytes, []),
        returnValue: Future.value(Uint8List(0)),
      );

  @override
  String get path => super.noSuchMethod(
        Invocation.getter(#path),
        returnValue: '',
      );
}
