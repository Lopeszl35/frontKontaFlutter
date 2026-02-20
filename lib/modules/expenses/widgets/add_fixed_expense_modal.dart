import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports globais
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/konta_snack.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/expenses/controllers/fixed_expenses_controller.dart';

// NOME PÚBLICO (sem o _)
class AddFixedExpenseModal extends StatefulWidget {
  const AddFixedExpenseModal({super.key});

  @override
  State<AddFixedExpenseModal> createState() => _AddFixedExpenseModalState();
}

class _AddFixedExpenseModalState extends State<AddFixedExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  
  final _tituloCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  final _diaVencCtrl = TextEditingController();
  
  String _selectedTipo = 'agua'; 

  final Map<String, String> _tiposBackend = {
    'agua': 'Água',
    'luz': 'Luz/Energia',
    'internet': 'Internet',
    'aluguel': 'Aluguel',
    'assinatura': 'Assinatura',
    'outros': 'Outros'
  };

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _valorCtrl.dispose();
    _diaVencCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final controller = Provider.of<FixedExpensesController>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final payload = {
      "tipo": _selectedTipo,
      "titulo": _tituloCtrl.text.trim(),
      "valor": double.parse(_valorCtrl.text.replaceAll(',', '.')),
      "dia_vencimento": int.parse(_diaVencCtrl.text),
      "recorrencia": "mensal"
    };

    final success = await controller.addExpense(user.token!, user.id, payload);

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        KontaSnack.show(context, title: "Sucesso", message: "Gasto fixo adicionado.");
      } else {
        KontaSnack.show(context, type: KontaSnackType.error, title: "Erro", message: controller.error ?? "Falha ao adicionar");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para que apenas o botão recarregue durante o loading
    return Consumer<FixedExpensesController>(
      builder: (context, controller, child) {
        return Container(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24, // Suporte para teclado
          ),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.borderDark)),
          ),
          child: SingleChildScrollView( // Importante para não dar overflow com o teclado
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textSilver.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 24),
                  
                  const Text('Novo Gasto Fixo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                  const SizedBox(height: 24),
                  
                  _buildInput(label: 'Título (ex: Conta de Água)', ctrl: _tituloCtrl, icon: Icons.title),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedTipo,
                    dropdownColor: AppTheme.inputDark,
                    decoration: _inputDecoration('Tipo', Icons.category_outlined),
                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
                    items: _tiposBackend.entries.map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedTipo = v!),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(children: [
                    Expanded(child: _buildInput(label: 'Valor (R\$)', ctrl: _valorCtrl, icon: Icons.attach_money, isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInput(label: 'Dia Venc.', ctrl: _diaVencCtrl, icon: Icons.event, isNumber: true, validator: (v) {
                      final day = int.tryParse(v ?? '');
                      if (day == null || day < 1 || day > 31) return 'Dia inválido';
                      return null;
                    })),
                  ]),
                  
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: controller.isLoading ? null : _submit,
                    child: controller.isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : const Text('CRIAR GASTO FIXO', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildInput({required String label, required TextEditingController ctrl, required IconData icon, bool isNumber = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.textWhite),
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: _inputDecoration(label, icon),
      validator: validator ?? (v) => v == null || v.isEmpty ? "Obrigatório" : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppTheme.textSilver, size: 20),
      filled: true,
      fillColor: AppTheme.inputDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }
}