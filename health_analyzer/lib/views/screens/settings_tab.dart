import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'settings_screen.dart';
import 'profile_list_screen.dart';

/// Settings tab - app configuration and preferences
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
                Icons.upload_file,
                'Export Data',
                'Export all reports as JSON',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export feature coming soon!'),
                    ),
                  );
                },
              ),
              _buildTile(
                Icons.download,
                'Import Data',
                'Import from backup file',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Import feature coming soon!'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacing16,
            AppTheme.spacing24,
            AppTheme.spacing16,
            AppTheme.spacing8,
          ),
          child: Text(
            title,
            style: AppTheme.labelLarge.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Container(
          color: AppTheme.surfaceColor,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    String? subtitle, {
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.errorColor : AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(
          color: isDestructive ? AppTheme.errorColor : AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTheme.bodySmall,
            )
          : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
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
}
