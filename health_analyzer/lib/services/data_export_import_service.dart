import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import '../models/blood_report.dart';
import '../models/parameter.dart';
import '../models/profile.dart';

/// Service for exporting and importing health data
class DataExportImportService {
  // ============================================================
  // EXPORT METHODS
  // ============================================================

  /// Export a single report to CSV
  Future<String?> exportReportToCsv(BloodReport report) async {
    try {
      final csv = _generateReportCsv(report);
      final file = await _saveTempFile('report_${report.id}.csv', csv);
      return file.path;
    } catch (e) {
      throw Exception('Failed to export report to CSV: $e');
    }
  }

  /// Export multiple reports to CSV
  Future<String?> exportReportsToCsv(
    List<BloodReport> reports,
    String profileName,
  ) async {
    try {
      final List<List<dynamic>> rows = [];

      // Header row
      rows.add([
        'Report ID',
        'Test Date',
        'Lab Name',
        'Parameter Name',
        'Value',
        'Unit',
        'Reference Min',
        'Reference Max',
        'Status',
      ]);

      // Data rows
      for (final report in reports) {
        for (final param in report.parameters) {
          rows.add([
            report.id,
            report.testDate.toIso8601String(),
            report.labName ?? '',
            param.parameterName,
            param.parameterValue,
            param.unit ?? '',
            param.referenceRangeMin ?? '',
            param.referenceRangeMax ?? '',
            param.status,
          ]);
        }
      }

      final csv = const ListToCsvConverter().convert(rows);
      final fileName =
          '${profileName}_reports_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = await _saveTempFile(fileName, csv);
      return file.path;
    } catch (e) {
      throw Exception('Failed to export reports to CSV: $e');
    }
  }

  /// Export a single report to JSON
  Future<String?> exportReportToJson(BloodReport report) async {
    try {
      final json = _reportToJson(report);
      final file = await _saveTempFile(
        'report_${report.id}.json',
        json,
      );
      return file.path;
    } catch (e) {
      throw Exception('Failed to export report to JSON: $e');
    }
  }

  /// Export profile with all reports to JSON
  Future<String?> exportProfileToJson(
    Profile profile,
    List<BloodReport> reports,
  ) async {
    try {
      final data = {
        'profile': {
          'id': profile.id,
          'name': profile.name,
          'dateOfBirth': profile.dateOfBirth,
          'gender': profile.gender,
          'relationship': profile.relationship,
          'photoPath': profile.photoPath,
          'createdAt': profile.createdAt.toIso8601String(),
        },
        'reports': reports.map((r) => _reportToMap(r)).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0',
      };

      final json = const JsonEncoder.withIndent('  ').convert(data);
      final fileName =
          '${profile.name}_complete_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = await _saveTempFile(fileName, json);
      return file.path;
    } catch (e) {
      throw Exception('Failed to export profile to JSON: $e');
    }
  }

