import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_extensions.dart';
import '../../models/blood_report.dart';
import '../../models/parameter.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/profile_avatar.dart';
import '../../services/gemini_service.dart';
import '../../services/database_helper.dart';
import '../../viewmodels/report_viewmodel.dart';
import 'parameter_trend_screen.dart';
import 'dart:io';
import 'dart:convert';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';

/// Report details screen with grouped parameters
class ReportDetailsScreen extends StatefulWidget {
  final BloodReport report;
  final String? profileName;

  const ReportDetailsScreen({
    super.key,
    required this.report,
    this.profileName,
  });

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final Map<String, bool> _expandedGroups = {};
  final GeminiService _geminiService = GeminiService();

  bool _showAiInsights = false;
  bool _loadingAiInsights = false;
  Map<String, dynamic>? _aiInsights;
  String? _aiError;

  @override
  void initState() {
    super.initState();
    // Initialize all groups as collapsed
    _getParameterGroups().forEach((group, _) {
      _expandedGroups[group] = false;
    });
    
    // Load cached AI analysis if available
    if (widget.report.aiAnalysis != null) {
      try {
        _aiInsights = jsonDecode(widget.report.aiAnalysis!);
      } catch (e) {
        debugPrint('Error parsing cached AI analysis: $e');
      }
    }
  }

  /// Load AI insights for the report
  Future<void> _loadAiInsights({bool forceRefresh = false}) async {
    // Check if we have cached insights and not forcing refresh
    if (_aiInsights != null && !forceRefresh) return;
    
    if (_loadingAiInsights) return;

    setState(() {
      _loadingAiInsights = true;
      _aiError = null;
    });

    try {
      // Prepare abnormal parameters data
      final abnormalParams = widget.report.abnormalParameters.map((p) {
        return {
          'name': p.rawParameterName ?? p.parameterName,
          'value': p.parameterValue,
          'unit': p.unit ?? '',
          'ref_min': p.referenceRangeMin,
          'ref_max': p.referenceRangeMax,
          'status': p.status,
        };
      }).toList();

      // Prepare all parameters data
      final allParams = widget.report.parameters.map((p) {
        return {
          'name': p.rawParameterName ?? p.parameterName,
          'value': p.parameterValue,
          'unit': p.unit ?? '',
        };
      }).toList();

      final insights = await _geminiService.generateHealthInsights(
        abnormalParameters: abnormalParams,
        allParameters: allParams,
      );

      // Cache the AI analysis in database
      if (widget.report.id != null) {
        final aiAnalysisJson = jsonEncode(insights);
        await DatabaseHelper.instance.updateAiAnalysis(
          widget.report.id!,
          aiAnalysisJson,
        );
      }

      setState(() {
        _aiInsights = insights;
        _loadingAiInsights = false;
      });
    } catch (e) {
      setState(() {
        _aiError = e.toString();
        _loadingAiInsights = false;
      });
    }
  }

