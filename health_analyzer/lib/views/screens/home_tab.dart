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
import 'compare_reports_screen.dart';

/// Home tab - main view with profile content
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  Profile? _lastLoadedProfile;
  late AnimationController _animationController;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Initial load will happen in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadReportsIfNeeded();
  }

  void _loadReportsIfNeeded() {
    final profileVM = context.read<ProfileViewModel>();
    final reportVM = context.read<ReportViewModel>();
    final currentProfile = profileVM.currentProfile;

    // Load reports if:
    // 1. There's a current profile
    // 2. It's different from the last loaded profile (or first time)
    if (currentProfile != null && _lastLoadedProfile?.id != currentProfile.id) {
      debugPrint(
          '📊 Loading reports for profile: ${currentProfile.name} (ID: ${currentProfile.id})');
      _lastLoadedProfile = currentProfile;
      reportVM.loadReportsForProfile(currentProfile.id!);

      // Restart animations when content changes
      _animationController.forward(from: 0.0);
    }
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

  void _navigateToCompare(Profile profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CompareReportsScreen(
          profileId: profile.id!,
          profileName: profile.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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

                  // Trigger reload when profile changes
                  // This will be handled by didChangeDependencies on the next frame
                  if (profile != null && _lastLoadedProfile?.id != profile.id) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _loadReportsIfNeeded();
                      }
                    });
                  }

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
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _animationController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          onPressed: _navigateToScan,
          icon: const Icon(Icons.document_scanner_outlined, size: 24),
          label: const Text(
            'Scan Report',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          elevation: 3,
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // App logo/name with brand styling
          Text(
            'LabLens',
            style: AppTheme.brandTitle.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),

          // Action buttons
          Consumer2<ProfileViewModel, ReportViewModel>(
            builder: (context, profileVM, reportVM, child) {
              final profile = profileVM.currentProfile;
              final hasReports = reportVM.reports.isNotEmpty;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Compare button with improved visibility
                  if (hasReports && reportVM.reports.length >= 2)
                    FilledButton.tonalIcon(
                      onPressed: () => _navigateToCompare(profile!),
                      icon: const Icon(Icons.compare_arrows, size: 20),
                      label: const Text('Compare'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing12,
                          vertical: AppTheme.spacing8,
                        ),
                      ),
                    ),

                  const SizedBox(width: AppTheme.spacing12),
                ],
              );
            },
          ),

          // Profile switcher with improved touch target
          Consumer<ProfileViewModel>(
            builder: (context, profileVM, child) {
              final profile = profileVM.currentProfile;

              if (profile == null) {
                return IconButton(
                  icon: const Icon(Icons.person_add, size: 28),
                  onPressed: _showProfileSwitcher,
                  tooltip: 'Add Profile',
                );
              }

              return InkWell(
                onTap: _showProfileSwitcher,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProfileAvatar(
                        name: profile.name,
                        size: 40,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile.name.split(' ')[0],
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            'Tap to switch',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
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
        // Profile Summary Card with fade-in animation
        SliverToBoxAdapter(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final fadeAnimation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                ),
              );

              return FadeTransition(
                opacity: fadeAnimation,
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacing16,
                AppTheme.spacing12,
                AppTheme.spacing16,
                0,
              ),
              child: _buildProfileSummaryCard(profile, reportVM),
            ),
          ),
        ),

        // Recent Reports Section Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacing16,
              AppTheme.spacing20,
              AppTheme.spacing16,
              AppTheme.spacing12,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Text(
                  'Recent Reports',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
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

                // Staggered animation for each card
                final delay = index * 0.1; // 100ms delay between cards
                final animation = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(
                      delay.clamp(0.0, 0.8),
                      (delay + 0.3).clamp(0.2, 1.0),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                );

                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - animation.value)),
                      child: Opacity(
                        opacity: animation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing16,
                      vertical: AppTheme.spacing4,
                    ),
                    child: _buildReportCard(report),
                  ),
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

    // Calculate abnormal count
    int abnormalCount = 0;
    if (reportVM.reports.isNotEmpty) {
      for (final param in reportVM.reports.first.parameters) {
        if (!param.isNormal) abnormalCount++;
      }
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          children: [
            Row(
              children: [
                // Larger, more prominent avatar with Hero animation
                Hero(
                  tag: 'profile_avatar_${profile.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ProfileAvatar(
                      name: profile.name,
                      size: 72,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Row(
                        children: [
                          if (profile.gender != null) ...[
                            Icon(
                              profile.gender?.toLowerCase() == 'male'
                                  ? Icons.male
                                  : Icons.female,
                              size: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(width: AppTheme.spacing4),
                          ],
                          Text(
                            [
                              if (age != null) '$age years',
                            ].where((s) => s.isNotEmpty).join(' • '),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            // Stats grid with improved design
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Reports',
                    '${reportVM.reports.length}',
                    Icons.description_rounded,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Last Test',
                    reportVM.reports.isNotEmpty
                        ? _formatDate(reportVM.reports.first.testDate)
                        : 'N/A',
                    Icons.calendar_today_rounded,
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
                if (reportVM.reports.isNotEmpty && abnormalCount > 0) ...[
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Abnormal',
                      '$abnormalCount',
                      Icons.warning_amber_rounded,
                      Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    // Check if value is a number for animation
    final numValue = int.tryParse(value);
    final shouldAnimate = numValue != null;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppTheme.spacing8),
          // Animated counting for numeric values
          if (shouldAnimate)
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: numValue),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, animValue, child) {
                return Text(
                  '$animValue',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                );
              },
            )
          else
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(dynamic report) {
    final profile = context.read<ProfileViewModel>().currentProfile;

    // Calculate report stats
    int abnormalCount = 0;
    for (final param in report.parameters) {
      if (!param.isNormal) abnormalCount++;
    }

    final hasAbnormal = abnormalCount > 0;
    final statusColor = hasAbnormal
        ? Theme.of(context).colorScheme.error
        : AppTheme.healthNormal;

    // Generate unique hero tag for this report
    final heroTag = 'report_card_${report.id}_${report.testDate}';

    return Hero(
      tag: heroTag,
      child: Material(
        type: MaterialType.transparency,
        child: Card(
          elevation: hasAbnormal ? 1 : 0,
          color: hasAbnormal
              ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.2)
              : null,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReportDetailsScreen(
                    report: report,
                    profileName: profile?.name,
                    heroTag: heroTag,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                children: [
                  // Status indicator bar
                  Container(
                    width: 4,
                    height: 56,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  // Report content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatFullDate(report.testDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing8,
                                vertical: AppTheme.spacing4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    hasAbnormal
                                        ? Icons.warning_amber_rounded
                                        : Icons.check_circle_rounded,
                                    size: 14,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: AppTheme.spacing4),
                                  Text(
                                    hasAbnormal
                                        ? '$abnormalCount abnormal'
                                        : 'Normal',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (report.labName?.isNotEmpty ?? false) ...[
                          const SizedBox(height: AppTheme.spacing4),
                          Text(
                            report.labName!.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  letterSpacing: 0.5,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                        const SizedBox(height: AppTheme.spacing8),
                        Row(
                          children: [
                            Icon(
                              Icons.science_outlined,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: AppTheme.spacing4),
                            Text(
                              '${report.parameters.length} parameters',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Chevron icon
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
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
