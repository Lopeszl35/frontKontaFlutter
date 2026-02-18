import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart';

class FinanceSummaryCard extends StatelessWidget {
  final String title;
  final double value; // Mudou de String para double
  final IconData icon;
  final Color color;
  final bool showValues; // Novo parâmetro obrigatório

  const FinanceSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.showValues, // Obrigatório
  });

  @override
  Widget build(BuildContext context) {
    // Usamos um container com gradiente sutil em vez de borda sólida
    return Container(
      height: 110, // Altura fixa para alinhamento
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        // Gradiente diagonal sutil usando a cor do card
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            AppTheme.surface,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ícone grande e translúcido no fundo para estilo
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(
              icon,
              size: 80,
              color: color.withValues(alpha: 0.05),
            ),
          ),
          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cabeçalho com ícone pequeno e título
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textSilver,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                // Valor com Animação de Privacidade
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: showValues
                        ? Text(
                            Formatters.formatMoney(value), // Formata aqui dentro
                            key: ValueKey('value_${value}'),
                            style: TextStyle(
                              color: color, 
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          )
                        : Container(
                            key: const ValueKey('hidden'),
                            height: 24,
                            width: 80,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}