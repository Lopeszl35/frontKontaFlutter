import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/expenses/controllers/variable_expenses_controller.dart';

class LimitModal extends StatelessWidget {
  const LimitModal({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VariableExpensesController>(context, listen: false);
    final limitCtrl = TextEditingController(text: controller.limiteMensal.toStringAsFixed(2));

    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppTheme.borderDark)),
      title: const Text("Meta Global", style: TextStyle(color: AppTheme.textWhite)),
      content: TextField(
        controller: limitCtrl,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: AppTheme.textWhite),
        decoration: const InputDecoration(
          suffixText: "R\$",
          suffixStyle: TextStyle(color: AppTheme.textSilver),
          labelText: "Limite para o Mês",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text("Cancelar", style: TextStyle(color: AppTheme.textSilver))
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryModern),
          onPressed: () {
            final user = Provider.of<AuthProvider>(context, listen: false).user!;
            final val = double.tryParse(limitCtrl.text.replaceAll(',', '.')) ?? 0.0;
            controller.updateMonthlyLimit(context, user.token!, user.id, val);
            Navigator.pop(context);
          },
          child: const Text("Salvar", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}