import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Profile avatar widget with initials and colored background
class ProfileAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? backgroundColor;
  final bool showBorder;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.backgroundColor,
    this.showBorder = false,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }

  Color _getColorFromName(String name) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Green
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEF4444), // Red
    ];

    final hash = name.codeUnits.fold(0, (prev, curr) => prev + curr);
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ?? _getColorFromName(name);
    final initials = _getInitials(name);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: Colors.white,
                width: 2,
              )
            : null,
        boxShadow: showBorder ? AppTheme.shadowSmall : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
