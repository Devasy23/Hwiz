import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'gemini_service.dart';
import 'extraction_validator.dart';
import 'parameter_alias_resolver.dart';
import '../models/parameter.dart';
import '../models/blood_report.dart';

/// Batch processing service for analyzing multiple blood reports efficiently
///
/// Features:
/// - Parallel processing with configurable concurrency
/// - Intelligent rate limiting based on Gemini API limits
/// - Progress tracking and cancellation support
/// - Automatic retry with exponential backoff
/// - Validation and normalization of all extracted data
/// - Real-time progress callbacks
///
/// Usage:
/// ```dart
/// final batchService = BatchProcessingService();
///
/// final result = await batchService.processReports(
///   files: selectedFiles,
///   profileId: currentProfile.id,
///   gender: currentProfile.gender,
///   onProgress: (processed, total, current) {
///     setState(() {
///       progress = processed / total;
///       currentFile = current;
///     });
///   },
///   onReportProcessed: (file, report, error) {
///     if (error != null) {
///       showError(file, error);
///     } else {
///       showSuccess(file, report);
///     }
///   },
/// );
/// ```
class BatchProcessingService {
  final GeminiService _geminiService = GeminiService();

  bool _isCancelled = false;
  Timer? _rateLimitTimer;

  // Gemini API rate limits (per minute)
  // gemini-2.5-flash: 15 RPM (requests per minute) for free tier
  // gemini-2.5-pro: 2 RPM for free tier
  static const int _defaultMaxParallel = 4;
  static const int _maxRequestsPerMinute = 15; // Conservative for free tier
  static const Duration _rateLimitWindow = Duration(minutes: 1);

  int _requestsInCurrentWindow = 0;
  DateTime _windowStartTime = DateTime.now();

