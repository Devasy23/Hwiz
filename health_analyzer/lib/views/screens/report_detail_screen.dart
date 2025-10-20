import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../../models/blood_report.dart';
import '../../models/parameter.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'parameter_trend_screen.dart';

/// Screen to display detailed view of a blood report
class ReportDetailScreen extends StatefulWidget {
  final BloodReport report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  List<Parameter>? _parameters;
  bool _isLoading = true;
  bool _showImage = false;
  final PdfViewerController _pdfViewerController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    debugPrint('🔍 ReportDetailScreen initialized');
    debugPrint('  Report ID: ${widget.report.id}');
    debugPrint('  Test Date: ${widget.report.testDate}');
    debugPrint('  Lab Name: ${widget.report.labName}');
    _loadParameters();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  Future<void> _loadParameters() async {
    debugPrint('📋 Loading parameters for report ID: ${widget.report.id}');
    setState(() {
      _isLoading = true;
    });

    try {
      final params =
          await context.read<ReportViewModel>().getParametersForReport(
                widget.report.id!,
              );

      debugPrint('✅ Loaded ${params.length} parameters');
      for (var i = 0; i < params.length && i < 5; i++) {
        debugPrint(
            '  - ${params[i].parameterName}: ${params[i].parameterValue} ${params[i].unit}');
      }

      if (mounted) {
        setState(() {
          _parameters = params;
          _isLoading = false;
        });
        debugPrint('✅ Parameters set in state, UI should update');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading parameters: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _parameters = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading parameters: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParameterTrendScreen(
                    profileId: widget.report.profileId,
                    profileName: 'Profile',
                  ),
                ),
              );
            },
            tooltip: 'View Trends',
          ),
          if (widget.report.reportImagePath != null)
            IconButton(
              icon: Icon(_showImage ? Icons.description : Icons.image),
              onPressed: () {
                debugPrint(
                    '🖼️ Toggling view: ${_showImage ? "to Data" : "to Report"}');
                debugPrint('  Image Path: ${widget.report.reportImagePath}');
                setState(() {
                  _showImage = !_showImage;
                });
              },
              tooltip: _showImage ? 'View Data' : 'View Report',
            ),
        ],
      ),
      body: _showImage && widget.report.reportImagePath != null
          ? _buildImageView()
          : _buildDataView(),
    );
  }

  Widget _buildImageView() {
    final imagePath = widget.report.reportImagePath!;
    final isPDF = imagePath.toLowerCase().endsWith('.pdf');

    debugPrint('🖼️ Building image view');
    debugPrint('  Path: $imagePath');
    debugPrint('  Is PDF: $isPDF');
    debugPrint('  File exists: ${File(imagePath).existsSync()}');

    if (isPDF) {
      return _buildPDFView(imagePath);
    }

    // Check if file exists before trying to display
    if (!File(imagePath).existsSync()) {
      debugPrint('❌ Image file does not exist at: $imagePath');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.broken_image,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                'Report image not found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The original scan may have been moved or deleted.',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showImage = false;
                  });
                },
                icon: const Icon(Icons.list),
                label: const Text('View Data Instead'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('❌ Error loading image: $error');
              debugPrint('Stack trace: $stackTrace');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Error loading image',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error.toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showImage = false;
                          });
                        },
                        icon: const Icon(Icons.list),
                        label: const Text('View Data Instead'),
                      ),
                    ],
                  ),
                ),
              );
            },
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) {
                debugPrint('✅ Image loaded synchronously');
                return child;
              }
              if (frame == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              debugPrint('✅ Image loaded (frame: $frame)');
              return child;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPDFView(String pdfPath) {
    debugPrint('📄 Building PDF view');
    debugPrint('  Path: $pdfPath');
    debugPrint('  File exists: ${File(pdfPath).existsSync()}');

    // Check if PDF file exists
    if (!File(pdfPath).existsSync()) {
      debugPrint('❌ PDF file does not exist at: $pdfPath');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.picture_as_pdf,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                'PDF not found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'The original PDF may have been moved or deleted.',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showImage = false;
                  });
                },
                icon: const Icon(Icons.list),
                label: const Text('View Data Instead'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // PDF Toolbar
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_out),
                onPressed: () {
                  _pdfViewerController.zoomLevel =
                      (_pdfViewerController.zoomLevel - 0.25).clamp(1.0, 3.0);
                },
                tooltip: 'Zoom Out',
              ),
              IconButton(
                icon: const Icon(Icons.zoom_in),
                onPressed: () {
                  _pdfViewerController.zoomLevel =
                      (_pdfViewerController.zoomLevel + 0.25).clamp(1.0, 3.0);
                },
                tooltip: 'Zoom In',
              ),
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: () {
                  _pdfViewerController.jumpToPage(1);
                },
                tooltip: 'First Page',
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: () {
                  _pdfViewerController.jumpToPage(
                    _pdfViewerController.pageCount,
                  );
                },
                tooltip: 'Last Page',
              ),
            ],
          ),
        ),
        // PDF Viewer
        Expanded(
          child: Container(
            color: Colors.grey[300],
            child: SfPdfViewer.file(
              File(pdfPath),
              controller: _pdfViewerController,
              enableDoubleTapZooming: true,
              enableTextSelection: true,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              canShowPaginationDialog: true,
              pageLayoutMode: PdfPageLayoutMode.continuous,
              onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                debugPrint('✅ PDF loaded successfully');
                debugPrint('  Total pages: ${details.document.pages.count}');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'PDF loaded successfully (${details.document.pages.count} pages)',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                debugPrint('❌ PDF load failed: ${details.error}');
                debugPrint('  Description: ${details.description}');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error loading PDF: ${details.error}'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report header
          _buildReportHeader(),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Parameters section
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_parameters == null || _parameters!.isEmpty)
            _buildNoParameters()
          else
            _buildParametersList(),
        ],
      ),
    );
  }

  Widget _buildReportHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Test Date',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMMM dd, yyyy').format(widget.report.testDate),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (widget.report.labName != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.local_hospital,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Laboratory',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.report.labName!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoParameters() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.science_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Parameters Found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'This report doesn\'t have any parameters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParametersList() {
    // Group parameters by status
    final normal = _parameters!.where((p) => p.isNormal).toList();
    final abnormal = _parameters!.where((p) => !p.isNormal).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (abnormal.isNotEmpty) ...[
          _buildSectionHeader('Abnormal Values', abnormal.length, Colors.red),
          const SizedBox(height: 12),
          ...abnormal.map((param) => _ParameterCard(
                parameter: param,
                report: widget.report,
              )),
          const SizedBox(height: 24),
        ],
        if (normal.isNotEmpty) ...[
          _buildSectionHeader('Normal Values', normal.length, Colors.green),
          const SizedBox(height: 12),
          ...normal.map((param) => _ParameterCard(
                parameter: param,
                report: widget.report,
              )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}

class _ParameterCard extends StatelessWidget {
  final Parameter parameter;
  final BloodReport report;

  const _ParameterCard({
    required this.parameter,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final isNormal = parameter.isNormal;
    final statusColor = isNormal ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to trend screen for this parameter
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParameterTrendScreen(
                profileId: report.profileId,
                profileName:
                    'Profile', // You can pass the actual name if available
                initialParameter: parameter.parameterName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatParameterName(parameter.parameterName),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Icon(
                              Icons.show_chart,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                        if (parameter.rawParameterName != null &&
                            parameter.rawParameterName !=
                                parameter.parameterName)
                          Text(
                            parameter.rawParameterName!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      parameter.status.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Value',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${parameter.parameterValue} ${parameter.unit ?? ''}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                      ),
                    ],
                  ),
                  if (parameter.referenceRangeMin != null &&
                      parameter.referenceRangeMax != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Reference Range',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${parameter.referenceRangeMin} - ${parameter.referenceRangeMax}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatParameterName(String name) {
    // Convert snake_case to Title Case
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
