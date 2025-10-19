import 'dart:io';
import 'dart:convert';
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

    _model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);
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
          maxOutputTokens: 2048,
        ),
      );

      final extractedText = response.text;
      if (extractedText == null || extractedText.isEmpty) {
        throw Exception('No data extracted from the report');
      }

      // Parse JSON from response
      final jsonData = _parseJsonFromResponse(extractedText);

      // Normalize parameter names
      final normalizedData = _normalizeParameters(jsonData);

      return normalizedData;
    } catch (e) {
      throw Exception('Failed to extract data from report: $e');
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
    // Remove markdown code blocks if present
    String cleaned = response
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      return json.decode(cleaned);
    } catch (e) {
      // Try to find JSON in the response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
      if (jsonMatch != null) {
        return json.decode(jsonMatch.group(0)!);
      }
      throw Exception('Could not parse JSON from response: $e');
    }
  }

  /// Normalize parameter names using LOINC mapper
  Map<String, dynamic> _normalizeParameters(Map<String, dynamic> data) {
    final parameters = data['parameters'] as Map<String, dynamic>? ?? {};
    final normalizedParams = <String, dynamic>{};

    parameters.forEach((key, value) {
      final normalizedKey = LOINCMapper.normalize(key);
      normalizedParams[normalizedKey] = value;

      // Ensure raw_name is preserved
      if (value is Map && !value.containsKey('raw_name')) {
        value['raw_name'] = key;
      }
    });

    return {
      'test_date': data['test_date'],
      'lab_name': data['lab_name'],
      'parameters': normalizedParams,
    };
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