  /// Process multiple blood reports in batch
  ///
  /// [files] - List of report files (images or PDFs) to process
  /// [profileId] - Profile ID to associate reports with
  /// [gender] - Gender for reference range selection
  /// [maxParallel] - Maximum parallel requests (default: 4, max: 8)
  /// [maxRetries] - Maximum retry attempts per file (default: 2)
  /// [onProgress] - Callback for progress updates (processed, total, currentFile)
  /// [onReportProcessed] - Callback when each report completes (file, report, error)
  ///
  /// Returns [BatchProcessingResult] with successful and failed reports
  Future<BatchProcessingResult> processReports({
    required List<File> files,
    required int profileId,
    String? gender,
    int maxParallel = _defaultMaxParallel,
    int maxRetries = 2,
    Function(int processed, int total, String? currentFile)? onProgress,
    Function(File file, BloodReport? report, String? error)? onReportProcessed,
  }) async {
    if (files.isEmpty) {
      return BatchProcessingResult(
        successful: [],
        failed: [],
        totalProcessed: 0,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
      );
    }

    // Reset state
    _isCancelled = false;
    _requestsInCurrentWindow = 0;
    _windowStartTime = DateTime.now();

    final startTime = DateTime.now();
    final successful = <BatchReportResult>[];
    final failed = <BatchReportFailure>[];

    // Limit parallel requests to avoid rate limiting
    final effectiveMaxParallel = maxParallel.clamp(1, 8);

    debugPrint('🚀 Starting batch processing of ${files.length} reports');
    debugPrint('   Max parallel: $effectiveMaxParallel');
    debugPrint('   Max retries: $maxRetries');

    // Process in batches
    for (int i = 0;
        i < files.length && !_isCancelled;
        i += effectiveMaxParallel) {
      final batchEnd = (i + effectiveMaxParallel).clamp(0, files.length);
      final batch = files.sublist(i, batchEnd);

      debugPrint(
          '📦 Processing batch ${(i ~/ effectiveMaxParallel) + 1}/${(files.length / effectiveMaxParallel).ceil()}');
      debugPrint(
          '   Files: ${batch.map((f) => f.path.split(Platform.pathSeparator).last).join(", ")}');

      // Wait for rate limit if needed
      await _checkRateLimit(batch.length);

      // Process batch in parallel
      final batchFutures = batch.map((file) async {
        if (_isCancelled) {
          return _BatchResult(
            file: file,
            error: 'Batch processing cancelled by user',
          );
        }

        final fileName = file.path.split(Platform.pathSeparator).last;
        onProgress?.call(
            successful.length + failed.length, files.length, fileName);

        return await _processFileWithRetry(
          file: file,
          profileId: profileId,
          gender: gender,
          maxRetries: maxRetries,
        );
      });

      final batchResults = await Future.wait(batchFutures);

      // Categorize results and trigger callbacks
      for (final result in batchResults) {
        if (result.report != null) {
          final success = BatchReportResult(
            file: result.file,
            report: result.report!,
            confidence: result.confidence ?? 0,
            warnings: result.warnings ?? [],
          );
          successful.add(success);
          onReportProcessed?.call(result.file, result.report, null);
        } else {
          final failure = BatchReportFailure(
            file: result.file,
            error: result.error ?? 'Unknown error',
            attempts: result.attempts ?? 1,
          );
          failed.add(failure);
          onReportProcessed?.call(result.file, null, result.error);
        }
      }

      // Update progress
      onProgress?.call(successful.length + failed.length, files.length, null);

      // Small delay between batches to avoid overwhelming the API
      if (batchEnd < files.length && !_isCancelled) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    final endTime = DateTime.now();

    debugPrint('✅ Batch processing complete!');
    debugPrint('   Successful: ${successful.length}/${files.length}');
    debugPrint('   Failed: ${failed.length}/${files.length}');
    debugPrint('   Duration: ${endTime.difference(startTime).inSeconds}s');
    debugPrint('   ${_isCancelled ? "⚠️ Cancelled by user" : ""}');

    return BatchProcessingResult(
      successful: successful,
      failed: failed,
      totalProcessed: files.length,
      cancelled: _isCancelled,
      startTime: startTime,
      endTime: endTime,
    );
  }

  /// Process a single file with retry logic
  Future<_BatchResult> _processFileWithRetry({
    required File file,
    required int profileId,
    String? gender,
    int maxRetries = 2,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      attempts++;

      try {
        debugPrint(
            '   📄 Processing: ${file.path.split(Platform.pathSeparator).last} (attempt $attempts/$maxRetries)');

        // Extract data from report
        final extractedData = await _geminiService.extractBloodReportData(file);

        // Validate extraction
        final validation = ExtractionValidator.validate(extractedData);
        final confidence =
            ExtractionValidator.calculateConfidenceScore(extractedData);

        if (!validation.isValid && attempts < maxRetries) {
          debugPrint('      ⚠️ Validation failed, retrying...');
          debugPrint('      Errors: ${validation.errors.join(", ")}');
          lastException =
              Exception('Validation failed: ${validation.errors.join(", ")}');

          // Exponential backoff
          await Future.delayed(Duration(seconds: attempts * 2));
          continue;
        }

        // Process and normalize parameters
        final parameters =
            extractedData['parameters'] as Map<String, dynamic>? ?? {};
        final processedParams = await _processParameters(
          parameters: parameters,
          profileId: profileId,
          gender: gender,
        );

        // Create report object (without saving to DB)
        final report = BloodReport(
          id: null,
          profileId: profileId,
          testDate: DateTime.tryParse(extractedData['test_date'] ?? '') ??
              DateTime.now(),
          reportImagePath: file.path,
          labName: extractedData['lab_name'],
          createdAt: DateTime.now(),
          parameters: processedParams,
        );

        debugPrint('      ✅ Successfully processed');

        return _BatchResult(
          file: file,
          report: report,
          confidence: confidence,
          warnings: validation.warnings,
          attempts: attempts,
        );
      } catch (e) {
        lastException = e as Exception?;
        debugPrint('      ❌ Error: $e');

        if (attempts < maxRetries) {
          // Exponential backoff
          await Future.delayed(Duration(seconds: attempts * 2));
        }
      }
    }

    return _BatchResult(
      file: file,
      error: lastException?.toString() ?? 'Failed after $maxRetries attempts',
      attempts: attempts,
    );
  }

  /// Process and normalize parameters
  Future<List<Parameter>> _processParameters({
    required Map<String, dynamic> parameters,
    required int profileId,
    String? gender,
  }) async {
    final paramList = <Parameter>[];

    // Convert to parameter objects
    for (final entry in parameters.entries) {
      final paramData = entry.value as Map<String, dynamic>;

      // Get or fill reference ranges
      final enhanced = ParameterAliasResolver.getCanonicalWithRanges(
        entry.key,
        paramData['value'],
        paramData['unit'],
        existingMin: paramData['ref_min'],
        existingMax: paramData['ref_max'],
        gender: gender,
      );

      paramList.add(Parameter(
        id: null,
        reportId: 0, // Will be set when saving to database
        parameterName: enhanced['canonical_name'] as String,
        parameterValue: (enhanced['value'] as num).toDouble(),
        unit: enhanced['unit'] as String?,
        referenceRangeMin: enhanced['reference_min'] as double?,
        referenceRangeMax: enhanced['reference_max'] as double?,
        rawParameterName: paramData['raw_name'] as String?,
      ));
    }

    // Merge duplicates
    final mergedParams = ParameterAliasResolver.mergeDuplicates(paramList);

    return mergedParams;
  }

  /// Check and enforce rate limiting
  Future<void> _checkRateLimit(int requestCount) async {
    final now = DateTime.now();
    final elapsed = now.difference(_windowStartTime);

    // Reset window if expired
    if (elapsed >= _rateLimitWindow) {
      _requestsInCurrentWindow = 0;
      _windowStartTime = now;
      return;
    }

    // Check if adding these requests would exceed limit
    if (_requestsInCurrentWindow + requestCount > _maxRequestsPerMinute) {
      final waitTime = _rateLimitWindow - elapsed;
      debugPrint('⏳ Rate limit reached. Waiting ${waitTime.inSeconds}s...');

      await Future.delayed(waitTime);

      // Reset after waiting
      _requestsInCurrentWindow = 0;
      _windowStartTime = DateTime.now();
    }

    _requestsInCurrentWindow += requestCount;
  }

  /// Cancel ongoing batch processing
  void cancel() {
    debugPrint('🛑 Cancelling batch processing...');
    _isCancelled = true;
    _rateLimitTimer?.cancel();
  }

  /// Reset cancellation state
  void reset() {
    _isCancelled = false;
    _requestsInCurrentWindow = 0;
    _windowStartTime = DateTime.now();
  }

  /// Check if processing is cancelled
  bool get isCancelled => _isCancelled;
}

/// Internal result holder for batch processing
class _BatchResult {
  final File file;
  final BloodReport? report;
  final String? error;
  final int? confidence;
  final List<String>? warnings;
  final int? attempts;

