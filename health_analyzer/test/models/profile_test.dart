import 'package:flutter_test/flutter_test.dart';
import 'package:health_analyzer/models/profile.dart';

void main() {
  group('Profile model', () {
    test('toMap omits relationship per backward-compat note', () {
      final p = Profile(
        id: 10,
        name: 'John Doe',
        dateOfBirth: '1990-01-01',
        gender: 'Male',
        relationship: 'Self',
        photoPath: '/path/pic.png',
      );
      final map = p.toMap();
      expect(map['name'], 'John Doe');
      expect(map.containsKey('relationship'), isFalse,
          reason: 'Relationship intentionally omitted for existing DBs');
    });

    test('fromMap reads relationship when present', () {
      final map = {
        'id': 1,
        'name': 'Alice',
        'date_of_birth': '1985-05-05',
        'gender': 'Female',
        'relationship': 'Parent',
        'photo_path': null,
        'created_at': DateTime(2024, 1, 1).toIso8601String(),
      };

      final profile = Profile.fromMap(map);
      expect(profile.name, 'Alice');
      expect(profile.relationship, 'Parent');
    });

    test('copyWith updates selected fields', () {
      final p = Profile(name: 'X');
      final q = p.copyWith(name: 'Y', relationship: 'Self');
      expect(q.name, 'Y');
      expect(q.relationship, 'Self');
    });
  });
}