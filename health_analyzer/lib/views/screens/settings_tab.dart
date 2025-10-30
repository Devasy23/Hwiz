import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_extensions.dart';
import 'settings_screen.dart';
import 'profile_list_screen.dart';
import 'data_management_screen.dart';

/// Settings tab - app configuration and preferences
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            'Family Members',
            [
              _buildTile(
                Icons.people,
                'Manage Profiles',
                'Add, edit, or remove family members',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileListScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            'API Configuration',
            [
              _buildTile(
                Icons.key,
                'Gemini API Key',
                'Configure your AI API key',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            'Data Management',
            [
              _buildTile(
                Icons.import_export,
                'Export & Import Data',
                'Export reports to CSV/JSON or import from backup',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DataManagementScreen(),
                    ),
                  );
                },
              ),
              _buildTile(
                Icons.delete_forever,
                'Clear All Data',
                'Delete all profiles and reports',
                onTap: () {
                  _showClearDataDialog(context);
                },
                isDestructive: true,
              ),
            ],
          ),
          _buildSection(
            'App Preferences',
            [
              _buildTile(
                Icons.brightness_6,
                'Theme',
                'System default',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Theme selector coming soon!'),
                    ),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            'About & Help',
            [
              _buildTile(
                Icons.info_outline,
                'App Version',
                '1.0.0',
              ),
              _buildTile(
                Icons.code,
                'GitHub Repository',
                'View source code & contribute',
                onTap: () {
                  _openGitHub(context);
                },
              ),
              _buildTile(
                Icons.person_outline,
                'Developer',
                'Created by @Devasy23',
                onTap: () {
                  _showDeveloperInfo(context);
                },
              ),
              _buildTile(
                Icons.help_outline,
                'How to Use LabLens',
                'Tutorial and guide',
                onTap: () {
                  _showTutorialDialog(context);
                },
              ),
              _buildTile(
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                'All data stored locally',
                onTap: () {
                  _showPrivacyDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with accent bar
          Padding(
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
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  title.toUpperCase(),
                  style: AppTheme.labelLarge.copyWith(
                    color: context.primaryColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Cards container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing12),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    String? subtitle, {
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Builder(
      builder: (context) {
        final tileColor = isDestructive
            ? context.errorColor.withAlpha(20)
            : Colors.transparent;

        final iconColor =
            isDestructive ? context.errorColor : context.primaryColor;

        final textColor =
            isDestructive ? context.errorColor : context.onSurfaceColor;

        return Material(
          color: tileColor,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing16,
                vertical: AppTheme.spacing16,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing8),
                    decoration: BoxDecoration(
                      color: iconColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: isDestructive ? 26 : 24,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: AppTheme.bodySmall.copyWith(
                              color: context.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onTap != null && !isDestructive)
                    Icon(
                      Icons.chevron_right,
                      color: context.onSurfaceVariant,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all profiles and blood reports. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clear data feature coming soon!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use LabLens'),
        content: const SingleChildScrollView(
          child: Text(
            '📱 Getting Started\n\n'
            '1. Create Profile\n'
            '   Add family member profiles to organize reports\n\n'
            '2. Setup API Key\n'
            '   Configure your Gemini API key in settings\n\n'
            '3. Scan Report\n'
            '   Use camera, gallery, or PDF to add blood reports\n\n'
            '4. View Analysis\n'
            '   Get AI-powered health insights and trends\n\n'
            '5. Track Progress\n'
            '   Monitor parameter changes over time\n\n'
            '💡 Tips\n'
            '• Ensure good lighting when scanning\n'
            '• Keep reports flat and in focus\n'
            '• All data is stored locally on your device\n'
            '• Regular updates help track health trends',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'LabLens Privacy Policy\n\n'
            '1. Data Storage\n'
            'All your health data is stored locally on your device. '
            'We never upload your blood reports or health information to any server.\n\n'
            '2. API Key\n'
            'Your Gemini API key is stored securely using platform-specific encryption. '
            'It is only used to analyze blood reports via Google\'s Gemini AI.\n\n'
            '3. Third-Party Services\n'
            'We use Google Gemini AI API for OCR and health analysis. '
            'Images are sent to Gemini only during report scanning.\n\n'
            '4. Data Ownership\n'
            'You own all your data. You can export or delete it at any time.\n\n'
            '5. No Analytics\n'
            'We do not collect usage analytics or personal information.\n\n'
            '6. Security\n'
            'We use industry-standard encryption for sensitive data storage.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openGitHub(BuildContext context) async {
    const url = 'https://github.com/Devasy23/Hwiz';
    final uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback - copy to clipboard
        await Clipboard.setData(const ClipboardData(text: url));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GitHub URL copied to clipboard!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Copy to clipboard as fallback
      await Clipboard.setData(const ClipboardData(text: url));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GitHub URL copied to clipboard!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showDeveloperInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.red),
            const SizedBox(width: 8),
            const Text('About the Developer'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LabLens',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Created with ❤️ by',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'D',
                        style: TextStyle(
                          color: context.onPrimaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '@Devasy23',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Full Stack Developer',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.onSurfaceColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '🚀 Open Source Contribution',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This app is open source! Feel free to contribute, report issues, or suggest features on GitHub.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openGitHub(context);
                    },
                    icon: const Icon(Icons.code, size: 18),
                    label: const Text('View on GitHub'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
