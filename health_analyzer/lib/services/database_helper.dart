import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/profile.dart';
import '../models/blood_report.dart';
import '../models/parameter.dart';
import '../utils/constants.dart';

/// Database Helper - Singleton class to manage SQLite database
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(
      documentsDirectory.path,
      AppConstants.databaseName,
    );

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDatabase,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
    );
  }

  /// Enable foreign keys
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Upgrade database schema
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add migration logic here if needed in the future
    // For now, we're on version 1
  }

  /// Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // Profiles table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableProfiles} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date_of_birth TEXT,
        gender TEXT,
        photo_path TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Reports table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableReports} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        test_date TEXT NOT NULL,
        lab_name TEXT,
        report_image_path TEXT,
        ai_analysis TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (profile_id) REFERENCES ${AppConstants.tableProfiles}(id) ON DELETE CASCADE
      )
    ''');

    // Blood parameters table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableBloodParameters} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        report_id INTEGER NOT NULL,
        parameter_name TEXT NOT NULL,
        parameter_value REAL NOT NULL,
        unit TEXT,
        reference_range_min REAL,
        reference_range_max REAL,
        raw_parameter_name TEXT,
        FOREIGN KEY (report_id) REFERENCES ${AppConstants.tableReports}(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for faster queries
    await db.execute('''
      CREATE INDEX idx_parameters_name 
      ON ${AppConstants.tableBloodParameters}(parameter_name)
    ''');

    await db.execute('''
      CREATE INDEX idx_reports_profile 
      ON ${AppConstants.tableReports}(profile_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_reports_date 
      ON ${AppConstants.tableReports}(test_date)
    ''');
  }

  // ==================== PROFILE OPERATIONS ====================

  /// Insert a new profile
  Future<int> insertProfile(Profile profile) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableProfiles,
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all profiles
  Future<List<Profile>> getAllProfiles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableProfiles,
      orderBy: 'name ASC',
    );
    return maps.map((map) => Profile.fromMap(map)).toList();
  }

  /// Get profile by ID
  Future<Profile?> getProfile(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableProfiles,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Profile.fromMap(maps.first);
  }

  /// Update profile
  Future<int> updateProfile(Profile profile) async {
    final db = await database;
    return await db.update(
      AppConstants.tableProfiles,
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  /// Delete profile (cascades to reports and parameters)
  Future<int> deleteProfile(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableProfiles,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== REPORT OPERATIONS ====================

  /// Save blood report with all parameters in a transaction
  Future<int> saveBloodReport({
    required int profileId,
    required DateTime testDate,
    required Map<String, Map<String, dynamic>> parameters,
    String? labName,
    String? imagePath,
  }) async {
    final db = await database;

    return await db.transaction((txn) async {
      // Insert report
      final reportId = await txn.insert(AppConstants.tableReports, {
        'profile_id': profileId,
        'test_date': testDate.toIso8601String(),
        'lab_name': labName,
        'report_image_path': imagePath,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Insert all parameters
      for (var entry in parameters.entries) {
        await txn.insert(AppConstants.tableBloodParameters, {
          'report_id': reportId,
          'parameter_name': entry.key,
          'parameter_value': entry.value['value'],
          'unit': entry.value['unit'],
          'reference_range_min': entry.value['ref_min'],
          'reference_range_max': entry.value['ref_max'],
          'raw_parameter_name': entry.value['raw_name'],
        });
      }

      return reportId;
    });
  }

  /// Get all reports for a profile
  Future<List<BloodReport>> getReportsByProfile(int profileId) async {
    final db = await database;
    final List<Map<String, dynamic>> reportMaps = await db.query(
      AppConstants.tableReports,
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'test_date DESC',
    );

    List<BloodReport> reports = [];
    for (var reportMap in reportMaps) {
      final report = BloodReport.fromMap(reportMap);
      final parameters = await getParametersByReport(report.id!);
      reports.add(report.copyWith(parameters: parameters));
    }

    return reports;
  }

  /// Get all reports across all profiles
  Future<List<BloodReport>> getAllReports() async {
    final db = await database;
    final List<Map<String, dynamic>> reportMaps = await db.query(
      AppConstants.tableReports,
      orderBy: 'test_date DESC',
    );

    List<BloodReport> reports = [];
    for (var reportMap in reportMaps) {
      final report = BloodReport.fromMap(reportMap);
      final parameters = await getParametersByReport(report.id!);
      reports.add(report.copyWith(parameters: parameters));
    }

    return reports;
  }

  /// Get report by ID with parameters
  Future<BloodReport?> getReport(int reportId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableReports,
      where: 'id = ?',
      whereArgs: [reportId],
    );

    if (maps.isEmpty) return null;

    final report = BloodReport.fromMap(maps.first);
    final parameters = await getParametersByReport(reportId);
    return report.copyWith(parameters: parameters);
  }

  /// Delete report (cascades to parameters)
  Future<int> deleteReport(int reportId) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableReports,
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  /// Update AI analysis for a report
  Future<int> updateAiAnalysis(int reportId, String aiAnalysis) async {
    final db = await database;
    return await db.update(
      AppConstants.tableReports,
      {'ai_analysis': aiAnalysis},
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  // ==================== PARAMETER OPERATIONS ====================

  /// Get all parameters for a report
  Future<List<Parameter>> getParametersByReport(int reportId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableBloodParameters,
      where: 'report_id = ?',
      whereArgs: [reportId],
      orderBy: 'parameter_name ASC',
    );
    return maps.map((map) => Parameter.fromMap(map)).toList();
  }

  /// Get trend data for a specific parameter across all reports of a profile
  Future<List<Map<String, dynamic>>> getParameterTrend({
    required int profileId,
    required String parameterName,
  }) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT 
        r.test_date,
        r.lab_name,
        bp.parameter_value,
        bp.unit,
        bp.reference_range_min,
        bp.reference_range_max
      FROM ${AppConstants.tableBloodParameters} bp
      JOIN ${AppConstants.tableReports} r ON bp.report_id = r.id
      WHERE r.profile_id = ? AND bp.parameter_name = ?
      ORDER BY r.test_date ASC
    ''',
      [profileId, parameterName],
    );
  }

  /// Get all unique parameter names for a profile
  Future<List<String>> getAvailableParameters(int profileId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT DISTINCT bp.parameter_name
      FROM ${AppConstants.tableBloodParameters} bp
      JOIN ${AppConstants.tableReports} r ON bp.report_id = r.id
      WHERE r.profile_id = ?
      ORDER BY bp.parameter_name ASC
    ''',
      [profileId],
    );

    return result.map((row) => row['parameter_name'] as String).toList();
  }

  /// Get latest value for each parameter for a profile
  Future<Map<String, Parameter>> getLatestParameterValues(int profileId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT bp.*, r.test_date
      FROM ${AppConstants.tableBloodParameters} bp
      JOIN ${AppConstants.tableReports} r ON bp.report_id = r.id
      WHERE r.profile_id = ?
        AND r.test_date = (
          SELECT MAX(r2.test_date)
          FROM ${AppConstants.tableReports} r2
          JOIN ${AppConstants.tableBloodParameters} bp2 ON r2.id = bp2.report_id
          WHERE r2.profile_id = ? AND bp2.parameter_name = bp.parameter_name
        )
      ORDER BY bp.parameter_name ASC
    ''',
      [profileId, profileId],
    );

    Map<String, Parameter> parameters = {};
    for (var row in result) {
      final parameter = Parameter.fromMap(row);
      parameters[parameter.parameterName] = parameter;
    }
    return parameters;
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Get report count for a profile
  Future<int> getReportCount(int profileId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM ${AppConstants.tableReports}
      WHERE profile_id = ?
    ''',
      [profileId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// Delete database (for testing/reset)
  Future<void> deleteDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(
      documentsDirectory.path,
      AppConstants.databaseName,
    );
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