  Map<String, List<Parameter>> _getParameterGroups() {
    final Map<String, List<Parameter>> groups = {
      'Complete Blood Count (CBC)': [],
      'Lipid Profile': [],
      'Liver Function Test': [],
      'Kidney Function Test': [],
      'Thyroid Profile': [],
      'Blood Sugar': [],
      'Others': [],
    };

    for (final param in widget.report.parameters) {
      final name = param.parameterName.toLowerCase();

      // CBC
      if (name.contains('rbc') ||
          name.contains('wbc') ||
          name.contains('hemoglobin') ||
          name.contains('hematocrit') ||
          name.contains('platelet') ||
          name.contains('mcv') ||
          name.contains('mch') ||
          name.contains('neutrophil') ||
          name.contains('lymphocyte') ||
          name.contains('monocyte') ||
          name.contains('eosinophil') ||
          name.contains('basophil')) {
        groups['Complete Blood Count (CBC)']!.add(param);
      }
      // Lipid Profile
      else if (name.contains('cholesterol') ||
          name.contains('triglyceride') ||
          name.contains('hdl') ||
          name.contains('ldl') ||
          name.contains('vldl')) {
        groups['Lipid Profile']!.add(param);
      }
      // Liver Function
      else if (name.contains('sgpt') ||
          name.contains('sgot') ||
          name.contains('alt') ||
          name.contains('ast') ||
          name.contains('bilirubin') ||
          name.contains('alp') ||
          name.contains('ggt') ||
          name.contains('protein') ||
          name.contains('albumin') ||
          name.contains('globulin')) {
        groups['Liver Function Test']!.add(param);
      }
      // Kidney Function
      else if (name.contains('creatinine') ||
          name.contains('urea') ||
          name.contains('bun') ||
          name.contains('uric') ||
          name.contains('egfr')) {
        groups['Kidney Function Test']!.add(param);
      }
      // Thyroid
      else if (name.contains('tsh') ||
          name.contains('t3') ||
          name.contains('t4') ||
          name.contains('thyroid')) {
        groups['Thyroid Profile']!.add(param);
      }
      // Blood Sugar
      else if (name.contains('glucose') ||
          name.contains('sugar') ||
          name.contains('hba1c') ||
          name.contains('fasting') ||
          name.contains('pp') ||
          name.contains('random')) {
        groups['Blood Sugar']!.add(param);
      }
      // Others
      else {
        groups['Others']!.add(param);
      }
    }

    // Remove empty groups
    groups.removeWhere((key, value) => value.isEmpty);

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _getParameterGroups();
    final abnormalCount = widget.report.abnormalParameters.length;
    final normalCount = widget.report.parameters.length - abnormalCount;

    return Scaffold(
      backgroundColor: context.surfaceColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(widget.report.testDate)),
            if (widget.report.labName != null)
              Text(
                widget.report.labName!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Summary Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: _buildSummaryCard(normalCount, abnormalCount),
            ),
          ),

