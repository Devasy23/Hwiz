import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/constants.dart';
import 'loinc_mapper.dart';

/// Gemini Service - Handles OCR and data extraction from blood reports
class GeminiService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  GenerativeModel? _model;

  /// Initialize Gemini model with API key
  Future<void> initialize() async {
    final apiKey = await _secureStorage.read(
      key: AppConstants.geminiApiKeyStorage,
    );
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not found. Please set it in settings.');
    }

    // Get selected model from storage, default to gemini-2.5-flash
    final selectedModel = await _secureStorage.read(
          key: 'selected_gemini_model',
        ) ??
        'gemini-2.5-flash';

    _model = GenerativeModel(model: selectedModel, apiKey: apiKey);
  }

  /// Set API key in secure storage
  Future<void> setApiKey(String apiKey) async {
    await _secureStorage.write(
      key: AppConstants.geminiApiKeyStorage,
      value: apiKey,
    );
    await initialize();
  }

  /// Extract blood report data from image or PDF
  Future<Map<String, dynamic>> extractBloodReportData(File file) async {
    if (_model == null) {
      await initialize();
    }

    final bytes = await file.readAsBytes();
    final mimeType = _getMimeType(file.path);

    final prompt = _buildExtractionPrompt();

    final content = [
      Content.multi([TextPart(prompt), DataPart(mimeType, bytes)]),
    ];

    try {
      final response = await _model!.generateContent(
        content,
        generationConfig: GenerationConfig(
          temperature: 0.1, // Low temperature for consistent output
          maxOutputTokens: 4096, // Increased token limit
        ),
      );

      final extractedText = response.text;
      if (extractedText == null || extractedText.isEmpty) {
        throw Exception('No data extracted from the report');
      }

      debugPrint('🔍 Raw Gemini Response:');
      debugPrint(extractedText);

      // Parse JSON from response with better error handling
      final jsonData = _parseJsonFromResponse(extractedText);

      // Normalize parameter names
      final normalizedData = _normalizeParameters(jsonData);

      return normalizedData;
    } on FormatException catch (e) {
      debugPrint('❌ JSON Parse Error: $e');
      throw Exception(
          'Failed to parse data from report. The AI response was incomplete. Please try again with a clearer image.');
    } catch (e) {
      debugPrint('❌ Extraction Error: $e');
      throw Exception('Failed to extract data from report: ${e.toString()}');
    }
  }

  /// Build the prompt for blood report extraction
  String _buildExtractionPrompt() {
    return '''
You are an expert medical document analyzer. Extract all blood test parameters from this blood report image/PDF.

CRITICAL INSTRUCTIONS:
1. Return ONLY valid JSON, no other text
2. Normalize ALL parameter names to lowercase with underscores (e.g., "RBC Count" → "rbc_count")
3. Include these fields for each parameter:
   - value: numeric value only (no units)
   - unit: the unit of measurement
   - ref_min: minimum reference range (if available)
   - ref_max: maximum reference range (if available)
   - raw_name: the exact parameter name as written in the report

4. Also include:
   - test_date: in YYYY-MM-DD format
   - lab_name: name of the laboratory (if visible)

PARAMETER NAME NORMALIZATION RULES:
- "RBC" / "Red Blood Cells" / "Erythrocytes" → "rbc_count"
- "WBC" / "White Blood Cells" / "Leukocytes" → "wbc_count"
- "Hemoglobin" / "Hb" / "HGB" → "hemoglobin"
- "Hematocrit" / "HCT" / "PCV" → "hematocrit"
- "Platelets" / "PLT" → "platelet_count"
- Apply similar normalization to ALL parameters

JSON FORMAT:
{
  "test_date": "YYYY-MM-DD",
  "lab_name": "Laboratory Name",
  "parameters": {
    "rbc_count": {
      "value": 5.2,
      "unit": "million cells/μL",
      "ref_min": 4.5,
      "ref_max": 5.9,
      "raw_name": "RBC Count"
    },
    "wbc_count": {
      "value": 7500,
      "unit": "cells/μL",
      "ref_min": 4000,
      "ref_max": 11000,
      "raw_name": "WBC"
    }
    // ... more parameters
  }
}

Extract ALL visible parameters. If reference ranges are not shown, omit ref_min and ref_max.
Return ONLY the JSON, nothing else.
''';
  }

  /// Parse JSON from Gemini response
  Map<String, dynamic> _parseJsonFromResponse(String response) {
    debugPrint('📝 Parsing JSON from response (length: ${response.length})');

    // Remove markdown code blocks if present
    String cleaned =
        response.replaceAll('```json', '').replaceAll('```', '').trim();

    // Remove any text before the first {
    final firstBrace = cleaned.indexOf('{');
    if (firstBrace > 0) {
      cleaned = cleaned.substring(firstBrace);
    }

    // Remove any text after the last }
    final lastBrace = cleaned.lastIndexOf('}');
    if (lastBrace > 0 && lastBrace < cleaned.length - 1) {
      cleaned = cleaned.substring(0, lastBrace + 1);
    }

    debugPrint(
        '🧹 Cleaned JSON (first 200 chars): ${cleaned.substring(0, cleaned.length < 200 ? cleaned.length : 200)}');

    try {
      final decoded = json.decode(cleaned);
      debugPrint('✅ Successfully parsed JSON');
      return decoded;
    } on FormatException catch (e) {
      debugPrint('❌ JSON Parse Error: $e');
      debugPrint('📄 Problematic JSON:\n$cleaned');

      // Try to find and extract complete JSON object
      final jsonMatch =
          RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(cleaned);
      if (jsonMatch != null) {
        try {
          debugPrint('🔄 Trying to parse extracted JSON...');
          return json.decode(jsonMatch.group(0)!);
        } catch (e2) {
          debugPrint('❌ Extracted JSON also failed: $e2');
        }
      }

      throw FormatException(
          'Could not parse JSON from AI response. Response may be incomplete.');
    }
  }

  /// Normalize parameter names using LOINC mapper
  Map<String, dynamic> _normalizeParameters(Map<String, dynamic> data) {
    try {
      debugPrint('🔄 Normalizing parameters...');
      final parameters = data['parameters'] as Map<String, dynamic>? ?? {};
      final normalizedParams = <String, dynamic>{};

      parameters.forEach((key, value) {
        try {
          debugPrint('  Processing parameter: $key');
          final normalizedKey = LOINCMapper.normalize(key);
          debugPrint('    Normalized to: $normalizedKey');
          normalizedParams[normalizedKey] = value;

          // Ensure raw_name is preserved
          if (value is Map && !value.containsKey('raw_name')) {
            value['raw_name'] = key;
          }
        } catch (e) {
          debugPrint('    ❌ Error normalizing $key: $e');
          // Skip this parameter if normalization fails
        }
      });

      debugPrint(
          '✅ Normalization complete. ${normalizedParams.length} parameters processed.');

      return {
        'test_date': data['test_date'],
        'lab_name': data['lab_name'],
        'parameters': normalizedParams,
      };
    } catch (e) {
      debugPrint('❌ Error in _normalizeParameters: $e');
      rethrow;
    }
  }

  /// Get MIME type from file path
  String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'image/jpeg';
    }
  }

  /// Test API key validity
  Future<bool> testApiKey(String apiKey) async {
    try {
      final testModel = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
      );

      final response = await testModel.generateContent([Content.text('Hello')]);

      return response.text != null;
    } catch (e) {
      return false;
    }
  }

  /// Extract data with retry logic
  Future<Map<String, dynamic>> extractWithRetry(
    File file, {
    int maxAttempts = AppConstants.maxRetryAttempts,
  }) async {
    int attempt = 0;
    Exception? lastException;

    while (attempt < maxAttempts) {
      attempt++;
      try {
        return await extractBloodReportData(file);
      } catch (e) {
        lastException = e as Exception;
        if (attempt < maxAttempts) {
          // Exponential backoff
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }

    throw lastException ?? Exception('Failed after $maxAttempts attempts');
  }
}
