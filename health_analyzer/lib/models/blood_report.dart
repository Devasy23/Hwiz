import 'parameter.dart';

/// Blood Report Model
/// Represents a complete blood test report
class BloodReport {
  final int? id;
  final int profileId;
  final DateTime testDate;
  final String? labName;
  final String? reportImagePath;
  final String? aiAnalysis; // Cached AI analysis
  final List<Parameter> parameters;
  final DateTime createdAt;

  BloodReport({
    this.id,
    required this.profileId,
    required this.testDate,
    this.labName,
    this.reportImagePath,
    this.aiAnalysis,
    List<Parameter>? parameters,
    DateTime? createdAt,
  })  : parameters = parameters ?? [],
        createdAt = createdAt ?? DateTime.now();

  /// Create BloodReport from database map
  factory BloodReport.fromMap(Map<String, dynamic> map) {
    return BloodReport(
      id: map['id'] as int?,
      profileId: map['profile_id'] as int,
      testDate: DateTime.parse(map['test_date'] as String),
      labName: map['lab_name'] as String?,
      reportImagePath: map['report_image_path'] as String?,
      aiAnalysis: map['ai_analysis'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert BloodReport to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'test_date': testDate.toIso8601String(),
      'lab_name': labName,
      'report_image_path': reportImagePath,
      'ai_analysis': aiAnalysis,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  BloodReport copyWith({
    int? id,
    int? profileId,
    DateTime? testDate,
    String? labName,
    String? reportImagePath,
    String? aiAnalysis,
    List<Parameter>? parameters,
    DateTime? createdAt,
  }) {
    return BloodReport(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      testDate: testDate ?? this.testDate,
      labName: labName ?? this.labName,
      reportImagePath: reportImagePath ?? this.reportImagePath,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      parameters: parameters ?? this.parameters,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get parameter by name
  Parameter? getParameter(String parameterName) {
    try {
      return parameters.firstWhere((p) => p.parameterName == parameterName);
    } catch (e) {
      return null;
    }
  }

  /// Get all abnormal parameters
  List<Parameter> get abnormalParameters {
    return parameters.where((p) => !p.isNormal).toList();
  }

  @override
  String toString() {
    return 'BloodReport(id: $id, profileId: $profileId, testDate: $testDate, parameters: ${parameters.length})';
  }
}
