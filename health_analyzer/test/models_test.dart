import 'package:flutter_test/flutter_test.dart';
import 'package:Lablens/models/parameter.dart';
import 'package:Lablens/models/blood_report.dart';
import 'package:Lablens/models/profile.dart';

void main() {
  group('Parameter Model', () {
    test('creates parameter with all fields', () {
      // Given/When: Create parameter
      final parameter = Parameter(
        id: 1,
        reportId: 1,
        parameterName: 'hemoglobin',
        parameterValue: 14.5,
        unit: 'g/dL',
        referenceRangeMin: 13.0,
        referenceRangeMax: 17.0,
        rawParameterName: 'HGB',
      );

      // Then: All fields should be set
      expect(parameter.id, equals(1));
      expect(parameter.reportId, equals(1));
      expect(parameter.parameterName, equals('hemoglobin'));
      expect(parameter.parameterValue, equals(14.5));
      expect(parameter.unit, equals('g/dL'));
      expect(parameter.referenceRangeMin, equals(13.0));
      expect(parameter.referenceRangeMax, equals(17.0));
    });

    test('isNormal returns true for value within range', () {
      // Given: Parameter within normal range
      final parameter = Parameter(
        reportId: 1,
        parameterName: 'hemoglobin',
        parameterValue: 14.5,
        referenceRangeMin: 13.0,
        referenceRangeMax: 17.0,
      );

      // When/Then: Should be normal
      expect(parameter.isNormal, isTrue);
      expect(parameter.status, equals('normal'));
    });

    test('isNormal returns false for value below range', () {
      // Given: Parameter below normal range
      final parameter = Parameter(
        reportId: 1,
        parameterName: 'hemoglobin',
        parameterValue: 12.0,
        referenceRangeMin: 13.0,
        referenceRangeMax: 17.0,
      );

      // When/Then: Should be abnormal (low)
      expect(parameter.isNormal, isFalse);
      expect(parameter.status, equals('low'));
    });

    test('isNormal returns false for value above range', () {
      // Given: Parameter above normal range
      final parameter = Parameter(
        reportId: 1,
        parameterName: 'hemoglobin',
        parameterValue: 18.0,
        referenceRangeMin: 13.0,
        referenceRangeMax: 17.0,
      );

      // When/Then: Should be abnormal (high)
      expect(parameter.isNormal, isFalse);
      expect(parameter.status, equals('high'));
    });

    test('status returns unknown when reference ranges are null', () {
      // Given: Parameter without reference ranges
      final parameter = Parameter(
        reportId: 1,
        parameterName: 'hemoglobin',
        parameterValue: 14.5,
      );

      // When/Then: Status should be unknown
      expect(parameter.status, equals('unknown'));
      expect(parameter.isNormal, isTrue); // Default to true when can't determine
    });

    test('status handles boundary values correctly', () {
      // Given: Parameter at exact boundary
      final parameterAtMin = Parameter(
        reportId: 1,
        parameterName: 'hemoglobin',
        parameterValue: 13.0,
        referenceRangeMin: 13.0,
        referenceRangeMax: 17.0,
      );

      final parameterAtMax = Parameter(
        reportId: 1,
        parameterName: 'hemoglobin',
        parameterValue: 17.0,
        referenceRangeMin: 13.0,
        referenceRangeMax: 17.0,
      );

      // When/Then: Boundary values should be normal
      expect(parameterAtMin.isNormal, isTrue);
      expect(parameterAtMin.status, equals('normal'));
      expect(parameterAtMax.isNormal, isTrue);
      expect(parameterAtMax.status, equals('normal'));
    });

    test('toMap converts parameter to map correctly', () {
      // Given: Parameter
      final parameter = Parameter(
        id: 1,
        reportId: 1,
        parameterName: 'hemoglobin',
        parameterValue: 14.5,
        unit: 'g/dL',
        referenceRangeMin: 13.0,
        referenceRangeMax: 17.0,
      );

      // When: Convert to map
      final map = parameter.toMap();

      // Then: Map should contain all fields
      expect(map['id'], equals(1));
      expect(map['report_id'], equals(1));
      expect(map['parameter_name'], equals('hemoglobin'));
      expect(map['parameter_value'], equals(14.5));
      expect(map['unit'], equals('g/dL'));
      expect(map['reference_range_min'], equals(13.0));
      expect(map['reference_range_max'], equals(17.0));
    });

    test('fromMap creates parameter from map', () {
      // Given: Map with parameter data
      final map = {
        'id': 1,
        'report_id': 1,
        'parameter_name': 'hemoglobin',
        'parameter_value': 14.5,
        'unit': 'g/dL',
        'reference_range_min': 13.0,
        'reference_range_max': 17.0,
      };

      // When: Create parameter from map
      final parameter = Parameter.fromMap(map);

      // Then: All fields should be set correctly
      expect(parameter.id, equals(1));
      expect(parameter.parameterName, equals('hemoglobin'));
      expect(parameter.parameterValue, equals(14.5));
    });

    test('toString returns readable string representation', () {
      // Given: Parameter
      final parameter = Parameter(
        reportId: 1,
        parameterName: 'hemoglobin',
        parameterValue: 14.5,
        unit: 'g/dL',
        referenceRangeMin: 13.0,
        referenceRangeMax: 17.0,
      );

      // When: Convert to string
      final str = parameter.toString();

      // Then: Should contain key information
      expect(str, contains('hemoglobin'));
      expect(str, contains('14.5'));
      expect(str, contains('g/dL'));
      expect(str, contains('normal'));
    });
  });

  group('BloodReport Model', () {
    test('creates blood report with all fields', () {
      // Given/When: Create blood report
      final report = BloodReport(
        id: 1,
        profileId: 1,
        testDate: DateTime(2023, 10, 15),
        labName: 'Test Lab',
        reportImagePath: '/path/to/image.jpg',
        aiAnalysis: 'Analysis text',
        parameters: [],
      );

      // Then: All fields should be set
      expect(report.id, equals(1));
      expect(report.profileId, equals(1));
      expect(report.testDate, equals(DateTime(2023, 10, 15)));
      expect(report.labName, equals('Test Lab'));
      expect(report.reportImagePath, equals('/path/to/image.jpg'));
      expect(report.aiAnalysis, equals('Analysis text'));
    });

    test('creates report with default empty parameters', () {
      // Given/When: Create report without parameters
      final report = BloodReport(
        id: 1,
        profileId: 1,
        testDate: DateTime(2023, 10, 15),
      );

      // Then: Parameters should be empty list
      expect(report.parameters, isEmpty);
    });

    test('creates report with default createdAt', () {
      // Given/When: Create report without createdAt
      final before = DateTime.now();
      final report = BloodReport(
        id: 1,
        profileId: 1,
        testDate: DateTime(2023, 10, 15),
      );
      final after = DateTime.now();

      // Then: createdAt should be set to current time
      expect(report.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(report.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('getParameter returns correct parameter by name', () {
      // Given: Report with parameters
      final report = BloodReport(
        id: 1,
        profileId: 1,
        testDate: DateTime(2023, 10, 15),
        parameters: [
          Parameter(
            reportId: 1,
            parameterName: 'hemoglobin',
            parameterValue: 14.5,
          ),
          Parameter(
            reportId: 1,
            parameterName: 'rbc_count',
            parameterValue: 5.2,
          ),
        ],
      );

      // When: Get parameter by name
      final param = report.getParameter('hemoglobin');

      // Then: Should return correct parameter
      expect(param, isNotNull);
      expect(param!.parameterName, equals('hemoglobin'));
      expect(param.parameterValue, equals(14.5));
    });

    test('getParameter returns null for non-existent parameter', () {
      // Given: Report with parameters
      final report = BloodReport(
        id: 1,
        profileId: 1,
        testDate: DateTime(2023, 10, 15),
        parameters: [
          Parameter(
            reportId: 1,
            parameterName: 'hemoglobin',
            parameterValue: 14.5,
          ),
        ],
      );

      // When: Get non-existent parameter
      final param = report.getParameter('nonexistent');

      // Then: Should return null
      expect(param, isNull);
    });

    test('abnormalParameters returns only abnormal values', () {
      // Given: Report with mix of normal and abnormal parameters
      final report = BloodReport(
        id: 1,
        profileId: 1,
        testDate: DateTime(2023, 10, 15),
        parameters: [
          Parameter(
            reportId: 1,
            parameterName: 'hemoglobin',
            parameterValue: 14.5,
            referenceRangeMin: 13.0,
            referenceRangeMax: 17.0,
          ),
          Parameter(
            reportId: 1,
            parameterName: 'rbc_count',
            parameterValue: 3.0, // Low
            referenceRangeMin: 4.5,
            referenceRangeMax: 5.9,
          ),
          Parameter(
            reportId: 1,
            parameterName: 'wbc_count',
            parameterValue: 15000, // High
            referenceRangeMin: 4000,
            referenceRangeMax: 11000,
          ),
        ],
      );

      // When: Get abnormal parameters
      final abnormal = report.abnormalParameters;

      // Then: Should return only abnormal ones
      expect(abnormal, hasLength(2));
      expect(abnormal.any((p) => p.parameterName == 'rbc_count'), isTrue);
      expect(abnormal.any((p) => p.parameterName == 'wbc_count'), isTrue);
      expect(abnormal.any((p) => p.parameterName == 'hemoglobin'), isFalse);
    });

    test('toMap converts report to map correctly', () {
      // Given: Blood report
      final report = BloodReport(
        id: 1,
        profileId: 1,
        testDate: DateTime(2023, 10, 15),
        labName: 'Test Lab',
        createdAt: DateTime(2023, 10, 15, 10, 30),
      );

      // When: Convert to map
      final map = report.toMap();

      // Then: Map should contain all fields
      expect(map['id'], equals(1));
      expect(map['profile_id'], equals(1));
      expect(map['test_date'], contains('2023-10-15'));
      expect(map['lab_name'], equals('Test Lab'));
      expect(map['created_at'], isNotNull);
    });

    test('fromMap creates report from map', () {
      // Given: Map with report data
      final map = {
        'id': 1,
        'profile_id': 1,
        'test_date': '2023-10-15T00:00:00.000',
        'lab_name': 'Test Lab',
        'report_image_path': '/path/to/image.jpg',
        'ai_analysis': 'Analysis',
        'created_at': '2023-10-15T10:30:00.000',
      };

      // When: Create report from map
      final report = BloodReport.fromMap(map);

      // Then: All fields should be set correctly
      expect(report.id, equals(1));
      expect(report.profileId, equals(1));
      expect(report.labName, equals('Test Lab'));
    });

    test('copyWith creates new instance with updated fields', () {
      // Given: Original report
      final original = BloodReport(
        id: 1,
        profileId: 1,
        testDate: DateTime(2023, 10, 15),
        labName: 'Lab A',
      );

      // When: Create copy with updated fields
      final copy = original.copyWith(
        labName: 'Lab B',
        aiAnalysis: 'New analysis',
      );

      // Then: Should have updated fields but same other fields
      expect(copy.id, equals(1));
      expect(copy.profileId, equals(1));
      expect(copy.labName, equals('Lab B'));
      expect(copy.aiAnalysis, equals('New analysis'));
      expect(copy.testDate, equals(original.testDate));
    });

    test('toString returns readable string representation', () {
      // Given: Report
      final report = BloodReport(
        id: 1,
        profileId: 1,
        testDate: DateTime(2023, 10, 15),
        parameters: [
          Parameter(reportId: 1, parameterName: 'test', parameterValue: 1.0),
        ],
      );

      // When: Convert to string
      final str = report.toString();

      // Then: Should contain key information
      expect(str, contains('BloodReport'));
      expect(str, contains('id: 1'));
      expect(str, contains('profileId: 1'));
      expect(str, contains('parameters: 1'));
    });
  });

  group('Profile Model', () {
    test('creates profile with all fields', () {
      // Given/When: Create profile
      final profile = Profile(
        id: 1,
        name: 'John Doe',
        dateOfBirth: '1990-01-01',
        gender: 'Male',
        relationship: 'Self',
        photoPath: '/path/to/photo.jpg',
      );

      // Then: All fields should be set
      expect(profile.id, equals(1));
      expect(profile.name, equals('John Doe'));
      expect(profile.dateOfBirth, equals('1990-01-01'));
      expect(profile.gender, equals('Male'));
      expect(profile.relationship, equals('Self'));
      expect(profile.photoPath, equals('/path/to/photo.jpg'));
    });

    test('creates profile with minimal required fields', () {
      // Given/When: Create profile with only name
      final profile = Profile(
        name: 'Jane Doe',
      );

      // Then: Should have name and null optional fields
      expect(profile.name, equals('Jane Doe'));
      expect(profile.id, isNull);
      expect(profile.dateOfBirth, isNull);
      expect(profile.gender, isNull);
      expect(profile.relationship, isNull);
      expect(profile.photoPath, isNull);
    });

    test('creates profile with default createdAt', () {
      // Given/When: Create profile without createdAt
      final before = DateTime.now();
      final profile = Profile(name: 'Test');
      final after = DateTime.now();

      // Then: createdAt should be set to current time
      expect(profile.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(profile.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });

    test('toMap converts profile to map correctly', () {
      // Given: Profile
      final profile = Profile(
        id: 1,
        name: 'John Doe',
        dateOfBirth: '1990-01-01',
        gender: 'Male',
        photoPath: '/path/to/photo.jpg',
        createdAt: DateTime(2023, 10, 15, 10, 30),
      );

      // When: Convert to map
      final map = profile.toMap();

      // Then: Map should contain all fields (except relationship due to comment)
      expect(map['id'], equals(1));
      expect(map['name'], equals('John Doe'));
      expect(map['date_of_birth'], equals('1990-01-01'));
      expect(map['gender'], equals('Male'));
      expect(map['photo_path'], equals('/path/to/photo.jpg'));
      expect(map['created_at'], isNotNull);
      // Note: relationship is not included in toMap as per comment in Profile model
    });

    test('fromMap creates profile from map', () {
      // Given: Map with profile data
      final map = {
        'id': 1,
        'name': 'John Doe',
        'date_of_birth': '1990-01-01',
        'gender': 'Male',
        'photo_path': '/path/to/photo.jpg',
        'created_at': '2023-10-15T10:30:00.000',
      };

      // When: Create profile from map
      final profile = Profile.fromMap(map);

      // Then: All fields should be set correctly
      expect(profile.id, equals(1));
      expect(profile.name, equals('John Doe'));
      expect(profile.dateOfBirth, equals('1990-01-01'));
      expect(profile.gender, equals('Male'));
    });

    test('copyWith creates new instance with updated fields', () {
      // Given: Original profile
      final original = Profile(
        id: 1,
        name: 'John Doe',
        dateOfBirth: '1990-01-01',
        gender: 'Male',
      );

      // When: Create copy with updated fields
      final copy = original.copyWith(
        name: 'Jane Doe',
        gender: 'Female',
      );

      // Then: Should have updated fields but same other fields
      expect(copy.id, equals(1));
      expect(copy.name, equals('Jane Doe'));
      expect(copy.gender, equals('Female'));
      expect(copy.dateOfBirth, equals('1990-01-01'));
    });

    test('copyWith with null values preserves original', () {
      // Given: Original profile
      final original = Profile(
        id: 1,
        name: 'John Doe',
        dateOfBirth: '1990-01-01',
      );

      // When: Create copy without updates
      final copy = original.copyWith();

      // Then: Should have same values
      expect(copy.id, equals(original.id));
      expect(copy.name, equals(original.name));
      expect(copy.dateOfBirth, equals(original.dateOfBirth));
    });

    test('toString returns readable string representation', () {
      // Given: Profile
      final profile = Profile(
        id: 1,
        name: 'John Doe',
        dateOfBirth: '1990-01-01',
      );

      // When: Convert to string
      final str = profile.toString();

      // Then: Should contain key information
      expect(str, contains('Profile'));
      expect(str, contains('id: 1'));
      expect(str, contains('name: John Doe'));
      expect(str, contains('dateOfBirth: 1990-01-01'));
    });
  });
}