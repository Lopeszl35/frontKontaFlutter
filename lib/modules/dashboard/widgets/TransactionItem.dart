import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String category;
  final double value;
  final String type; // 'receita' ou 'despesa'
  

  const TransactionItem({
    super.key,
    required this.title,
    required this.category,
    required this.value,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = type == 'despesa';
    final displayValue = isNegative ? -value.abs() : value.abs();
    final color = isNegative ? AppTheme.neonRed : AppTheme.neonGreen;
    final typeIcon = isNegative ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 75, // Altura fixa para consistência
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: AppTheme.surface.withValues(alpha: 0.6), // Fundo ligeiramente mais transparente
          child: Row(
            children: [
              // --- 1. BARRA LATERAL FINA ---
              Container(
                width: 3,
                color: color,
              ),
              
              // --- 2. CONTEÚDO ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // --- ÍCONE INDICADOR ---
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1), // Fundo suave da cor
                          shape: BoxShape.circle,
                        ),
                        child: Icon(typeIcon, color: color, size: 20),
                      ),
                      const SizedBox(width: 16),
                      
                      // --- TEXTOS ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppTheme.textWhite,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category,
                              style: TextStyle(
                                color: AppTheme.textSilver.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // --- VALOR ---
                      Text(
                        Formatters.formatMoney(displayValue),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color, 
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}