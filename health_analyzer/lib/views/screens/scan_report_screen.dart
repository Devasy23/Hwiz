import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../models/profile.dart';

/// Screen for scanning blood reports
class ScanReportScreen extends StatefulWidget {
  final Profile? preSelectedProfile;

  const ScanReportScreen({
    super.key,
    this.preSelectedProfile,
  });

  @override
  State<ScanReportScreen> createState() => _ScanReportScreenState();
}

class _ScanReportScreenState extends State<ScanReportScreen> {
  Profile? _selectedProfile;

  @override
  void initState() {
    super.initState();
    _selectedProfile = widget.preSelectedProfile;
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = context.watch<ProfileViewModel>();
    final reportViewModel = context.watch<ReportViewModel>();

    // Auto-select first profile if none selected
    if (_selectedProfile == null && profileViewModel.hasProfiles) {
      _selectedProfile = profileViewModel.profiles.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Blood Report'),
        centerTitle: true,
      ),
      body: reportViewModel.isScanning
          ? _buildScanningView(reportViewModel)
          : _buildScanOptions(context, profileViewModel),
    );
  }

  Widget _buildScanningView(ReportViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: viewModel.scanProgress,
                strokeWidth: 8,
                backgroundColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Analyzing Report...',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              _getScanningMessage(viewModel.scanProgress),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            if (viewModel.scanProgress != null) ...[
              const SizedBox(height: 24),
              Text(
                '${(viewModel.scanProgress! * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanOptions(
      BuildContext context, ProfileViewModel profileViewModel) {
    if (!profileViewModel.hasProfiles) {
      return _buildNoProfilesView(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Profile>(
                    value: _selectedProfile,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: profileViewModel.profiles
                        .map((profile) => DropdownMenuItem(
                              value: profile,
                              child: Text(profile.name),
                            ))
                        .toList(),
                    onChanged: (profile) {
                      setState(() {
                        _selectedProfile = profile;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Instructions
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Scanning Tips',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip(context, 'Ensure good lighting'),
                  _buildTip(context, 'Keep report flat and in focus'),
                  _buildTip(context, 'Include all parameter values'),
                  _buildTip(context, 'Supports both images and PDFs'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Scan options
          Text(
            'Choose Scan Method',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          _ScanOptionCard(
            icon: Icons.camera_alt,
            title: 'Take Photo',
            subtitle: 'Use camera to capture report',
            color: Colors.blue,
            onTap: () => _scanFromCamera(context),
          ),
          const SizedBox(height: 12),

          _ScanOptionCard(
            icon: Icons.photo_library,
            title: 'Choose from Gallery',
            subtitle: 'Select existing image',
            color: Colors.green,
            onTap: () => _scanFromGallery(context),
          ),
          const SizedBox(height: 12),

          _ScanOptionCard(
            icon: Icons.picture_as_pdf,
            title: 'Upload PDF',
            subtitle: 'Select PDF document',
            color: Colors.orange,
            onTap: () => _scanFromPDF(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProfilesView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Profiles Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Create a profile first to scan reports',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanFromCamera(BuildContext context) async {
    if (_selectedProfile == null) {
      _showError(context, 'Please select a profile first');
      return;
    }

    final reportViewModel = context.read<ReportViewModel>();
    final success = await reportViewModel.scanFromCamera(_selectedProfile!.id!);

    if (success && mounted) {
      Navigator.pop(context, true);
      _showSuccess(context, 'Report scanned successfully!');
    } else if (mounted && reportViewModel.error != null) {
      _showError(context, reportViewModel.error!);
    }
  }

  Future<void> _scanFromGallery(BuildContext context) async {
    if (_selectedProfile == null) {
      _showError(context, 'Please select a profile first');
      return;
    }

    final reportViewModel = context.read<ReportViewModel>();
    final success =
        await reportViewModel.scanFromGallery(_selectedProfile!.id!);

    if (success && mounted) {
      Navigator.pop(context, true);
      _showSuccess(context, 'Report scanned successfully!');
    } else if (mounted && reportViewModel.error != null) {
      _showError(context, reportViewModel.error!);
    }
  }

  Future<void> _scanFromPDF(BuildContext context) async {
    if (_selectedProfile == null) {
      _showError(context, 'Please select a profile first');
      return;
    }

    final reportViewModel = context.read<ReportViewModel>();
    final success = await reportViewModel.scanFromPDF(_selectedProfile!.id!);

    if (success && mounted) {
      Navigator.pop(context, true);
      _showSuccess(context, 'Report scanned successfully!');
    } else if (mounted && reportViewModel.error != null) {
      _showError(context, reportViewModel.error!);
    }
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _getScanningMessage(double? progress) {
    if (progress == null) return 'Initializing...';
    if (progress < 0.3) return 'Reading image...';
    if (progress < 0.7) return 'Extracting data with AI...';
    if (progress < 0.9) return 'Saving results...';
    return 'Almost done...';
  }
}

class _ScanOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ScanOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
