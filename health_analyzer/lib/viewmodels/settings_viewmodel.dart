import 'package:flutter/foundation.dart';
import '../services/api_key_service.dart';

/// ViewModel for managing app settings, particularly API key management
class SettingsViewModel extends ChangeNotifier {
  final ApiKeyService _apiKeyService;

  bool _hasApiKey = false;
  bool _isLoading = false;
  bool _isValidating = false;
  String? _errorMessage;
  String? _successMessage;
  String _maskedApiKey = '';

  SettingsViewModel({ApiKeyService? apiKeyService})
      : _apiKeyService = apiKeyService ?? ApiKeyService() {
    _initialize();
  }

  // Getters
  bool get hasApiKey => _hasApiKey;
  bool get isLoading => _isLoading;
  bool get isValidating => _isValidating;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get maskedApiKey => _maskedApiKey;

  /// Initialize by checking if API key exists
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _hasApiKey = await _apiKeyService.hasApiKey();
      if (_hasApiKey) {
        final apiKey = await _apiKeyService.getApiKey();
        _maskedApiKey = _maskApiKey(apiKey);
      }
    } catch (e) {
      _errorMessage = 'Failed to load settings: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mask API key for display (show first 8 and last 4 characters)
  String _maskApiKey(String? apiKey) {
    if (apiKey == null || apiKey.length < 12) return '••••••••••••';

    final start = apiKey.substring(0, 8);
    final end = apiKey.substring(apiKey.length - 4);
    final middle = '•' * (apiKey.length - 12);

    return '$start$middle$end';
  }

  /// Clear any messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Validate API key only (without saving)
  Future<bool> validateApiKey(String apiKey) async {
    _isValidating = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final (isValid, message) = await _apiKeyService.validateApiKey(apiKey);

      if (isValid) {
        _successMessage = 'API key is valid! ✓';
      } else {
        _errorMessage = message;
      }

      return isValid;
    } catch (e) {
      _errorMessage = 'Validation error: ${e.toString()}';
      return false;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  /// Save API key (validates first)
  Future<bool> saveApiKey(String apiKey) async {
    _isValidating = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final (isValid, message) =
          await _apiKeyService.validateAndSaveApiKey(apiKey);

      if (isValid) {
        _successMessage = message;
        _hasApiKey = true;
        _maskedApiKey = _maskApiKey(apiKey);
        return true;
      } else {
        _errorMessage = message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to save API key: ${e.toString()}';
      return false;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  /// Update existing API key
  Future<bool> updateApiKey(String newApiKey) async {
    return await saveApiKey(newApiKey);
  }

  /// Delete API key
  Future<void> deleteApiKey() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _apiKeyService.deleteApiKey();
      _hasApiKey = false;
      _maskedApiKey = '';
      _successMessage = 'API key deleted successfully';
    } catch (e) {
      _errorMessage = 'Failed to delete API key: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get the actual API key (for use in services)
  Future<String?> getApiKey() async {
    return await _apiKeyService.getApiKey();
  }

  /// Refresh API key status
  Future<void> refresh() async {
    await _initialize();
  }
}
