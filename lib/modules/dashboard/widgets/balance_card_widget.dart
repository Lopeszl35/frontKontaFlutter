import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart'; // Certifique-se de ter seus formatters aqui

class BalanceCardWidget extends StatelessWidget {
  final double saldoTotal;
  final double receitasMes;
  final double despesasMes;
  final bool showValues; // Novo parâmetro

  const BalanceCardWidget({
    super.key,
    required this.saldoTotal,
    required this.receitasMes,
    required this.despesasMes,
    required this.showValues,
  });

  @override
  Widget build(BuildContext context) {
    final double balancoMensal = receitasMes - despesasMes;
    final bool isPositivo = balancoMensal >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.premiumGradient, 
        borderRadius: BorderRadius.circular(28), // Mais arredondado (estilo iOS 17)
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mais sutil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: Colors.white.withValues(alpha: 0.7), size: 20),
                  const SizedBox(width: 8),
                  Text("Saldo Total", style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
                ],
              ),
              if (!showValues)
                const Icon(Icons.lock_outline, color: Colors.white30, size: 16),
            ],
          ),

          const SizedBox(height: 16),

          // VALOR COM PRIVACIDADE
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: showValues
                ? Text(
                    Formatters.formatMoney(saldoTotal),
                    key: const ValueKey(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34, // Tipografia grande e limpa
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.0,
                    ),
                  )
                : Container(
                    key: const ValueKey(2),
                    height: 38,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
          ),

          const SizedBox(height: 20),

          // Balanço (Pílula)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20), // Pill shape
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositivo ? Icons.trending_up : Icons.trending_down,
                  color: isPositivo ? AppTheme.neonGreen : AppTheme.neonRed,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isPositivo ? "Superávit" : "Déficit",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                ),
                const SizedBox(width: 6),
                Text(
                  showValues ? Formatters.formatMoney(balancoMensal.abs()) : "••••",
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