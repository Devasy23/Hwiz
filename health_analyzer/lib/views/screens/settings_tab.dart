import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

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
                  // TODO: Navigate to profile management
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
                  // TODO: Navigate to API key setup
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
                  // TODO: Export data
                },
              ),
              _buildTile(
                Icons.download,
                'Import Data',
                'Import from backup file',
                onTap: () {
                  // TODO: Import data
                },
              ),
              _buildTile(
                Icons.delete_forever,
                'Clear All Data',
                'Delete all profiles and reports',
                onTap: () {
                  // TODO: Show confirmation dialog
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
                  // TODO: Theme selector
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
                  // TODO: Show tutorial
                },
              ),
              _buildTile(
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                'All data stored locally',
                onTap: () {
                  // TODO: Show privacy policy
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
}
