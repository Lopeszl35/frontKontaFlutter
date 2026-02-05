import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final double spent;
  final double limit;
  final IconData icon;
  final VoidCallback onAdd;

  const CategoryCard({
    super.key,
    required this.name,
    required this.spent,
    required this.limit,
    required this.icon,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    // Lógica de Cor: >100% (Vermelho), >80% (Laranja), Resto (Verde Neon)
    final percentage = (spent / limit).clamp(0.0, 2.0); 
    final percentDisplay = (spent / limit * 100).toInt();
    
    Color statusColor;
    if (percentage >= 1.0) {
      statusColor = AppTheme.neonRed; // Vermelho Neon para erro
    } else if (percentage >= 0.8) {
      statusColor = AppTheme.neonOrange; // Laranja Neon para alerta
    } else {
      statusColor = AppTheme.neonGreen; // Verde Neon para sucesso
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface, // Fundo Carbono (Escuro)
        borderRadius: BorderRadius.circular(16),
        // Borda sutil ou colorida se estiver em alerta
        border: Border.all(
          color: percentage >= 0.8 ? statusColor.withValues(alpha: 0.5) : AppTheme.borderDark, 
          width: percentage >= 0.8 ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3), // Sombra mais forte para fundo escuro
            blurRadius: 8, 
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CABEÇALHO (Ícone + Nome + %)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15), // Fundo translúcido do ícone
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 14,
                    color: AppTheme.textWhite // Nome em Branco
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$percentDisplay%',
                  style: TextStyle(
                    color: statusColor, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 12
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 2. VALORES (Gasto vs Limite)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                Formatters.formatMoney(spent),
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 15, // Um pouco maior para leitura
                  color: AppTheme.textWhite // Valor gasto em Branco
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'de ${Formatters.formatMoney(limit)}',
                style: TextStyle(
                  color: AppTheme.textSilver.withValues(alpha: 0.7), // Limite em cinza suave
                  fontSize: 12
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),

          // 3. BARRA DE PROGRESSO
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage > 1 ? 1 : percentage, 
              backgroundColor: AppTheme.inputDark, // Fundo da barra escuro
              valueColor: AlwaysStoppedAnimation(statusColor),
              minHeight: 6,
            ),
          ),
          
          const Spacer(), 
          
         const Divider(height: 24, color: AppTheme.borderDark), // Divisor sutil

          // 4. BOTÃO DE AÇÃO
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ 
                   Icon(Icons.add, size: 16, color: AppTheme.neonGreen),
                   SizedBox(width: 6),
                  Text(
                    "Adicionar gasto",
                    style: TextStyle(
                      color: AppTheme.neonGreen, 
                      fontWeight: FontWeight.w600, 
                      fontSize: 12,
                      letterSpacing: 0.5
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}