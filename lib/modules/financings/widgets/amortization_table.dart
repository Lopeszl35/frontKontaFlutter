import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/data/models/financing_model.dart';

class AmortizationTableWidget extends StatefulWidget {
  final Financing financing;

  const AmortizationTableWidget({super.key, required this.financing});

  @override
  State<AmortizationTableWidget> createState() => _AmortizationTableWidgetState();
}

class _AmortizationTableWidgetState extends State<AmortizationTableWidget> {
  bool _showAll = false;
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    // Usamos as parcelas que vêm do backend
    final allParcels = widget.financing.parcels;
    
    // Filtramos apenas as abertas (futuras)
    final openParcels = allParcels.where((p) => p.status == 'aberta').toList();
    
    if (openParcels.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.borderDark)),
        child: const Center(child: Text("Nenhuma parcela futura.", style: TextStyle(color: AppTheme.textSilver))),
      );
    }

    final displayList = _showAll ? openParcels : openParcels.take(5).toList();

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
              
              if (openParcels.length > 5)
                TextButton(
                  onPressed: () => setState(() => _showAll = !_showAll),
                  child: Text(_showAll ? 'Ver Menos' : 'Ver Todas', 
                    style: const TextStyle(color: AppTheme.neonBlue)),
                ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(color: AppTheme.inputDark, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                SizedBox(width: 30, child: Text('#', style: TextStyle(color: AppTheme.textSilver, fontSize: 12))),
                Expanded(child: Text('Vencimento', style: TextStyle(color: AppTheme.textSilver, fontSize: 12))),
                Expanded(child: Text('Valor', textAlign: TextAlign.end, style: TextStyle(color: AppTheme.textSilver, fontSize: 12))),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Column(
            children: displayList.map((parcel) {
              final isNext = parcel == openParcels.first;
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
                      child: Text('${parcel.number}', 
                        style: TextStyle(
                          color: isNext ? AppTheme.neonBlue : AppTheme.textWhite, 
                          fontWeight: FontWeight.bold
                        ))
                    ),
                    Expanded(
                      child: Text(
                        parcel.dueDate != null ? DateFormat('dd/MM/yyyy').format(parcel.dueDate!) : '-', 
                        style: const TextStyle(color: AppTheme.textSilver, fontSize: 12)
                      )
                    ),
                    Expanded(
                      child: Text(
                        currencyFormat.format(parcel.value), 
                        textAlign: TextAlign.end, 
                        style: const TextStyle(color: AppTheme.textWhite, fontSize: 12)
                      )
                    ),
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