          // Parameters Groups
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final groupName = groups.keys.elementAt(index);
                final parameters = groups[groupName]!;
                final isExpanded = _expandedGroups[groupName] ?? false;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing8,
                  ),
                  child: _buildParameterGroup(
                    groupName,
                    parameters,
                    isExpanded,
                  ),
                );
              },
              childCount: groups.length,
            ),
          ),

          // AI Insights Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: _buildAiInsightsSection(),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: AppTheme.spacing32),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int normalCount, int abnormalCount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          children: [
            // Profile info
            if (widget.profileName != null)
              Row(
                children: [
                  ProfileAvatar(
                    name: widget.profileName!,
                    size: 40,
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Text(
                    widget.profileName!,
                    style: AppTheme.titleMedium,
                  ),
                ],
              ),

            if (widget.profileName != null)
              const Divider(height: AppTheme.spacing24),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    'Total',
                    '${widget.report.parameters.length}',
                    Icons.analytics_outlined,
                    context.primaryColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.dividerColor,
                ),
                Expanded(
                  child: _buildStatColumn(
                    'Normal',
                    '$normalCount',
                    Icons.check_circle_outline,
                    AppTheme.successColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.dividerColor,
                ),
                Expanded(
                  child: _buildStatColumn(
                    'Abnormal',
                    '$abnormalCount',
                    Icons.warning_amber_outlined,
                    abnormalCount > 0
                        ? AppTheme.errorColor
                        : AppTheme.textTertiary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacing16),

            // Status indicator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing16,
                vertical: AppTheme.spacing12,
              ),
              decoration: BoxDecoration(
                color: abnormalCount > 0
                    ? AppTheme.errorLight
                    : AppTheme.successLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    abnormalCount > 0 ? Icons.warning : Icons.check_circle,
                    color: abnormalCount > 0
                        ? AppTheme.errorColor
                        : AppTheme.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    abnormalCount > 0
                        ? 'Some values are outside normal range'
                        : 'All values are within normal range',
                    style: AppTheme.titleSmall.copyWith(
                      color: abnormalCount > 0
                          ? AppTheme.errorColor
                          : AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacing12),

            // View AI Insights button
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _showAiInsights = !_showAiInsights;
                });
              },
              icon:
                  Icon(_showAiInsights ? Icons.expand_less : Icons.expand_more),
              label: const Text('View AI Analysis'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          value,
          style: AppTheme.titleLarge.copyWith(color: color),
        ),
        const SizedBox(height: AppTheme.spacing4),
        Text(
          label,
          style: AppTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _buildParameterGroup(
    String groupName,
    List<Parameter> parameters,
    bool isExpanded,
  ) {
    final abnormalInGroup = parameters.where((p) => !p.isNormal).length;

    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedGroups[groupName] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          '${parameters.length} parameters${abnormalInGroup > 0 ? ', $abnormalInGroup abnormal' : ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (abnormalInGroup > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacing8,
                        vertical: AppTheme.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.errorLight,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        '$abnormalInGroup',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: AppTheme.spacing12),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Column(
              children: parameters.map((param) {
                return _buildParameterCard(param);
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildParameterCard(Parameter parameter) {
    return Builder(
      builder: (context) {
        final status = parameter.status;
        final colorScheme = Theme.of(context).colorScheme;

        Color bgColor;
        Color borderColor;
        Color textColor;
        StatusType badgeType;

        if (status == 'high') {
          // Error state - red tinted surface
          bgColor = Color.alphaBlend(
            AppTheme.errorColor.withOpacity(0.12),
            colorScheme.surface,
          );
          borderColor = AppTheme.errorColor;
          textColor = colorScheme.onSurface;
          badgeType = StatusType.high;
        } else if (status == 'low') {
          // Warning state - orange/yellow tinted surface
          bgColor = Color.alphaBlend(
            AppTheme.warningColor.withOpacity(0.12),
            colorScheme.surface,
          );
          borderColor = AppTheme.warningColor;
          textColor = colorScheme.onSurface;
          badgeType = StatusType.low;
        } else {
          // Success state - green tinted surface
          bgColor = Color.alphaBlend(
            AppTheme.successColor.withOpacity(0.12),
            colorScheme.surface,
          );
          borderColor = AppTheme.successColor;
          textColor = colorScheme.onSurface;
          badgeType = StatusType.normal;
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(
            AppTheme.spacing16,
            0,
            AppTheme.spacing16,
            AppTheme.spacing12,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: borderColor.withOpacity(0.3), width: 1),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to parameter trend screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ParameterTrendScreen(
                    profileId: widget.report.profileId,
                    profileName: widget.profileName ?? 'Profile',
                    initialParameter: parameter.parameterName,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatParameterName(parameter.rawParameterName ??
                              parameter.parameterName),
                          style: AppTheme.titleSmall.copyWith(color: textColor),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Row(
                          children: [
                            Text(
                              '${parameter.parameterValue}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontSize: 20,
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (parameter.unit != null) ...[
                              const SizedBox(width: AppTheme.spacing4),
                              Text(
                                parameter.unit!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: textColor.withOpacity(0.8),
                                    ),
                              ),
                            ],
                          ],
                        ),
                        if (parameter.referenceRangeMin != null &&
                            parameter.referenceRangeMax != null) ...[
                          const SizedBox(height: AppTheme.spacing4),
                          Text(
                            'Range: ${parameter.referenceRangeMin} - ${parameter.referenceRangeMax}',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: textColor.withOpacity(0.7),
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusBadge(
                        label: status == 'high'
                            ? 'High'
                            : status == 'low'
                                ? 'Low'
                                : 'Normal',
                        type: badgeType,
                      ),
                      const SizedBox(height: AppTheme.spacing8),
                      Icon(
                        Icons.trending_up,
                        size: 20,
                        color: textColor.withOpacity(0.6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAiInsightsSection() {
    if (!_showAiInsights) {
      return const SizedBox.shrink();
    }

    // Load AI insights when section is expanded
    if (_aiInsights == null && !_loadingAiInsights && _aiError == null) {
      _loadAiInsights();
    }

    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Expanded(
                      child: Text(
                        'AI Health Analysis',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: colorScheme.primary,
                            ),
                      ),
                    ),
                    // Refresh button
                    if (_aiInsights != null)
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: () {
                          _loadAiInsights(forceRefresh: true);
                        },
                        tooltip: 'Regenerate insights',
                      ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacing16),
                const Divider(),
                const SizedBox(height: AppTheme.spacing16),

                // Loading state
                if (_loadingAiInsights)
                  Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: AppTheme.spacing12),
                        Text(
                          'Analyzing your report...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )

                // Error state
                else if (_aiError != null)
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.error,
                          size: 48,
                        ),
                        const SizedBox(height: AppTheme.spacing12),
                        Text(
                          'Failed to generate AI insights',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          _aiError!.contains('API key')
                              ? 'Please check your Gemini API key in settings'
                              : 'Please try again later',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _aiError = null;
                            });
                            _loadAiInsights();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  )

                // AI insights content
                else if (_aiInsights != null)
                  _buildAiInsightsContent()

                // Initial state
                else
                  Center(
                    child: TextButton.icon(
                      onPressed: _loadAiInsights,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate AI Analysis'),
                    ),
                  ),

                // Disclaimer (always show when insights are loaded)
                if (_aiInsights != null || _loadingAiInsights) ...[
                  const SizedBox(height: AppTheme.spacing20),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing12),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        Expanded(
                          child: Text(
                            'This is AI-generated information for educational purposes only. Always consult qualified healthcare professionals for medical advice.',
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: colorScheme.onTertiaryContainer,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAiInsightsContent() {
    final insights = _aiInsights!;

    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Assessment
            Text(
              'Overall Assessment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              insights['overall_assessment'] ?? 'No assessment available',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // Areas of Concern
            if (insights['concerns'] != null &&
                (insights['concerns'] as List).isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacing20),
              Text(
                'Areas of Concern',
                style: AppTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacing12),
              ...(insights['concerns'] as List).map((concern) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 18,
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(width: AppTheme.spacing8),
                          Expanded(
                            child: Text(
                              concern['parameter'] ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacing4),
                      Padding(
                        padding: const EdgeInsets.only(left: 26),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (concern['issue'] != null) ...[
                              Text(
                                concern['issue'],
                                style: AppTheme.bodySmall,
                              ),
                              const SizedBox(height: AppTheme.spacing4),
                            ],
                            if (concern['recommendation'] != null)
                              Text(
                                '💡 ${concern['recommendation']}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: colorScheme.primary,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],

            // Positive Notes
            if (insights['positive_notes'] != null &&
                (insights['positive_notes'] as List).isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacing20),
              Text(
                'Positive Observations',
                style: AppTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacing12),
              ...(insights['positive_notes'] as List).map((note) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Expanded(
                        child: Text(
                          note,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],

            // Next Steps
            if (insights['next_steps'] != null &&
                (insights['next_steps'] as List).isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacing20),
              Text(
                'Recommended Next Steps',
                style: AppTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacing12),
              ...(insights['next_steps'] as List).asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: AppTheme.labelSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        );
      },
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('View Report Image'),
                onTap: () {
                  debugPrint('🖼️ View Report Image tapped from bottom sheet');
                  debugPrint(
                      '  Report Image Path: ${widget.report.reportImagePath}');
                  Navigator.pop(context);
                  if (widget.report.reportImagePath != null) {
                    _showReportImage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No image attached to this report'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Report'),
                onTap: () {
                  Navigator.pop(context);
                  _shareReport();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.errorColor),
                title: const Text(
                  'Delete Report',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareReport() async {
    try {
      // Create a text summary of the report
      final StringBuffer summary = StringBuffer();
      
      summary.writeln('📊 Blood Test Report');
      summary.writeln('━━━━━━━━━━━━━━━━━━━');
      if (widget.profileName != null) {
        summary.writeln('Patient: ${widget.profileName}');
      }
      summary.writeln('Date: ${_formatDate(widget.report.testDate)}');
      if (widget.report.labName != null) {
        summary.writeln('Lab: ${widget.report.labName}');
      }
      summary.writeln('');
      
      summary.writeln('Summary:');
      final abnormalCount = widget.report.abnormalParameters.length;
      final normalCount = widget.report.parameters.length - abnormalCount;
      summary.writeln('• Total Parameters: ${widget.report.parameters.length}');
      summary.writeln('• Normal: $normalCount');
      summary.writeln('• Abnormal: $abnormalCount');
      summary.writeln('');
      
      // Add abnormal parameters if any
      if (abnormalCount > 0) {
        summary.writeln('⚠️ Abnormal Parameters:');
        summary.writeln('━━━━━━━━━━━━━━━━━━━');
        for (final param in widget.report.abnormalParameters) {
          final name = _formatParameterName(param.rawParameterName ?? param.parameterName);
          summary.writeln('$name: ${param.parameterValue}${param.unit ?? ''}');
          if (param.referenceRangeMin != null && param.referenceRangeMax != null) {
            summary.writeln('  Range: ${param.referenceRangeMin} - ${param.referenceRangeMax}');
          }
          summary.writeln('  Status: ${param.status.toUpperCase()}');
          summary.writeln('');
        }
      }
      
      // Add all parameters grouped
      final groups = _getParameterGroups();
      summary.writeln('📋 Detailed Results:');
      summary.writeln('━━━━━━━━━━━━━━━━━━━');
      
      for (final entry in groups.entries) {
        summary.writeln('\n${entry.key}:');
        for (final param in entry.value) {
          final name = _formatParameterName(param.rawParameterName ?? param.parameterName);
          final status = param.isNormal ? '✓' : '⚠️';
          summary.writeln('  $status $name: ${param.parameterValue}${param.unit ?? ''}');
        }
      }
      
      summary.writeln('\n━━━━━━━━━━━━━━━━━━━');
      summary.writeln('Generated by LabLens');
      summary.writeln('Health tracking made simple');
      
      // Share the text
      await Share.share(
        summary.toString(),
        subject: 'Blood Test Report - ${_formatDate(widget.report.testDate)}',
      );
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share report: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Report'),
          content: const Text(
            'Are you sure you want to delete this report? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            // Material 3 FilledButton for destructive action
            FilledButton(
              onPressed: () async {
                debugPrint(
                    '🗑️ Delete button pressed for report ${widget.report.id}');
                Navigator.pop(context); // Close dialog

                final viewModel = context.read<ReportViewModel>();
                debugPrint('  Calling deleteReport...');
                final success = await viewModel.deleteReport(widget.report.id!);

                if (success && mounted) {
                  debugPrint('  ✅ Report deleted successfully');
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Go back to report list
                  Navigator.pop(context);

                  // Reload reports for the profile
                  debugPrint(
                      '  🔄 Reloading reports for profile ${widget.report.profileId}');
                  await viewModel
                      .loadReportsForProfile(widget.report.profileId);
                } else if (mounted) {
                  debugPrint('  ❌ Failed to delete report: ${viewModel.error}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(viewModel.error ?? 'Failed to delete report'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Show the report image in a full-screen viewer
  void _showReportImage() {
    final imagePath = widget.report.reportImagePath!;
    final isPDF = imagePath.toLowerCase().endsWith('.pdf');

    debugPrint('🖼️ Opening report image viewer');
    debugPrint('  Path: $imagePath');
    debugPrint('  Is PDF: $isPDF');
    debugPrint('  File exists: ${File(imagePath).existsSync()}');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ReportImageViewer(
          imagePath: imagePath,
          isPDF: isPDF,
          reportDate: widget.report.testDate,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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

  String _formatParameterName(String name) {
    // Convert snake_case to Title Case
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}

/// Full-screen image/PDF viewer widget
class _ReportImageViewer extends StatelessWidget {
  final String imagePath;
  final bool isPDF;
  final DateTime reportDate;

  const _ReportImageViewer({
    required this.imagePath,
    required this.isPDF,
    required this.reportDate,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(_formatDate(reportDate)),
      ),
      body: FutureBuilder<bool>(
        future: file.exists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Image file not found',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    imagePath,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (isPDF) {
            return SfPdfViewer.file(file);
          }

          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.file(
                file,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('❌ Error loading image: $error');
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, color: Colors.white, size: 64),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
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
