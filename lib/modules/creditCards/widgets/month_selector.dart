import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';

class MonthSelector extends StatelessWidget {
  final DateTime currentDate;
  final Function(int) onMonthChanged;

  const MonthSelector({
    super.key,
    required this.currentDate,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM yyyy', 'pt_BR');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppTheme.neonGreen),
            onPressed: () => onMonthChanged(-1),
          ),
          Text(
            dateFormat.format(currentDate).toUpperCase(),
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppTheme.neonGreen),
            onPressed: () => onMonthChanged(1),
          ),
        ],
      ),
    );
  }
}