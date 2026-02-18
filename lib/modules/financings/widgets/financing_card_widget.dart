import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/data/models/financing_model.dart';

class FinancingCardWidget extends StatelessWidget {
  final Financing financing;
  final bool isSelected;
  final VoidCallback onTap;

  const FinancingCardWidget({
    super.key,
    required this.financing,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    // Lógica para definir ícone e cor baseado no título (Fallback para o backend atual)
    IconData icon = Icons.account_balance_wallet;
    Color accentColor = AppTheme.textSilver;
    
    final titleLower = financing.title.toLowerCase();
    if (titleLower.contains('moto') || titleLower.contains('carro') || titleLower.contains('veículo')) {
      icon = Icons.directions_car;
      accentColor = AppTheme.neonBlue;
    } else if (titleLower.contains('casa') || titleLower.contains('apto') || titleLower.contains('imóvel')) {
      icon = Icons.home;
      accentColor = AppTheme.neonGreen;
    } else if (titleLower.contains('pessoal') || titleLower.contains('crédito')) {
      icon = Icons.person;
      accentColor = AppTheme.neonOrange;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : AppTheme.borderDark,
            width: isSelected ? 1.5 : 1
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 20, color: accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(financing.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                        const SizedBox(height: 4),
                        Text(financing.institution,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSilver)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.inputDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderDark)
                    ),
                    child: Text('${financing.interestRate}% a.m.', 
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progresso', style: TextStyle(fontSize: 12, color: AppTheme.textSilver)),
                  Text('${(financing.progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: financing.progress,
                  backgroundColor: AppTheme.inputDark,
                  valueColor: AlwaysStoppedAnimation(accentColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${financing.paidInstallments} pagas',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSilver.withOpacity(0.7))),
                  Text('${financing.remainingInstallments} restantes',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSilver.withOpacity(0.7))),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(color: AppTheme.borderDark),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Saldo Devedor', style: TextStyle(fontSize: 11, color: AppTheme.textSilver)),
                      const SizedBox(height: 2),
                      Text(currencyFormat.format(financing.remainingAmount),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Mensalidade', style: TextStyle(fontSize: 11, color: AppTheme.textSilver)),
                      const SizedBox(height: 2),
                      Text(currencyFormat.format(financing.currentInstallmentValue),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}