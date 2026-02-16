import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';

class DataRowWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const DataRowWidget({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textSilver)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.textWhite,
            ),
          ),
        ],
      ),
    );
  }
}