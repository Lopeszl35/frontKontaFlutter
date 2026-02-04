import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';

class FinanceCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isPrincipal;
  final List<Widget>? actions; // Lista de botões opcionais

  const FinanceCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isPrincipal = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isPrincipal ? double.infinity : null,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isPrincipal ? AppTheme.premiumGradient : null,
        color: isPrincipal ? null : AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: isPrincipal 
            ? Border.all(color: Colors.white.withValues(alpha: 0.1)) 
            : Border.all(color: AppTheme.borderDark),
        boxShadow: [
          BoxShadow(
            color: isPrincipal 
                ? AppTheme.primaryModern.withValues(alpha: 0.4) 
                : Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Lado Esquerdo: Ícone + Título
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPrincipal 
                          ? Colors.white.withValues(alpha: 0.15) 
                          : color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon, 
                      color: isPrincipal ? Colors.white : color, 
                      size: 22
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: isPrincipal ? Colors.white70 : AppTheme.textSilver,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              // Lado Direito: Ações Rápidas (Se houver)
              if (actions != null)
                Row(children: actions!),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Text(
            value,
            style: TextStyle(
              fontSize: isPrincipal ? 32 : 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite, 
              letterSpacing: -0.5,
            ),
          ),
          
          if (!isPrincipal) ...[
            const SizedBox(height: 12),
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)
                ]
              ),
            )
          ]
        ],
      ),
    );
  }
}