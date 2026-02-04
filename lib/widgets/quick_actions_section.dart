import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/widgets/quick_action_button.dart';
import 'package:konta_app/modules/expenses/pages/variable_expenses_page.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface, // Fundo Escuro
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderDark), // Borda escura sutil
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ações Rápidas",
            style: TextStyle(
              color: AppTheme.textWhite, // Texto Branco
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // GRID 2x2
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  title: "Nova Receita",
                  subtitle: "Entrada",
                  icon: Icons.arrow_upward_rounded,
                  iconColor: AppTheme.neonGreen, // Neon
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: QuickActionButton(
                  title: "Nova Despesa",
                  subtitle: "Saída",
                  icon: Icons.arrow_downward_rounded,
                  iconColor: AppTheme.neonRed, // Neon
                  onTap: () {
                     Navigator.of(context).push(
                       MaterialPageRoute(builder: (_) => const VariableExpensesPage()),
                     );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  title: "Investir",
                  subtitle: "Aplicar",
                  icon: Icons.show_chart_rounded,
                  iconColor: AppTheme.neonBlue, // Neon
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: QuickActionButton(
                  title: "Metas",
                  subtitle: "Objetivos",
                  icon: Icons.flag_rounded,
                  iconColor: AppTheme.neonOrange, // Neon
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}