  const _BatchResult({
    required this.file,
    this.report,
    this.error,
    this.confidence,
    this.warnings,
    this.attempts,
  });
}

/// Result of batch processing operation
class BatchProcessingResult {
  final List<BatchReportResult> successful;
  final List<BatchReportFailure> failed;
  final int totalProcessed;
  final bool cancelled;
  final DateTime startTime;
  final DateTime endTime;

  const BatchProcessingResult({
    required this.successful,
    required this.failed,
    required this.totalProcessed,
    this.cancelled = false,
    required this.startTime,
    required this.endTime,
  });

  /// Number of successfully processed reports
  int get successCount => successful.length;

  /// Number of failed reports
  int get failureCount => failed.length;

  /// Success rate (0.0 to 1.0)
  double get successRate =>
      totalProcessed > 0 ? successCount / totalProcessed : 0.0;

  /// Total processing duration
  Duration get duration => endTime.difference(startTime);

  /// Average time per report
  Duration get averageTimePerReport => totalProcessed > 0
      ? Duration(milliseconds: duration.inMilliseconds ~/ totalProcessed)
      : Duration.zero;

  /// Check if any reports had warnings
  bool get hasWarnings => successful.any((r) => r.warnings.isNotEmpty);

  /// Get all warnings from successful reports
  List<String> get allWarnings => successful.expand((r) => r.warnings).toList();

  /// Summary string for display
  String getSummary() {
    final buffer = StringBuffer();
    buffer.writeln('Batch Processing Complete');
    buffer.writeln('━' * 40);
    buffer.writeln('✅ Successful: $successCount/$totalProcessed');
    buffer.writeln('❌ Failed: $failureCount/$totalProcessed');
    buffer
        .writeln('📊 Success Rate: ${(successRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('⏱️  Duration: ${duration.inSeconds}s');
    buffer.writeln('📈 Avg per report: ${averageTimePerReport.inSeconds}s');

    if (cancelled) {
      buffer.writeln('⚠️  Cancelled by user');
    }

    if (hasWarnings) {
      buffer.writeln('⚠️  ${allWarnings.length} warnings detected');
    }

    return buffer.toString();
  }
}

/// Successfully processed report
class BatchReportResult {
  final File file;
  final BloodReport report;
  final int confidence;
  final List<String> warnings;

  const BatchReportResult({
    required this.file,
    required this.report,
    required this.confidence,
    required this.warnings,
  });

  /// Get file name without path
  String get fileName => file.path.split(Platform.pathSeparator).last;

  /// Check if this report has high confidence
  bool get isHighConfidence => confidence >= 80;

  /// Check if this report has warnings
  bool get hasWarnings => warnings.isNotEmpty;
}

/// Failed report processing
class BatchReportFailure {
  final File file;
  final String error;
  final int attempts;

  const BatchReportFailure({
    required this.file,
    required this.error,
    required this.attempts,
  });

  /// Get file name without path
  String get fileName => file.path.split(Platform.pathSeparator).last;

  /// Check if error is due to rate limiting
  bool get isRateLimitError =>
      error.toLowerCase().contains('quota') ||
      error.toLowerCase().contains('rate limit');

  /// Check if error is due to network issues
  bool get isNetworkError =>
      error.toLowerCase().contains('network') ||
      error.toLowerCase().contains('connection') ||
      error.toLowerCase().contains('timeout');

  /// Check if error is due to invalid image/file
  bool get isFileError =>
      error.toLowerCase().contains('image') ||
      error.toLowerCase().contains('file') ||
      error.toLowerCase().contains('format');
}
