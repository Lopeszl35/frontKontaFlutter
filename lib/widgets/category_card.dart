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
    // Lógica de Cor: >100% (Vermelho), >80% (Laranja), Resto (Verde)
    final percentage = (spent / limit).clamp(0.0, 2.0); // Trava em 200% pra não quebrar layout
    final percentDisplay = (spent / limit * 100).toInt();
    
    Color statusColor;
    if (percentage >= 1.0) {
      statusColor = AppTheme.error;
    } else if (percentage >= 0.8) {
      statusColor = AppTheme.warning;
    } else {
      statusColor = AppTheme.success;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: percentage >= 0.8 ? statusColor: const Color(0xFFE2E8F0), width: percentage>= 0.8 ? 2.0 : 1.0,),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10, offset: const Offset(0, 4),
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
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
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
            children: [
              Text(
                Formatters.formatMoney(spent),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                ' de ${Formatters.formatMoney(limit)}',
                style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
              ),
            ],
          ),
          
          const SizedBox(height: 8),

          // 3. BARRA DE PROGRESSO
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage > 1 ? 1 : percentage, // Barra cheia se estourou
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(statusColor),
              minHeight: 6,
            ),
          ),
          
          const Spacer(), // Empurra o botão para baixo
          const Divider(height: 24),

          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ 
                  Icon(Icons.add, size: 16, color: AppTheme.accent),
                  SizedBox(width: 4),
                  Text(
                    "Adicionar gasto",
                    style: TextStyle(
                      color: AppTheme.accent, 
                      fontWeight: FontWeight.w600, 
                      fontSize: 12
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