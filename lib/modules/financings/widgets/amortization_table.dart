import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/konta_snack.dart';
import 'package:konta_app/data/models/financing_model.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/financings/controllers/financing_controller.dart';

class AmortizationTableWidget extends StatefulWidget {
  final Financing financing;

  const AmortizationTableWidget({super.key, required this.financing});

  @override
  State<AmortizationTableWidget> createState() => _AmortizationTableWidgetState();
}

class _AmortizationTableWidgetState extends State<AmortizationTableWidget> {
  bool _showAll = false;
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  // --- CORREÇÃO AQUI ---
  void _confirmPayment(BuildContext context, FinancingParcel parcel) {
    // 1. Captura o controller EXISTENTE antes de abrir a nova rota
    final existingController = Provider.of<FinancingController>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => ChangeNotifierProvider.value(
        // 2. Injeta o controller capturado para dentro do Dialog
        value: existingController,
        child: AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), 
            side: const BorderSide(color: AppTheme.borderDark)
          ),
          title: const Text("Pagar Parcela?", style: TextStyle(color: AppTheme.textWhite)),
          
          // 3. SingleChildScrollView previne o Overflow (listras amarelas)
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Confirmar pagamento da parcela #${parcel.number}?", style: const TextStyle(color: AppTheme.textSilver)),
                const SizedBox(height: 16),
                _infoRow("Vencimento", parcel.dueDate != null ? DateFormat('dd/MM/yyyy').format(parcel.dueDate!) : 'N/A'),
                const SizedBox(height: 8),
                _infoRow("Valor Total", currencyFormat.format(parcel.value), isBold: true, color: AppTheme.textWhite),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text("Cancelar", style: TextStyle(color: AppTheme.textSilver))
            ),
            // Agora o Consumer vai encontrar o Provider que injetamos logo acima
            Consumer<FinancingController>(
              builder: (context, controller, _) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonGreen,
                    foregroundColor: Colors.black,
                    elevation: 0,
                  ),
                  onPressed: controller.isLoading ? null : () async {
                    final user = Provider.of<AuthProvider>(context, listen: false).user;
                    if (user != null) {
                      // Usamos o controller do Consumer para garantir estado atualizado
                      final success = await controller.payParcel(user.token!, user.id, parcel.id);
                      
                      if (context.mounted) {
                        Navigator.pop(ctx); // Fecha dialog
                        if (success) {
                          KontaSnack.show(context, title: "Sucesso", message: "Parcela ${parcel.number} paga!");
                        } else {
                          KontaSnack.show(
                            context, 
                            type: KontaSnackType.error, 
                            title: "Erro", 
                            message: controller.error ?? "Falha no pagamento"
                          );
                        }
                      }
                    }
                  },
                  child: controller.isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text("CONFIRMAR", style: TextStyle(fontWeight: FontWeight.bold)),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSilver, fontSize: 13)),
        Text(value, style: TextStyle(color: color ?? AppTheme.textSilver, fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ordena as parcelas
    final allParcels = List<FinancingParcel>.from(widget.financing.parcels);
    allParcels.sort((a, b) => a.number.compareTo(b.number));

    // Filtra apenas as abertas
    final openParcels = allParcels.where((p) => p.status == 'aberta').toList();
    
    // Identifica a PRÓXIMA parcela a vencer (a primeira da lista aberta)
    final nextParcel = openParcels.isNotEmpty ? openParcels.first : null;

    if (openParcels.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.borderDark)),
        child: const Column(
          children: [
            Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 40),
            SizedBox(height: 12),
            Text("Parabéns! Financiamento Quitado.", style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold)),
          ],
        ),
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
              const Text('Próximas Parcelas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
              if (openParcels.length > 5)
                TextButton(
                  onPressed: () => setState(() => _showAll = !_showAll),
                  child: Text(_showAll ? 'Ver Menos' : 'Ver Todas', style: const TextStyle(color: AppTheme.neonBlue)),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Header Tabela
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(color: AppTheme.inputDark, borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                SizedBox(width: 30, child: Text('#', style: TextStyle(color: AppTheme.textSilver, fontSize: 12))),
                Expanded(child: Text('Vencimento', style: TextStyle(color: AppTheme.textSilver, fontSize: 12))),
                Expanded(child: Text('Valor', textAlign: TextAlign.end, style: TextStyle(color: AppTheme.textSilver, fontSize: 12))),
                SizedBox(width: 40), // Espaço para botão
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Lista
          Column(
            children: displayList.map((parcel) {
              // Verifica se é a próxima parcela (única pagável)
              final isNextToPay = nextParcel != null && parcel.id == nextParcel.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isNextToPay ? AppTheme.neonGreen.withValues(alpha: 0.05) : Colors.transparent,
                  border: isNextToPay ? Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)) : null
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30, 
                      child: Text('${parcel.number}', 
                        style: TextStyle(
                          color: isNextToPay ? AppTheme.neonGreen : AppTheme.textWhite, 
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
                        style: TextStyle(
                          color: isNextToPay ? AppTheme.textWhite : AppTheme.textSilver, 
                          fontSize: 12,
                          fontWeight: isNextToPay ? FontWeight.bold : FontWeight.normal
                        )
                      )
                    ),
                    
                    // BOTÃO DE AÇÃO (Só aparece na próxima parcela)
                    SizedBox(
                      width: 40,
                      child: isNextToPay 
                        ? IconButton(
                            icon: const Icon(Icons.payments_outlined, color: AppTheme.neonGreen, size: 20),
                            tooltip: "Pagar agora",
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _confirmPayment(context, parcel),
                          )
                        : null, 
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