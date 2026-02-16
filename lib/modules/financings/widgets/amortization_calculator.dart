import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/data/models/financing_model.dart';

class AmortizationCalculatorWidget extends StatefulWidget {
  final Financing financing;

  const AmortizationCalculatorWidget({super.key, required this.financing});

  @override
  State<AmortizationCalculatorWidget> createState() => _AmortizationCalculatorWidgetState();
}

class _AmortizationCalculatorWidgetState extends State<AmortizationCalculatorWidget> {
  final _controller = TextEditingController();
  Map<String, dynamic>? _result;
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  void _calculate() {
    final extra = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (extra == null || extra <= 0) return;

    final f = widget.financing;
    final monthlyRate = f.interestRate / 100;
    final remaining = f.totalInstallments - f.paidInstallments;
    final currentTotalInterest = (f.monthlyPayment * remaining) - f.remainingAmount;
    final newRemaining = f.remainingAmount - extra;
    
    // Cálculo simplificado de amortização (SAC/Price misto para estimativa)
    // pmt = PV * i / (1 - (1+i)^-n) -> isolando n
    final pmtFactor = (newRemaining * monthlyRate) / f.monthlyPayment;

    int newInstallments;
    if (pmtFactor >= 1 || newRemaining <= 0) {
      newInstallments = 0; // Quitado ou inválido
    } else {
      newInstallments = (-log(1 - pmtFactor) / log(1 + monthlyRate)).ceil();
    }

    final monthsReduced = remaining - newInstallments;
    final newTotalPayment = newInstallments * f.monthlyPayment;
    final newTotalInterest = newTotalPayment - newRemaining;
    final interestSaved = currentTotalInterest - newTotalInterest;
    
    final newEndDate = DateTime.now().add(Duration(days: newInstallments * 30));

    setState(() {
      _result = {
        'monthsReduced': monthsReduced > 0 ? monthsReduced : 0,
        'interestSaved': interestSaved > 0 ? interestSaved : 0.0,
        'newEndDate': newEndDate,
        'newRemainingAmount': newRemaining > 0 ? newRemaining : 0.0,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
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
          const Row(
            children: [
              Icon(Icons.calculate, size: 18, color: AppTheme.neonGreen),
              SizedBox(width: 8),
              Text('Simular Amortização',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
            ],
          ),
          const SizedBox(height: 16),

          const Text('Valor para antecipar', style: TextStyle(fontSize: 12, color: AppTheme.textSilver)),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppTheme.textWhite),
                  decoration: InputDecoration(
                    hintText: 'Ex: 5000.00',
                    hintStyle: TextStyle(color: AppTheme.textSilver.withValues(alpha: .5)),
                    filled: true,
                    fillColor: AppTheme.inputDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    prefixText: 'R\$ ',
                    prefixStyle: const TextStyle(color: AppTheme.neonGreen),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Calcular', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          if (_result != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.inputDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _resultItem(
                          'Meses a menos', 
                          '-${_result!['monthsReduced']}', 
                          Icons.timelapse, 
                          AppTheme.neonBlue
                        )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _resultItem(
                          'Juros Economizados', 
                          currencyFormat.format(_result!['interestSaved']), 
                          Icons.savings, 
                          AppTheme.neonGreen
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppTheme.borderDark),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nova previsão de quitação:', style: TextStyle(fontSize: 12, color: AppTheme.textSilver)),
                      Text(
                        DateFormat('MMMM yyyy', 'pt_BR').format(_result!['newEndDate']).toUpperCase(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textWhite),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _resultItem(String label, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSilver)),
        ]),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}