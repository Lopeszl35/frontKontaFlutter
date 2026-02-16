import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart'; // Certifique-se de ter seus formatters aqui

class BalanceCardWidget extends StatelessWidget {
  final double saldoTotal;
  final double receitasMes;
  final double despesasMes;

  const BalanceCardWidget({
    super.key,
    required this.saldoTotal,
    required this.receitasMes,
    required this.despesasMes,
  });

  @override
  Widget build(BuildContext context) {
    // Cálculo do Fluxo de Caixa do Mês (Net Cash Flow)
    final double balancoMensal = receitasMes - despesasMes;
    final bool isPositivo = balancoMensal >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Gradiente Premium do seu tema
        gradient: AppTheme.premiumGradient, 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonGreen.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER: Ícone e Título ---
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                "Saldo Total",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // --- VALOR PRINCIPAL (SALDO) ---
          Text(
            Formatters.formatMoney(saldoTotal),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36, // Fonte maior para impacto
              fontWeight: FontWeight.bold,
              letterSpacing: -1.0,
            ),
          ),

          const SizedBox(height: 16),

          // --- INSIGHT: BALANÇO DO MÊS (Substitui os botões) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2), // Fundo escuro sutil
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPositivo 
                    ? AppTheme.neonGreen.withValues(alpha: 0.3) 
                    : AppTheme.neonRed.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Ocupa apenas o espaço necessário
              children: [
                Icon(
                  isPositivo ? Icons.trending_up : Icons.trending_down,
                  color: isPositivo ? AppTheme.neonGreen : AppTheme.neonRed,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isPositivo ? "Superávit este mês" : "Déficit este mês",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  // Mostra o valor absoluto (sem sinal de menos duplicado)
                  Formatters.formatMoney(balancoMensal.abs()), 
                  style: TextStyle(
                    color: isPositivo ? AppTheme.neonGreen : AppTheme.neonRed,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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