/// Blood Parameter Model
/// Represents a single blood test parameter value
class Parameter {
  final int? id;
  final int reportId;
  final String parameterName; // Normalized name (e.g., 'rbc_count')
  final double parameterValue;
  final String? unit;
  final double? referenceRangeMin;
  final double? referenceRangeMax;
  final String? rawParameterName; // Original name from report

  Parameter({
    this.id,
    required this.reportId,
    required this.parameterName,
    required this.parameterValue,
    this.unit,
    this.referenceRangeMin,
    this.referenceRangeMax,
    this.rawParameterName,
  });

  /// Create Parameter from database map
  factory Parameter.fromMap(Map<String, dynamic> map) {
    return Parameter(
      id: map['id'] as int?,
      reportId: map['report_id'] as int,
      parameterName: map['parameter_name'] as String,
      parameterValue: (map['parameter_value'] as num).toDouble(),
      unit: map['unit'] as String?,
      referenceRangeMin: map['reference_range_min'] != null
          ? (map['reference_range_min'] as num).toDouble()
          : null,
      referenceRangeMax: map['reference_range_max'] != null
          ? (map['reference_range_max'] as num).toDouble()
          : null,
      rawParameterName: map['raw_parameter_name'] as String?,
    );
  }

  /// Convert Parameter to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'report_id': reportId,
      'parameter_name': parameterName,
      'parameter_value': parameterValue,
      'unit': unit,
      'reference_range_min': referenceRangeMin,
      'reference_range_max': referenceRangeMax,
      'raw_parameter_name': rawParameterName,
    };
  }

  /// Check if value is within normal range
  bool get isNormal {
    if (referenceRangeMin == null || referenceRangeMax == null) {
      return true; // Can't determine without ranges
    }
    return parameterValue >= referenceRangeMin! &&
        parameterValue <= referenceRangeMax!;
  }

  /// Get status: 'low', 'normal', or 'high'
  String get status {
    if (referenceRangeMin == null || referenceRangeMax == null) {
      return 'unknown';
    }
    if (parameterValue < referenceRangeMin!) return 'low';
    if (parameterValue > referenceRangeMax!) return 'high';
    return 'normal';
  }

  @override
  String toString() {
    return 'Parameter(name: $parameterName, value: $parameterValue $unit, status: $status)';
  }
}
