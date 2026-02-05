import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/expenses/controllers/variable_expenses_controller.dart';

class HistoryModal extends StatelessWidget {
  const HistoryModal({super.key});

  @override
  Widget build(BuildContext context) {
    // Ao abrir, garante que buscamos os dados
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    Provider.of<VariableExpensesController>(context, listen: false).fetchInativas(user.token!, user.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(top: BorderSide(color: AppTheme.borderDark)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(width: 40, height: 4, color: AppTheme.borderDark, margin: const EdgeInsets.only(bottom: 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Histórico", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                  IconButton(icon: const Icon(Icons.close, color: AppTheme.textSilver), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<VariableExpensesController>(
                  builder: (context, ctrl, _) {
                    if (ctrl.categoriasInativas.isEmpty) {
                      return const Center(child: Text("Lixeira vazia.", style: TextStyle(color: AppTheme.textSilver)));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: ctrl.categoriasInativas.length,
                      itemBuilder: (ctx, index) {
                        final cat = ctrl.categoriasInativas[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.inputDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderDark),
                          ),
                          child: ListTile(
                            title: Text(cat.nome, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSilver)),
                            subtitle: Text("Limite: ${Formatters.formatMoney(cat.limite)}", style: TextStyle(color: AppTheme.textSilver.withValues(alpha: 0.5))),
                            trailing: IconButton(
                              onPressed: () {
                                ctrl.reactivateCategory(context, user.token!, user.id, cat.id);
                                Navigator.pop(ctx);
                              },
                              icon: const Icon(Icons.refresh, color: AppTheme.primaryModern),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}