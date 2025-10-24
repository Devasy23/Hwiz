import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';

/// Service to manage Gemini API key storage, validation, and retrieval
class ApiKeyService {
  static const String _apiKeyStorageKey = 'gemini_api_key';
  final FlutterSecureStorage _secureStorage;

  ApiKeyService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Save API key to secure storage
  Future<void> saveApiKey(String apiKey) async {
    await _secureStorage.write(key: _apiKeyStorageKey, value: apiKey);
  }

  /// Retrieve API key from secure storage
  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: _apiKeyStorageKey);
  }

  /// Delete API key from secure storage
  Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: _apiKeyStorageKey);
  }

  /// Check if API key exists in storage
  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Validate API key by making a test request to Gemini API
  /// Returns a tuple: (isValid, errorMessage)
  Future<(bool, String?)> validateApiKey(String apiKey) async {
    if (apiKey.trim().isEmpty) {
      return (false, 'API key cannot be empty');
    }

    // Check basic format - Gemini API keys typically start with "AIza"
    if (!apiKey.startsWith('AIza')) {
      return (
        false,
        'Invalid API key format. Gemini API keys should start with "AIza"'
      );
    }

    // Check length - typical Gemini API keys are 39 characters
    if (apiKey.length < 30) {
      return (false, 'API key seems too short. Please check and try again');
    }

    try {
      // Test the API key with a simple request using Gemini 2.5 Flash
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      // Make a minimal test request
      final response = await model.generateContent([
        Content.text('Hello'),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      // If we get here without error, the key is valid
      if (response.text != null) {
        return (true, null);
      } else {
        return (false, 'Invalid response from API. Please check your key');
      }
    } on SocketException catch (e) {
      // Network connectivity issues
      if (e.osError?.errorCode == 7 ||
          e.message.contains('Failed host lookup')) {
        return (
          false,
          'Unable to reach Google AI servers. Please check:\n'
              '• Your internet connection is active\n'
              '• You\'re not behind a restrictive firewall\n'
              '• DNS resolution is working'
        );
      }
      return (
        false,
        'Network error: Unable to connect. Please check your internet connection'
      );
    } on GenerativeAIException catch (e) {
      // Handle specific AI exceptions
      if (e.message.contains('API key not valid') ||
          e.message.contains('invalid_api_key') ||
          e.message.contains('API_KEY_INVALID')) {
        return (false, 'Invalid API key. Please check your key and try again');
      } else if (e.message.contains('quota') || e.message.contains('QUOTA')) {
        return (false, 'API key is valid but quota exceeded. Try again later');
      } else if (e.message.contains('model') || e.message.contains('MODEL')) {
        return (
          false,
          'Model access error. The API key may not have access to this model'
        );
      } else {
        return (false, 'API Error: ${e.message}');
      }
    } on TimeoutException catch (_) {
      return (
        false,
        'Connection timeout. Please check your internet connection and try again'
      );
    } catch (e) {
      // Catch any other errors including ClientException
      final errorStr = e.toString();

      // Check for network-related errors in the error string
      if (errorStr.contains('SocketException') ||
          errorStr.contains('Failed host lookup') ||
          errorStr.contains('ClientException')) {
        return (
          false,
          'Network connection error. Please check your internet connection and try again'
        );
      }

      return (
        false,
        'Validation error: Unable to verify API key. Please try again'
      );
    }
  }

  /// Validate and save API key in one operation
  Future<(bool, String?)> validateAndSaveApiKey(String apiKey) async {
    final (isValid, errorMessage) = await validateApiKey(apiKey);

    if (isValid) {
      await saveApiKey(apiKey);
      return (true, 'API key saved successfully');
    } else {
      return (false, errorMessage);
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}
