import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/report_viewmodel.dart';
import '../../models/profile.dart';
import '../../widgets/common/profile_avatar.dart';
import '../../widgets/common/empty_state.dart';
import '../widgets/profile_switcher_sheet.dart';
import 'report_scan_screen.dart';
import 'report_details_screen.dart';

/// Home tab - main view with profile content
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load reports for current profile
      final profileVM = context.read<ProfileViewModel>();
      final reportVM = context.read<ReportViewModel>();

      if (profileVM.currentProfile != null) {
        reportVM.loadReportsForProfile(profileVM.currentProfile!.id!);
      }
    });
  }

  void _showProfileSwitcher() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProfileSwitcherSheet(),
    );
  }

  void _navigateToScan() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReportScanScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),

            // Content
            Expanded(
              child: Consumer2<ProfileViewModel, ReportViewModel>(
                builder: (context, profileVM, reportVM, child) {
                  final profile = profileVM.currentProfile;

                  if (profile == null) {
                    return EmptyState(
                      icon: Icons.person_add,
                      title: 'No Profile Selected',
                      message: 'Create or select a profile to get started',
                      actionLabel: 'Add Profile',
                      onAction: _showProfileSwitcher,
                    );
                  }

                  return _buildProfileContent(profile, reportVM);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToScan,
        icon: const Icon(Icons.add),
        label: const Text('Scan Report'),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      color: AppTheme.surfaceColor,
      child: Row(
        children: [
          // App logo/name
          Text(
            'LabLens',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          // Profile switcher
          Consumer<ProfileViewModel>(
            builder: (context, profileVM, child) {
              final profile = profileVM.currentProfile;

              if (profile == null) {
                return IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: _showProfileSwitcher,
                );
              }

              return GestureDetector(
                onTap: _showProfileSwitcher,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProfileAvatar(
                      name: profile.name,
                      size: 40,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      profile.name.split(' ')[0],
                      style: AppTheme.labelSmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(Profile profile, ReportViewModel reportVM) {
    return CustomScrollView(
      slivers: [
        // Profile Summary Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: _buildProfileSummaryCard(profile, reportVM),
          ),
        ),

        // Recent Reports
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: Text(
              'Recent Reports',
              style: AppTheme.headingSmall,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppTheme.spacing12),
        ),

        // Reports List or Empty State
        if (reportVM.reports.isEmpty)
          SliverFillRemaining(
            child: EmptyState(
              icon: Icons.description_outlined,
              title: 'No reports yet',
              message: 'Tap the + button to scan your first report',
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final report = reportVM.reports[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing8,
                  ),
                  child: _buildReportCard(report),
                );
              },
              childCount: reportVM.reports.length,
            ),
          ),

        // Bottom padding for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildProfileSummaryCard(Profile profile, ReportViewModel reportVM) {
    final age = profile.dateOfBirth != null && profile.dateOfBirth!.isNotEmpty
        ? _calculateAge(DateTime.parse(profile.dateOfBirth!))
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatar(
                  name: profile.name,
                  size: 60,
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: AppTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Text(
                        [
                          if (age != null) '$age years',
                          if (profile.relationship != null)
                            profile.relationship!,
                        ].where((s) => s.isNotEmpty).join(' • '),
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    // TODO: Navigate to edit profile
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            const Divider(),
            const SizedBox(height: AppTheme.spacing12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Reports',
                  '${reportVM.reports.length}',
                  Icons.description,
                ),
                _buildStatItem(
                  'Last Test',
                  reportVM.reports.isNotEmpty
                      ? _formatDate(reportVM.reports.first.testDate)
                      : 'N/A',
                  Icons.calendar_today,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          value,
          style: AppTheme.titleMedium.copyWith(
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildReportCard(dynamic report) {
    final profile = context.read<ProfileViewModel>().currentProfile;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReportDetailsScreen(
                report: report,
                profileName: profile?.name,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatFullDate(report.testDate),
                          style: AppTheme.titleMedium,
                        ),
                        if (report.labName?.isNotEmpty ?? false) ...[
                          const SizedBox(height: AppTheme.spacing4),
                          Text(
                            report.labName!,
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                '${report.parameters.length} parameters',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    if (diff < 30) return '${(diff / 7).floor()} weeks ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatFullDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