  /// Share exported file
  Future<void> shareFile(String filePath, {String? subject}) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject ?? 'Health Report Export',
      );
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  // ============================================================
  // IMPORT METHODS
  // ============================================================

  /// Import profile data from JSON file
  Future<Map<String, dynamic>> importProfileFromJson() async {
    try {
      // Pick JSON file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate format
      if (!data.containsKey('profile') || !data.containsKey('reports')) {
        throw Exception('Invalid file format');
      }

      // Parse profile
      final profileData = data['profile'] as Map<String, dynamic>;
      final profile = Profile(
        id: null, // Will be assigned by database
        name: profileData['name'] as String,
        dateOfBirth: profileData['dateOfBirth'] as String?,
        gender: profileData['gender'] as String?,
        relationship: profileData['relationship'] as String?,
        photoPath: profileData['photoPath'] as String?,
        createdAt: DateTime.now(), // Use current time for import
      );

      // Parse reports
      final reportsData = data['reports'] as List<dynamic>;
      final reports = reportsData.map((r) {
        final reportMap = r as Map<String, dynamic>;
        return _mapToReport(reportMap, null); // Profile ID will be set later
      }).toList();

      return {
        'profile': profile,
        'reports': reports,
        'version': data['version'] as String? ?? '1.0',
        'exportedAt': data['exportedAt'] as String?,
      };
    } catch (e) {
      throw Exception('Failed to import profile: $e');
    }
  }

  /// Import a single report from JSON
  Future<BloodReport> importReportFromJson(int profileId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      return _mapToReport(data, profileId);
    } catch (e) {
      throw Exception('Failed to import report: $e');
    }
  }

  /// Import reports from CSV
  Future<List<BloodReport>> importReportsFromCsv(int profileId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();
      final rows = const CsvToListConverter().convert(csvString);

      if (rows.isEmpty || rows.length < 2) {
        throw Exception('CSV file is empty or invalid');
      }

      // Parse CSV into reports
      final reportsMap = <int, Map<String, dynamic>>{};

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        final csvReportId = row[0] as int;

        if (!reportsMap.containsKey(csvReportId)) {
          reportsMap[csvReportId] = {
            'testDate': DateTime.parse(row[1] as String),
            'labName': row[2] as String,
            'parameters': <Map<String, dynamic>>[],
          };
        }

        // Store parameter data as map (will create Parameter objects later)
        reportsMap[csvReportId]!['parameters'].add({
          'parameterName': row[3] as String,
          'parameterValue': double.parse(row[4].toString()),
          'unit': row[5] as String,
          'referenceRangeMin':
              row[6] != '' ? double.parse(row[6].toString()) : null,
          'referenceRangeMax':
              row[7] != '' ? double.parse(row[7].toString()) : null,
        });
      }

      // Convert to BloodReport objects
      return reportsMap.values.map((data) {
        // Create Parameter objects from map data
        final paramMaps = data['parameters'] as List<Map<String, dynamic>>;
        final parameters = paramMaps
            .map((p) => Parameter(
                  reportId: 0, // Temporary, will be updated when saved
                  parameterName: p['parameterName'] as String,
                  parameterValue: p['parameterValue'] as double,
                  unit: p['unit'] as String?,
                  referenceRangeMin: p['referenceRangeMin'] as double?,
                  referenceRangeMax: p['referenceRangeMax'] as double?,
                ))
            .toList();

        return BloodReport(
          id: null,
          profileId: profileId,
          testDate: data['testDate'] as DateTime,
          labName: data['labName'] as String,
          parameters: parameters,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to import CSV: $e');
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  String _generateReportCsv(BloodReport report) {
    final List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Parameter',
      'Value',
      'Unit',
      'Reference Range Min',
      'Reference Range Max',
      'Status',
    ]);

    // Parameters
    for (final param in report.parameters) {
      rows.add([
        param.parameterName,
        param.parameterValue,
        param.unit ?? '',
        param.referenceRangeMin ?? '',
        param.referenceRangeMax ?? '',
        param.status,
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  String _reportToJson(BloodReport report) {
    return const JsonEncoder.withIndent('  ').convert(_reportToMap(report));
  }

  Map<String, dynamic> _reportToMap(BloodReport report) {
    return {
      'id': report.id,
      'profileId': report.profileId,
      'testDate': report.testDate.toIso8601String(),
      'labName': report.labName,
      'parameters': report.parameters
          .map((p) => {
                'parameterName': p.parameterName,
                'parameterValue': p.parameterValue,
                'unit': p.unit,
                'referenceRangeMin': p.referenceRangeMin,
                'referenceRangeMax': p.referenceRangeMax,
              })
          .toList(),
    };
  }

  BloodReport _mapToReport(Map<String, dynamic> data, int? profileId) {
    final params = (data['parameters'] as List<dynamic>).map((p) {
      final paramMap = p as Map<String, dynamic>;
      return Parameter(
        reportId: 0, // Temporary, will be updated when saved
        parameterName: paramMap['parameterName'] as String,
        parameterValue: (paramMap['parameterValue'] as num).toDouble(),
        unit: paramMap['unit'] as String?,
        referenceRangeMin: paramMap['referenceRangeMin'] != null
            ? (paramMap['referenceRangeMin'] as num).toDouble()
            : null,
        referenceRangeMax: paramMap['referenceRangeMax'] != null
            ? (paramMap['referenceRangeMax'] as num).toDouble()
            : null,
      );
    }).toList();

    return BloodReport(
      id: null, // Will be assigned by database
      profileId: profileId ?? data['profileId'] as int,
      testDate: DateTime.parse(data['testDate'] as String),
      labName: data['labName'] as String?,
      parameters: params,
    );
  }

  Future<File> _saveTempFile(String fileName, String content) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file;
  }
}
