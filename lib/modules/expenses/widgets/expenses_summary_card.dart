import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart';
import 'package:konta_app/modules/expenses/controllers/variable_expenses_controller.dart';

class ExpensesSummaryCard extends StatelessWidget {
  const ExpensesSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Uso correto do DateFormat (pt_BR deve estar inicializado no main ou na page)
    final mesFormatado = DateFormat('MMMM yyyy', 'pt_BR').format(DateTime.now()).toUpperCase();

    return Consumer<VariableExpensesController>(
      builder: (context, controller, _) {
        final progressoTotal = controller.limiteMensal > 0 
            ? (controller.gastoTotalMes / controller.limiteMensal) 
            : 0.0;
        final saldoRestante = controller.limiteMensal - controller.gastoTotalMes;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.premiumGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(mesFormatado, style: const TextStyle(color: AppTheme.textSilver, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "${(progressoTotal * 100).toInt()}% Usado", 
                      style: const TextStyle(color: AppTheme.neonBlue, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              
              // Valores Principais
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("GASTO ATUAL", style: TextStyle(color: AppTheme.textSilver, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        // HERO AQUI: Se clicar para ver detalhes, este valor voa
                        Hero(
                          tag: 'expenses_total_balance',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              Formatters.formatMoney(controller.gastoTotalMes), 
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 40, width: 1, color: Colors.white10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("META MENSAL", style: TextStyle(color: AppTheme.textSilver, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatMoney(controller.limiteMensal), 
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Barra de Progresso
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressoTotal.clamp(0.0, 1.0),
                  backgroundColor: Colors.black38,
                  valueColor: AlwaysStoppedAnimation(progressoTotal > 1 ? AppTheme.neonRed : AppTheme.neonGreen),
                  minHeight: 8,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Rodapé com Saldo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Disponível:", style: TextStyle(color: AppTheme.textSilver, fontSize: 13)),
                    Text(
                      Formatters.formatMoney(saldoRestante),
                      style: TextStyle(
                        color: saldoRestante < 0 ? AppTheme.neonRed : AppTheme.neonGreen, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        shadows: [Shadow(color: (saldoRestante < 0 ? AppTheme.neonRed : AppTheme.neonGreen).withValues(alpha: 0.5), blurRadius: 10)]
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}