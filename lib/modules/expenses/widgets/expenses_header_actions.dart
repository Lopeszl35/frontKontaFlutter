import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';

class ExpensesHeaderActions extends StatelessWidget {
  final VoidCallback onHistoryTap;
  final VoidCallback onNewCategoryTap;

  const ExpensesHeaderActions({
    super.key,
    required this.onHistoryTap,
    required this.onNewCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Categorias", 
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textWhite)
        ),
        Row(
          children: [
            IconButton(
              onPressed: onHistoryTap,
              icon: const Icon(Icons.history_outlined, color: AppTheme.textSilver),
              tooltip: "Histórico de Categorias",
            ),
            const SizedBox(width: 8),
            Material(
              color: AppTheme.primaryModern,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onNewCategoryTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryModern.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 18, color: Colors.white),
                      SizedBox(width: 6),
                      Text("Nova", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}