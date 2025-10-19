import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../services/database_helper.dart';

/// ViewModel for managing user profiles
/// Handles CRUD operations and profile-related business logic
class ProfileViewModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<Profile> _profiles = [];
  Profile? _selectedProfile;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Profile> get profiles => _profiles;
  Profile? get selectedProfile => _selectedProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfiles => _profiles.isNotEmpty;

  /// Initialize the view model by loading all profiles
  Future<void> initialize() async {
    await loadProfiles();
  }

  /// Load all profiles from the database
  Future<void> loadProfiles() async {
    _setLoading(true);
    _clearError();

    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'profiles',
        orderBy: 'name ASC',
      );

      _profiles = maps.map((map) => Profile.fromMap(map)).toList();

      // If no profile is selected but profiles exist, select the first one
      if (_selectedProfile == null && _profiles.isNotEmpty) {
        _selectedProfile = _profiles.first;
      }

      // If selected profile was deleted, clear selection or select another
      if (_selectedProfile != null &&
          !_profiles.any((p) => p.id == _selectedProfile!.id)) {
        _selectedProfile = _profiles.isNotEmpty ? _profiles.first : null;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load profiles: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new profile
  Future<bool> createProfile({
    required String name,
    String? dateOfBirth,
    String? gender,
    String? photoPath,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final profile = Profile(
        name: name,
        dateOfBirth: dateOfBirth,
        gender: gender,
        photoPath: photoPath,
        createdAt: DateTime.now(),
      );

      final db = await _databaseHelper.database;
      final id = await db.insert('profiles', profile.toMap());

      final newProfile = profile.copyWith(id: id);
      _profiles.add(newProfile);

      // Select the newly created profile
      _selectedProfile = newProfile;

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing profile
  Future<bool> updateProfile(Profile profile) async {
    _setLoading(true);
    _clearError();

    try {
      final db = await _databaseHelper.database;
      await db.update(
        'profiles',
        profile.toMap(),
        where: 'id = ?',
        whereArgs: [profile.id],
      );

      final index = _profiles.indexWhere((p) => p.id == profile.id);
      if (index != -1) {
        _profiles[index] = profile;

        // Update selected profile if it's the one being updated
        if (_selectedProfile?.id == profile.id) {
          _selectedProfile = profile;
        }

        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a profile and all associated reports
  Future<bool> deleteProfile(int profileId) async {
    _setLoading(true);
    _clearError();

    try {
      final db = await _databaseHelper.database;

      // Delete profile (reports will be cascade deleted if foreign key is set)
      await db.delete(
        'profiles',
        where: 'id = ?',
        whereArgs: [profileId],
      );

      // Also explicitly delete reports for this profile
      await db.delete(
        'reports',
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );

      _profiles.removeWhere((p) => p.id == profileId);

      // Clear selection if deleted profile was selected
      if (_selectedProfile?.id == profileId) {
        _selectedProfile = _profiles.isNotEmpty ? _profiles.first : null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete profile: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Select a profile
  void selectProfile(Profile profile) {
    _selectedProfile = profile;
    notifyListeners();
  }

  /// Get profile by ID
  Profile? getProfileById(int id) {
    try {
      return _profiles.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get the age of a profile in years
  int? getAge(Profile profile) {
    if (profile.dateOfBirth == null || profile.dateOfBirth!.isEmpty) {
      return null;
    }

    try {
      final dob = DateTime.parse(profile.dateOfBirth!);
      final today = DateTime.now();
      int age = today.year - dob.year;

      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }

      return age;
    } catch (e) {
      return null;
    }
  }

  /// Get profile statistics
  Future<ProfileStatistics> getProfileStatistics(int profileId) async {
    try {
      final db = await _databaseHelper.database;

      // Count total reports
      final reportCountResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM reports WHERE profile_id = ?',
        [profileId],
      );
      final totalReports = reportCountResult.first['count'] as int? ?? 0;

      // Get latest report date
      final latestReportResult = await db.query(
        'reports',
        columns: ['test_date'],
        where: 'profile_id = ?',
        whereArgs: [profileId],
        orderBy: 'test_date DESC',
        limit: 1,
      );

      DateTime? latestReportDate;
      if (latestReportResult.isNotEmpty) {
        latestReportDate = DateTime.parse(
          latestReportResult.first['test_date'] as String,
        );
      }

      // Count unique parameters
      final paramCountResult = await db.rawQuery(
        '''
        SELECT COUNT(DISTINCT bp.parameter_name) as count 
        FROM blood_parameters bp
        INNER JOIN reports r ON bp.report_id = r.id
        WHERE r.profile_id = ?
        ''',
        [profileId],
      );
      final uniqueParameters = paramCountResult.first['count'] as int? ?? 0;

      return ProfileStatistics(
        totalReports: totalReports,
        latestReportDate: latestReportDate,
        uniqueParameters: uniqueParameters,
      );
    } catch (e) {
      return ProfileStatistics(
        totalReports: 0,
        latestReportDate: null,
        uniqueParameters: 0,
      );
    }
  }

  // Private helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

/// Statistics for a profile
class ProfileStatistics {
  final int totalReports;
  final DateTime? latestReportDate;
  final int uniqueParameters;

  ProfileStatistics({
    required this.totalReports,
    required this.latestReportDate,
    required this.uniqueParameters,
  });
}
