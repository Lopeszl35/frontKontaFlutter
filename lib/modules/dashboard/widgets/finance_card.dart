import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';

class FinanceCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isPrincipal;
  final List<Widget>? actions;

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
      padding: const EdgeInsets.all(20), 
      decoration: BoxDecoration(
        gradient: isPrincipal ? AppTheme.premiumGradient : null,
        color: isPrincipal ? null : AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: isPrincipal 
            ? Border.all(color: Colors.white.withValues(alpha: 0.1)) 
            : Border.all(color: AppTheme.borderDark),
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- LINHA DO TÍTULO ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( // Expanded impede que o texto empurre para fora da tela
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10), // Reduzi um pouco o padding do ícone
                      decoration: BoxDecoration(
                        color: isPrincipal 
                            ? Colors.white.withValues(alpha: 0.15) 
                            : color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon, 
                        color: isPrincipal ? Colors.white : color, 
                        size: 20 // Ícone levemente menor para harmonia
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible( // Flexible permite que o texto quebre
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isPrincipal ? Colors.white70 : AppTheme.textSilver,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis, // Previne quebra de layout
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Se tiver algo extra no topo (como um ícone decorativo), coloque aqui.
              if (isPrincipal)
                 Icon(Icons.auto_graph_rounded, color: Colors.white.withValues(alpha: 0.3), size: 20),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // --- VALOR ---
          Text(
            value,
            style: TextStyle(
              // Fonte responsiva: se for principal é maior, senão menor
              fontSize: isPrincipal ? 32 : 20, 
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite, 
              letterSpacing: -0.5,
            ),
          ),
          
          // --- BARRA DECORATIVA (Apenas para secundários) ---
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
          ],

          // --- AÇÕES (BOTÕES) ---
          if (isPrincipal && actions != null) ...[
            const SizedBox(height: 24), // Espaço entre o valor e os botões
            Row(
              children: actions!, // Os botões ficam alinhados aqui
            ),
          ]
        ],
      ),
    );
  }
}