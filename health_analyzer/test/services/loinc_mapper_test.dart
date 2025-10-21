import 'package:flutter_test/flutter_test.dart';
import 'package:health_analyzer/services/loinc_mapper.dart';

void main() {
  group('LOINCMapper.normalize', () {
    test('maps common variants directly', () {
      expect(LOINCMapper.normalize('RBC'), 'rbc_count');
      expect(LOINCMapper.normalize('RBC Count'), 'rbc_count');
      expect(LOINCMapper.normalize('red blood cells'), 'rbc_count');
      expect(LOINCMapper.normalize('WBC'), 'wbc_count');
      expect(LOINCMapper.normalize('white blood cell count'), 'wbc_count');
      expect(LOINCMapper.normalize('Hb'), 'hemoglobin');
      expect(LOINCMapper.normalize('haemoglobin'), 'hemoglobin');
      expect(LOINCMapper.normalize('Platelet count'), 'platelet_count');
    });

    test('fuzzy matches near-miss names', () {
      // Slight misspells should fuzzy-match to nearest standard name
      expect(LOINCMapper.normalize('neutrophilss'), 'neutrophils');
    });

    test('falls back to cleaned input when no good match', () {
      // Unknown parameter becomes cleaned snake_case
      expect(LOINCMapper.normalize('Very Custom Param'), 'very_custom_param');
    });
  });

  group('LOINCMapper utilities', () {
    test('getDisplayName returns friendly names or title-cased fallback', () {
      expect(LOINCMapper.getDisplayName('rbc_count'), 'RBC Count');
      expect(LOINCMapper.getDisplayName('foo_bar'), 'Foo Bar');
    });

    test('getAllStandardNames contains key normalized parameters', () {
      final names = LOINCMapper.getAllStandardNames();
      expect(names, contains('rbc_count'));
      expect(names, contains('wbc_count'));
      expect(names, contains('hemoglobin'));
    });

    test('getVariations returns raw variants for a standard name', () {
      final vars = LOINCMapper.getVariations('rbc_count');
      expect(vars, isNotEmpty);
      expect(vars, contains('rbc'));
      expect(vars, contains('rbc count'));
    });

    test('addMapping allows custom normalization learning', () {
      LOINCMapper.addMapping('Hb%', 'hemoglobin');
      expect(LOINCMapper.normalize('Hb%'), 'hemoglobin');
    });
  });
}