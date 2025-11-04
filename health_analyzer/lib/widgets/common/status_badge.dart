import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Status badge widget for displaying normal/abnormal/high/low indicators
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    switch (type) {
      case StatusType.normal:
        backgroundColor = AppTheme.successLight;
        textColor = AppTheme.successColor;
        icon = Icons.check_circle;
        break;
      case StatusType.high:
        backgroundColor = AppTheme.errorLight;
        textColor = AppTheme.errorColor;
        icon = Icons.arrow_upward;
        break;
      case StatusType.low:
        backgroundColor = AppTheme.warningLight;
        textColor = AppTheme.warningColor;
        icon = Icons.arrow_downward;
        break;
      case StatusType.abnormal:
        backgroundColor = AppTheme.errorLight;
        textColor = AppTheme.errorColor;
        icon = Icons.warning;
        break;
      case StatusType.info:
        backgroundColor = AppTheme.infoLight;
        textColor = AppTheme.infoColor;
        icon = Icons.info;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? AppTheme.spacing8 : AppTheme.spacing12,
        vertical: isCompact ? AppTheme.spacing4 : AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isCompact) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: AppTheme.spacing4),
          ],
          Text(
            label,
            style: (isCompact ? AppTheme.labelSmall : AppTheme.labelMedium)
                .copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusType {
  normal,
  high,
  low,
  abnormal,
  info,
}
