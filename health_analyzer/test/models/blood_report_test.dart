import 'package:flutter_test/flutter_test.dart';
import 'package:health_analyzer/models/blood_report.dart';

void main() {
  group('BloodReport model', () {
    test('toMap/fromMap preserves core fields including aiAnalysis', () {
      final report = BloodReport(
        id: 7,
        profileId: 3,
        testDate: DateTime(2024, 1, 15),
        labName: 'City Lab',
        reportImagePath: '/tmp/report.png',
        aiAnalysis: '{"overall":"ok"}',
      );

      final map = report.toMap();
      expect(map['id'], 7);
      expect(map['profile_id'], 3);
      expect(map['lab_name'], 'City Lab');
      expect(map['report_image_path'], '/tmp/report.png');
      expect(map['ai_analysis'], '{"overall":"ok"}');

      final restored = BloodReport.fromMap(map);
      expect(restored.id, 7);
      expect(restored.profileId, 3);
      expect(restored.labName, 'City Lab');
      expect(restored.reportImagePath, '/tmp/report.png');
      expect(restored.aiAnalysis, '{"overall":"ok"}');
    });

    test('copyWith updates selected fields', () {
      final original = BloodReport(
        profileId: 1,
        testDate: DateTime(2025, 6, 1),
        labName: 'A',
      );
      final updated = original.copyWith(labName: 'B', aiAnalysis: '{}');
      expect(updated.labName, 'B');
      expect(updated.aiAnalysis, '{}');
      expect(updated.profileId, original.profileId);
    });

    test('getParameter returns null when empty and abnormalParameters is empty', () {
      final report = BloodReport(
        profileId: 1,
        testDate: DateTime(2025, 1, 1),
      );
      expect(report.getParameter('hemoglobin'), isNull);
      expect(report.abnormalParameters, isEmpty);
    });
  });
}