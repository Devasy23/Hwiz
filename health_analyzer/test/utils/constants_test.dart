import 'package:flutter_test/flutter_test.dart';
import 'package:health_analyzer/utils/constants.dart';

void main() {
  group('ParameterUnits', () {
    test('returns known units', () {
      expect(ParameterUnits.getUnit('rbc_count'), 'million cells/μL');
      expect(ParameterUnits.getUnit('hemoglobin'), 'g/dL');
    });
    test('returns default for unknown', () {
      expect(ParameterUnits.getUnit('unknown_parameter'), 'unit');
    });
  });

  group('ReferenceRanges', () {
    test('returns range maps for known params', () {
      final range = ReferenceRanges.getRange('hemoglobin');
      expect(range, isNotNull);
      expect(range!['min'], 13.5);
      expect(range['max'], 17.5);
    });
    test('returns null for unknown', () {
      expect(ReferenceRanges.getRange('nope'), isNull);
    });
  });

  test('AppConstants expose app metadata and table names', () {
    expect(AppConstants.appName, isNotEmpty);
    expect(AppConstants.tableProfiles, 'profiles');
    expect(AppConstants.tableReports, 'reports');
  });
}