import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Imports globais
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/konta_snack.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/reminders/controllers/payment_reminders_controller.dart';

// NOME PÚBLICO: Removido o '_'
class AddEditReminderModal extends StatefulWidget {
  final PaymentReminder? reminderToEdit;
  
  const AddEditReminderModal({super.key, this.reminderToEdit});

  @override
  State<AddEditReminderModal> createState() => _AddEditReminderModalState();
}

class _AddEditReminderModalState extends State<AddEditReminderModal> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _descCtrl;
  late TextEditingController _vendorCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _notesCtrl;
  
  String _dueDate = '';
  String _paymentMethod = 'pix';

  @override
  void initState() {
    super.initState();
    final r = widget.reminderToEdit;
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _vendorCtrl = TextEditingController(text: r?.vendorName ?? '');
    _amountCtrl = TextEditingController(text: r?.amount.toString() ?? '');
    _notesCtrl = TextEditingController(text: r?.notes ?? '');
    _dueDate = r?.dueDate ?? '';
    if (r != null) _paymentMethod = r.paymentMethod;
  }

  @override
  void dispose() {
    _descCtrl.dispose(); 
    _vendorCtrl.dispose(); 
    _amountCtrl.dispose(); 
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate.isEmpty) {
      KontaSnack.show(context, type: KontaSnackType.error, title: "Atenção", message: "Escolha uma data de vencimento.");
      return;
    }

    FocusScope.of(context).unfocus();
    
    // Listen: false porque estamos dentro de uma função assíncrona (onPressed)
    final controller = Provider.of<PaymentRemindersController>(context, listen: false);

    final isEditing = widget.reminderToEdit != null;
    
    final r = PaymentReminder(
      id: isEditing ? widget.reminderToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      description: _descCtrl.text.trim(),
      vendorName: _vendorCtrl.text.trim(),
      amount: double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0.0,
      purchaseDate: isEditing ? widget.reminderToEdit!.purchaseDate : DateTime.now().toIso8601String().split('T')[0],
      dueDate: _dueDate,
      paymentMethod: _paymentMethod,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      status: isEditing ? widget.reminderToEdit!.status : 'pending',
    );

    bool success;
    if (isEditing) {
      success = await controller.updateReminder(r);
    } else {
      success = await controller.addReminder(r);
    }

    if (mounted && success) {
      Navigator.pop(context);
      KontaSnack.show(context, title: "Sucesso", message: isEditing ? "Lembrete atualizado." : "Lembrete criado.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentRemindersController>(
      builder: (context, controller, child) {
        return Container(
          padding: EdgeInsets.only(
            left: 24, 
            right: 24, 
            top: 24, 
            // MediaQuery.of(context).viewInsets.bottom garante que o modal suba junto com o teclado
            bottom: MediaQuery.of(context).viewInsets.bottom + 24
          ),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.borderDark)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40, 
                      height: 4, 
                      decoration: BoxDecoration(
                        color: AppTheme.textSilver.withValues(alpha: 0.3), 
                        borderRadius: BorderRadius.circular(2)
                      )
                    )
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    widget.reminderToEdit != null ? 'Editar Lembrete' : 'Novo Lembrete', 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textWhite)
                  ),
                  const SizedBox(height: 24),
                  
                  _buildInput(label: 'O que comprou?', ctrl: _descCtrl, icon: Icons.shopping_bag_outlined),
                  const SizedBox(height: 16),
                  
                  _buildInput(label: 'Nome do credor / vendedor', ctrl: _vendorCtrl, icon: Icons.person_outline),
                  const SizedBox(height: 16),
                  
                  Row(children: [
                    Expanded(child: _buildInput(label: 'Valor (R\$)', ctrl: _amountCtrl, icon: Icons.attach_money, isNumber: true)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate.isNotEmpty ? DateTime.parse(_dueDate) : DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                            builder: (c, child) => Theme(data: AppTheme.lightTheme, child: child!),
                          );
                          if (picked != null) {
                            setState(() => _dueDate = picked.toIso8601String().split('T')[0]);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.inputDark, 
                            borderRadius: BorderRadius.circular(16), 
                            border: Border.all(color: _dueDate.isEmpty ? AppTheme.borderDark : AppTheme.neonBlue)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dueDate.isEmpty ? 'Data Venc.' : DateFormat('dd/MM/yyyy').format(DateTime.parse(_dueDate)), 
                                style: TextStyle(
                                  color: _dueDate.isEmpty ? AppTheme.textSilver : AppTheme.textWhite, 
                                  fontSize: 14
                                )
                              ),
                              const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.textSilver),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                  
                  const SizedBox(height: 16),
                  const Text('Método de Pagamento', style: TextStyle(color: AppTheme.textSilver, fontSize: 13)),
                  const SizedBox(height: 8),
                  
                  Row(children: [
                    _paymentToggle('PIX', Icons.qr_code_rounded, 'pix'),
                    const SizedBox(width: 10),
                    _paymentToggle('Dinheiro', Icons.money_rounded, 'dinheiro'),
                  ]),
                  
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesCtrl,
                    style: const TextStyle(color: AppTheme.textWhite),
                    decoration: const InputDecoration(
                      labelText: 'Observações (Opcional)', 
                      prefixIcon: Icon(Icons.notes, color: AppTheme.textSilver, size: 20), 
                      filled: true, 
                      fillColor: AppTheme.inputDark, 
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none)
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonGreen, 
                      foregroundColor: Colors.black, 
                      padding: const EdgeInsets.symmetric(vertical: 16), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                    ),
                    onPressed: controller.isLoading ? null : _submit,
                    child: controller.isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) 
                      : Text(widget.reminderToEdit != null ? 'SALVAR ALTERAÇÕES' : 'CRIAR LEMBRETE', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildInput({required String label, required TextEditingController ctrl, required IconData icon, bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.textWhite),
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label, 
        prefixIcon: Icon(icon, color: AppTheme.textSilver, size: 20), 
        filled: true, 
        fillColor: AppTheme.inputDark, 
        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide.none)
      ),
      validator: (v) => v == null || v.isEmpty ? "Obrigatório" : null,
    );
  }

  Widget _paymentToggle(String label, IconData icon, String value) {
    final selected = _paymentMethod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.neonBlue.withValues(alpha: 0.15) : AppTheme.inputDark, 
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: selected ? AppTheme.neonBlue : AppTheme.borderDark)
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 18, color: selected ? AppTheme.neonBlue : AppTheme.textSilver),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? AppTheme.neonBlue : AppTheme.textSilver)),
          ]),
        ),
      ),
    );
  }
}