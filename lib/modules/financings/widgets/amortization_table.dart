import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/data/models/financing_model.dart';

class AmortizationRow {
  final int installment;
  final double payment;
  final double principal;
  final double interest;
  final double balance;
  final bool isPaid;

  const AmortizationRow({
    required this.installment,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
    required this.isPaid,
  });
}

class AmortizationTableWidget extends StatefulWidget {
  final Financing financing;

  const AmortizationTableWidget({super.key, required this.financing});

  @override
  State<AmortizationTableWidget> createState() => _AmortizationTableWidgetState();
}

class _AmortizationTableWidgetState extends State<AmortizationTableWidget> {
  bool _showTable = false;
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  List<AmortizationRow> _buildRows() {
    final f = widget.financing;
    final monthlyRate = f.interestRate / 100;
    final rows = <AmortizationRow>[];
    var balance = f.totalAmount;

    for (int i = 1; i <= f.totalInstallments; i++) {
      final interest = balance * monthlyRate;
      final principal = f.monthlyPayment - interest;
      balance = max(0, balance - principal);
      
      rows.add(AmortizationRow(
        installment: i,
        payment: f.monthlyPayment,
        principal: max(0, principal),
        interest: max(0, interest),
        balance: max(0, balance),
        isPaid: i <= f.paidInstallments,
      ));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    // Calculamos apenas se a tabela estiver visível para performance, ou limitamos a exibição
    final rows = _buildRows();
    // Pega as próximas 5 parcelas a partir da atual
    final nextInstallments = rows.skip(widget.financing.paidInstallments).take(5).toList();
    final displayList = _showTable ? rows : nextInstallments;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Próximas Parcelas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
              
              TextButton(
                onPressed: () => setState(() => _showTable = !_showTable),
                child: Text(_showTable ? 'Ver Menos' : 'Ver Todas', 
                  style: const TextStyle(color: AppTheme.neonBlue)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cabeçalho da Tabela
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.inputDark,
              borderRadius: BorderRadius.circular(8)
            ),
            child: const Row(
              children: [
                SizedBox(width: 30, child: Text('#', style: TextStyle(color: AppTheme.textSilver, fontSize: 12))),
                Expanded(child: Text('Amortização', style: TextStyle(color: AppTheme.textSilver, fontSize: 12))),
                Expanded(child: Text('Juros', style: TextStyle(color: AppTheme.textSilver, fontSize: 12))),
                Expanded(child: Text('Saldo', textAlign: TextAlign.end, style: TextStyle(color: AppTheme.textSilver, fontSize: 12))),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Linhas
          Column(
            children: displayList.map((row) {
              final isNext = row.installment == widget.financing.paidInstallments + 1;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: isNext ? AppTheme.neonBlue.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isNext ? Border.all(color: AppTheme.neonBlue.withOpacity(0.3)) : null
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30, 
                      child: Text('${row.installment}', 
                        style: TextStyle(
                          color: isNext ? AppTheme.neonBlue : AppTheme.textWhite, 
                          fontWeight: FontWeight.bold
                        ))
                    ),
                    Expanded(child: Text(currencyFormat.format(row.principal), style: const TextStyle(color: AppTheme.textSilver, fontSize: 12))),
                    Expanded(child: Text(currencyFormat.format(row.interest), style: const TextStyle(color: AppTheme.neonRed, fontSize: 12))),
                    Expanded(child: Text(currencyFormat.format(row.balance), textAlign: TextAlign.end, style: const TextStyle(color: AppTheme.textWhite, fontSize: 12))),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}