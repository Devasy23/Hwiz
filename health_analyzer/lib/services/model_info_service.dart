import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service to manage Gemini model information
///
/// This service provides information about available Gemini models.
/// Models are dynamically fetched from Google's API.
class ModelInfoService {
  /// Fetch available models dynamically from Gemini API
  Future<List<ModelOption>> fetchAvailableModels(String apiKey) async {
    developer.log('🔍 Fetching available Gemini models from API...');

    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models?key=$apiKey');

      developer.log(
          '📡 Making API request to: ${url.toString().replaceAll(apiKey, "***")}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final models = data['models'] as List;

        developer
            .log('✅ Successfully fetched ${models.length} models from API');

        // Log all available models
        developer.log('📋 AVAILABLE MODELS:');
        developer.log('=' * 80);

        final availableModels = <ModelOption>[];

        for (final model in models) {
          final name = model['name'] as String;
          final displayName = model['displayName'] as String? ?? name;
          final description =
              model['description'] as String? ?? 'No description';
          final supportedMethods =
              (model['supportedGenerationMethods'] as List?)?.cast<String>() ??
                  [];
          final inputTokenLimit = model['inputTokenLimit'] as int? ?? 0;
          final outputTokenLimit = model['outputTokenLimit'] as int? ?? 0;

          // Extract model ID
          final modelId = name.replaceFirst('models/', '');

          developer.log('');
          developer.log('🤖 Model: $modelId');
          developer.log('   Display Name: $displayName');
          developer.log('   Description: $description');
          developer.log('   Supported Methods: ${supportedMethods.join(", ")}');
          developer.log('   Input Token Limit: $inputTokenLimit');
          developer.log('   Output Token Limit: $outputTokenLimit');

          // Only include models that support generateContent
          if (supportedMethods.contains('generateContent')) {
            final info = _createModelInfo(modelId, displayName, description,
                inputTokenLimit, outputTokenLimit);
            availableModels.add(ModelOption(id: modelId, info: info));
            developer.log('   ✅ SUPPORTS generateContent - ADDED TO LIST');
          } else {
            developer.log('   ❌ Does not support generateContent - SKIPPED');
          }
        }

        developer.log('=' * 80);
        developer.log(
            '✨ Total models supporting generateContent: ${availableModels.length}');

        // Sort by recommended first
        availableModels.sort((a, b) {
          if (a.info.recommended && !b.info.recommended) return -1;
          if (!a.info.recommended && b.info.recommended) return 1;
          return a.id.compareTo(b.id);
        });

        return availableModels;
      } else {
        developer.log('❌ API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch models: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('❌ Exception while fetching models: $e');
      developer.log('⚠️  Falling back to static model list');
      return getAllAvailableModels();
    }
  }

  /// Create model info from API data
  ModelDisplayInfo _createModelInfo(
    String modelId,
    String displayName,
    String description,
    int inputTokenLimit,
    int outputTokenLimit,
  ) {
    // Check if we have custom info for known models
    final knownInfo = getModelDisplayInfo()[modelId];
    if (knownInfo != null) {
      return knownInfo;
    }

    // Create info for unknown models
    return ModelDisplayInfo(
      name: displayName,
      description: description,
      recommended: _isRecommended(modelId),
      speed: _estimateSpeed(modelId),
      quality: _estimateQuality(modelId),
      inputTokenLimit: inputTokenLimit,
      outputTokenLimit: outputTokenLimit,
    );
  }

  bool _isRecommended(String modelId) {
    return (modelId.contains('flash') || modelId.contains('pro')) &&
        !modelId.contains('exp') &&
        !modelId.contains('vision') &&
        modelId.contains('1.5');
  }

  String _estimateSpeed(String modelId) {
    if (modelId.contains('flash-8b')) return 'Fastest';
    if (modelId.contains('flash')) return 'Very Fast';
    if (modelId.contains('pro')) return 'Fast';
    return 'Medium';
  }

  String _estimateQuality(String modelId) {
    if (modelId.contains('pro')) return 'Best';
    if (modelId.contains('flash') && !modelId.contains('8b'))
      return 'Excellent';
    return 'Good';
  }

  /// Get all available Gemini models (static fallback)
  List<ModelOption> getAllAvailableModels() {
    final displayInfo = getModelDisplayInfo();
    return displayInfo.entries.map((entry) {
      return ModelOption(id: entry.key, info: entry.value);
    }).toList();
  }

  /// Get model display information for all current Gemini models
  /// Updated regularly to reflect latest available models
  Map<String, ModelDisplayInfo> getModelDisplayInfo() {
    return {
      // Gemini 2.0 Models (Latest - December 2024)
      'gemini-2.0-flash-exp': ModelDisplayInfo(
        name: 'Gemini 2.0 Flash (Experimental)',
        description:
            '🆕 Latest experimental model with enhanced multimodal capabilities. Best for cutting-edge OCR tasks.',
        recommended: true,
        speed: 'Very Fast',
        quality: 'Excellent',
        inputTokenLimit: 1048576,
        outputTokenLimit: 8192,
      ),

      // Gemini 1.5 Models (Stable - Production Ready)
      'gemini-1.5-flash': ModelDisplayInfo(
        name: 'Gemini 1.5 Flash',
        description:
            '⚡ Fast and efficient, perfect for OCR and vision tasks. Best balance of speed and quality for medical documents.',
        recommended: true,
        speed: 'Very Fast',
        quality: 'Excellent',
        inputTokenLimit: 1048576,
        outputTokenLimit: 8192,
      ),

      'gemini-1.5-flash-8b': ModelDisplayInfo(
        name: 'Gemini 1.5 Flash 8B',
        description:
            '🚀 Smallest, fastest model. Good for quick OCR tasks with simpler documents.',
        recommended: false,
        speed: 'Fastest',
        quality: 'Very Good',
        inputTokenLimit: 1048576,
        outputTokenLimit: 8192,
      ),

      'gemini-1.5-pro': ModelDisplayInfo(
        name: 'Gemini 1.5 Pro',
        description:
            '⭐ Most capable model with highest accuracy. Best for complex medical documents with multiple parameters.',
        recommended: true,
        speed: 'Fast',
        quality: 'Best',
        inputTokenLimit: 2097152,
        outputTokenLimit: 8192,
      ),

      'gemini-1.5-pro-exp': ModelDisplayInfo(
        name: 'Gemini 1.5 Pro (Experimental)',
        description:
            '🔬 Experimental Pro version with latest improvements. Higher quality but may be less stable.',
        recommended: false,
        speed: 'Fast',
        quality: 'Best',
        inputTokenLimit: 2097152,
        outputTokenLimit: 8192,
      ),

      // Legacy models (for backwards compatibility)
      'gemini-pro-vision': ModelDisplayInfo(
        name: 'Gemini Pro Vision (Legacy)',
        description:
            '📜 Legacy vision model. Consider upgrading to Gemini 1.5 Flash for better performance.',
        recommended: false,
        speed: 'Medium',
        quality: 'Good',
        inputTokenLimit: 16384,
        outputTokenLimit: 2048,
      ),
    };
  }

  /// Get recommended models specifically for OCR/Vision tasks
  List<String> getRecommendedModelsForOCR() {
    return [
      'gemini-2.0-flash-exp', // Latest
      'gemini-1.5-flash', // Best balance
      'gemini-1.5-pro', // Highest quality
    ];
  }

  /// Get the default model (most reliable and balanced)
  String getDefaultModel() {
    return 'gemini-1.5-flash';
  }

  /// Get information about model updates
  String getModelUpdateInfo() {
    return '''
Model List Last Updated: October 2025

Latest Models:
• Gemini 2.0 Flash (Experimental) - Released Dec 2024
• Gemini 1.5 Pro - Stable production model
• Gemini 1.5 Flash - Recommended for most use cases

For the latest model information, visit:
https://ai.google.dev/gemini-api/docs/models/gemini
    ''';
  }
}

/// Model option with ID and display info
class ModelOption {
  final String id;
  final ModelDisplayInfo info;

  ModelOption({required this.id, required this.info});
}

/// Display information for a model
class ModelDisplayInfo {
  final String name;
  final String description;
  final bool recommended;
  final String speed;
  final String quality;
  final int inputTokenLimit;
  final int outputTokenLimit;

  ModelDisplayInfo({
    required this.name,
    required this.description,
    required this.recommended,
    required this.speed,
    required this.quality,
    required this.inputTokenLimit,
    required this.outputTokenLimit,
  });
}
