import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../../widgets/common/loading_indicator.dart';

/// Screen for scanning/uploading reports
class ReportScanScreen extends StatefulWidget {
  const ReportScanScreen({super.key});

  @override
  State<ReportScanScreen> createState() => _ReportScanScreenState();
}

class _ReportScanScreenState extends State<ReportScanScreen> {
  bool _isProcessing = false;
  double? _processingProgress;

  Future<void> _handleCamera() async {
    final profileVM = context.read<ProfileViewModel>();
    final profile = profileVM.currentProfile;

    if (profile == null) {
      _showError('Please select a profile first');
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingProgress = null;
    });

    try {
      final reportViewModel = context.read<ReportViewModel>();
      final success = await reportViewModel.scanFromCamera(profile.id!);

      if (success && mounted) {
        Navigator.of(context).pop();
        _showSuccess('Report scanned successfully!');
      } else if (mounted && reportViewModel.error != null) {
        _showError(reportViewModel.error!);
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handleGallery() async {
    final profileVM = context.read<ProfileViewModel>();
    final profile = profileVM.currentProfile;

    if (profile == null) {
      _showError('Please select a profile first');
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingProgress = null;
    });

    try {
      final reportViewModel = context.read<ReportViewModel>();
      final success = await reportViewModel.scanFromGallery(profile.id!);

      if (success && mounted) {
        Navigator.of(context).pop();
        _showSuccess('Report scanned successfully!');
      } else if (mounted && reportViewModel.error != null) {
        _showError(reportViewModel.error!);
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handlePdf() async {
    final profileVM = context.read<ProfileViewModel>();
    final profile = profileVM.currentProfile;

    if (profile == null) {
      _showError('Please select a profile first');
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingProgress = null;
    });

    try {
      final reportViewModel = context.read<ReportViewModel>();
      final success = await reportViewModel.scanFromPDF(profile.id!);

      if (success && mounted) {
        Navigator.of(context).pop();
        _showSuccess('Report scanned successfully!');
      } else if (mounted && reportViewModel.error != null) {
        _showError(reportViewModel.error!);
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      _showError('Failed to process PDF: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Scan Report'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isProcessing
          ? LoadingIndicator(
              message: 'Analyzing report...',
              showProgress: _processingProgress != null,
              progress: _processingProgress,
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile indicator
                    Consumer<ProfileViewModel>(
                      builder: (context, profileVM, child) {
                        final profile = profileVM.currentProfile;

                        if (profile == null) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          padding: const EdgeInsets.all(AppTheme.spacing16),
                          decoration: BoxDecoration(
                            color: AppTheme.infoLight,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppTheme.infoColor,
                              ),
                              const SizedBox(width: AppTheme.spacing12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scanning for:',
                                      style: AppTheme.labelSmall.copyWith(
                                        color: AppTheme.infoColor,
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacing4),
                                    Text(
                                      profile.name,
                                      style: AppTheme.titleMedium.copyWith(
                                        color: AppTheme.infoColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: Show profile switcher
                                },
                                child: const Text('Change'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppTheme.spacing40),

                    // Title
                    Text(
                      'Choose scan method',
                      style: AppTheme.headingMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppTheme.spacing8),

                    Text(
                      'Select how you\'d like to upload your report',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppTheme.spacing40),

                    // Scan options
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildScanOption(
                            icon: Icons.camera_alt,
                            label: 'Take Photo',
                            description: 'Use camera to capture report',
                            onTap: _handleCamera,
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          _buildScanOption(
                            icon: Icons.photo_library,
                            label: 'From Gallery',
                            description: 'Choose image from gallery',
                            onTap: _handleGallery,
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          _buildScanOption(
                            icon: Icons.picture_as_pdf,
                            label: 'Upload PDF',
                            description: 'Select PDF file',
                            onTap: _handlePdf,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildScanOption({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      description,
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
