import 'package:flutter/material.dart';
import '../services/database_helper.dart';

/// Utility to reset the database when schema changes
class DatabaseReset {
  /// Reset the database by deleting it
  /// WARNING: This will delete all data!
  static Future<void> resetDatabase(BuildContext context) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reset Database'),
          content: const Text(
            'This will delete all profiles, reports, and parameters. '
            'This action cannot be undone.\n\n'
            'Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Reset'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Delete the database
      await DatabaseHelper.instance.deleteDatabase();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Database reset successfully. Please restart the app.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting database: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show a debug button in settings to reset database
  static Widget buildResetButton(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.red),
        title: const Text(
          'Reset Database',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'Delete all data and recreate database (development only)',
        ),
        trailing: ElevatedButton(
          onPressed: () => resetDatabase(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Reset'),
        ),
      ),
    );
  }
}
