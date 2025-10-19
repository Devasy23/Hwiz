import 'package:fuzzywuzzy/fuzzywuzzy.dart';

/// LOINC Mapper - Normalizes parameter names to standard format
/// Handles variations in parameter naming across different labs
class LOINCMapper {
  // Comprehensive mapping of parameter variations to standard names
  static final Map<String, String> _parameterMap = {
    // RBC Count variations
    'rbc': 'rbc_count',
    'rbc count': 'rbc_count',
    'rbc_count': 'rbc_count',
    'rbccount': 'rbc_count',
    'red blood cells': 'rbc_count',
    'red blood cell count': 'rbc_count',
    'erythrocytes': 'rbc_count',
    'erythrocyte count': 'rbc_count',
    'total rbc': 'rbc_count',

    // WBC Count variations
    'wbc': 'wbc_count',
    'wbc count': 'wbc_count',
    'wbc_count': 'wbc_count',
    'wbccount': 'wbc_count',
    'white blood cells': 'wbc_count',
    'white blood cell count': 'wbc_count',
    'leukocytes': 'wbc_count',
    'leukocyte count': 'wbc_count',
    'total wbc': 'wbc_count',
    'tc': 'wbc_count',

    // Hemoglobin variations
    'hb': 'hemoglobin',
    'hgb': 'hemoglobin',
    'hemoglobin': 'hemoglobin',
    'haemoglobin': 'hemoglobin',
    'hgb concentration': 'hemoglobin',

    // Hematocrit variations
    'hct': 'hematocrit',
    'hematocrit': 'hematocrit',
    'haematocrit': 'hematocrit',
    'packed cell volume': 'hematocrit',
    'pcv': 'hematocrit',

    // Platelet variations
    'plt': 'platelet_count',
    'platelet': 'platelet_count',
    'platelets': 'platelet_count',
    'platelet count': 'platelet_count',
    'platelet_count': 'platelet_count',
    'thrombocytes': 'platelet_count',
    'thrombocyte count': 'platelet_count',

    // MCV variations
    'mcv': 'mcv',
    'mean corpuscular volume': 'mcv',
    'mean cell volume': 'mcv',

    // MCH variations
    'mch': 'mch',
    'mean corpuscular hemoglobin': 'mch',
    'mean cell hemoglobin': 'mch',

    // MCHC variations
    'mchc': 'mchc',
    'mean corpuscular hemoglobin concentration': 'mchc',
    'mean cell hemoglobin concentration': 'mchc',

    // Neutrophils variations
    'neutrophils': 'neutrophils',
    'neutrophil': 'neutrophils',
    'neutrophil count': 'neutrophils',
    'neutrophil %': 'neutrophils',
    'neutrophil percentage': 'neutrophils',
    'neut': 'neutrophils',
    'polymorphs': 'neutrophils',
    'pmn': 'neutrophils',

    // Lymphocytes variations
    'lymphocytes': 'lymphocytes',
    'lymphocyte': 'lymphocytes',
    'lymphocyte count': 'lymphocytes',
    'lymphocyte %': 'lymphocytes',
    'lymphocyte percentage': 'lymphocytes',
    'lymph': 'lymphocytes',

    // Monocytes variations
    'monocytes': 'monocytes',
    'monocyte': 'monocytes',
    'monocyte count': 'monocytes',
    'monocyte %': 'monocytes',
    'monocyte percentage': 'monocytes',
    'mono': 'monocytes',

    // Eosinophils variations
    'eosinophils': 'eosinophils',
    'eosinophil': 'eosinophils',
    'eosinophil count': 'eosinophils',
    'eosinophil %': 'eosinophils',
    'eosinophil percentage': 'eosinophils',
    'eos': 'eosinophils',

    // Basophils variations
    'basophils': 'basophils',
    'basophil': 'basophils',
    'basophil count': 'basophils',
    'basophil %': 'basophils',
    'basophil percentage': 'basophils',
    'baso': 'basophils',

    // Additional common parameters
    'esr': 'esr',
    'erythrocyte sedimentation rate': 'esr',
    'sed rate': 'esr',

    'rdw': 'rdw',
    'red cell distribution width': 'rdw',
    'rdw cv': 'rdw',

    'mpv': 'mpv',
    'mean platelet volume': 'mpv',
  };

  /// Normalize a parameter name to standard format
  static String normalize(String rawName) {
    // Clean the input
    String cleaned = rawName
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();

    // Direct lookup
    if (_parameterMap.containsKey(cleaned)) {
      return _parameterMap[cleaned]!;
    }

    // Try without spaces
    String noSpaces = cleaned.replaceAll(' ', '_');
    if (_parameterMap.containsKey(noSpaces)) {
      return _parameterMap[noSpaces]!;
    }

    // Fuzzy matching fallback
    return _fuzzyMatch(cleaned);
  }

  /// Fuzzy match parameter name to standard names
  static String _fuzzyMatch(String input) {
    try {
      final List<String> knownParameters =
          _parameterMap.values.toSet().toList();

      // Use fuzzy matching with 85% similarity threshold
      final result = extractOne(
        query: input,
        choices: knownParameters,
        cutoff: 85,
      );

      // If match found with high confidence, return it
      if (result != null && result.score >= 85) {
        return result.choice;
      }

      // If no good match, return cleaned input
      // This allows new parameters to be stored as-is
      return input.replaceAll(' ', '_');
    } catch (e) {
      // If fuzzy matching fails, return cleaned input
      return input.replaceAll(' ', '_');
    }
  }

  /// Get all standard parameter names
  static List<String> getAllStandardNames() {
    return _parameterMap.values.toSet().toList()..sort();
  }

  /// Get all variations for a standard name
  static List<String> getVariations(String standardName) {
    return _parameterMap.entries
        .where((entry) => entry.value == standardName)
        .map((entry) => entry.key)
        .toList();
  }

  /// Add a custom mapping (useful for learning from user corrections)
  static void addMapping(String rawName, String standardName) {
    String cleaned = rawName
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    _parameterMap[cleaned] = standardName;
  }

  /// Get friendly display name for a parameter
  static String getDisplayName(String standardName) {
    final Map<String, String> displayNames = {
      'rbc_count': 'RBC Count',
      'wbc_count': 'WBC Count',
      'hemoglobin': 'Hemoglobin',
      'hematocrit': 'Hematocrit',
      'platelet_count': 'Platelet Count',
      'mcv': 'MCV',
      'mch': 'MCH',
      'mchc': 'MCHC',
      'neutrophils': 'Neutrophils',
      'lymphocytes': 'Lymphocytes',
      'monocytes': 'Monocytes',
      'eosinophils': 'Eosinophils',
      'basophils': 'Basophils',
      'esr': 'ESR',
      'rdw': 'RDW',
      'mpv': 'MPV',
    };

    return displayNames[standardName] ??
        standardName
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
  }
}
