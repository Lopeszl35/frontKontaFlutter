import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/konta_snack.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/expenses/controllers/variable_expenses_controller.dart';
import 'package:konta_app/data/models/card_model.dart';

class AddExpenseModal extends StatefulWidget {
  final int categoriaId;
  final String categoriaNome;

  const AddExpenseModal({
    super.key,
    required this.categoriaId,
    required this.categoriaNome,
  });

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final valorCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final dateCtrl = TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  
  String selectedPayment = 'DINHEIRO';
  String? selectedCardUuid;
  DateTime selectedDate = DateTime.now();

  final List<Map<String, String>> paymentMethods = [
    {'id': 'DINHEIRO', 'label': 'Dinheiro'},
    {'id': 'PIX', 'label': 'Pix'},
    {'id': 'DEBITO', 'label': 'Débito'},
    {'id': 'CREDITO', 'label': 'Crédito'},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VariableExpensesController>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user!;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        top: 30, left: 24, right: 24
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.inputDark, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.add_shopping_cart, color: AppTheme.neonGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Adicionar Gasto", style: TextStyle(color: AppTheme.textSilver, fontSize: 12)),
                    Text(widget.categoriaNome, style: const TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              InkWell(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, color: AppTheme.textSilver))
            ],
          ),
          const SizedBox(height: 24),

          // Input Valor
          TextField(
            controller: valorCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppTheme.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              prefixText: "R\$ ",
              prefixStyle: TextStyle(color: AppTheme.primaryModern, fontSize: 24, fontWeight: FontWeight.bold),
              hintText: "0,00",
              hintStyle: TextStyle(color: AppTheme.textSilver),
              filled: true, fillColor: Colors.transparent,
              border: InputBorder.none,
            ),
          ),
          const Divider(color: AppTheme.borderDark),
          const SizedBox(height: 16),

          // Input Descrição
          TextField(
            controller: descCtrl,
            style: const TextStyle(color: AppTheme.textWhite),
            decoration: InputDecoration(
              labelText: "Descrição (Opcional)",
              prefixIcon: const Icon(Icons.edit_note, color: AppTheme.textSilver),
              filled: true, fillColor: AppTheme.inputDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          // Data e Pagamento
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  controller: dateCtrl,
                  readOnly: true,
                  style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: "Data",
                    prefixIcon: const Icon(Icons.calendar_today, size: 18, color: AppTheme.textSilver),
                    filled: true, fillColor: AppTheme.inputDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) => Theme(data: AppTheme.lightTheme, child: child!),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                        dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: AppTheme.inputDark, borderRadius: BorderRadius.circular(16)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedPayment,
                      dropdownColor: AppTheme.surface,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSilver),
                      style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedPayment = newValue!;
                          if (selectedPayment == 'CREDITO' && controller.userCards.isEmpty) {
                            controller.fetchCards(user.token!, user.id);
                          }
                        });
                      },
                      items: paymentMethods.map<DropdownMenuItem<String>>((Map<String, String> item) {
                        return DropdownMenuItem<String>(value: item['id'], child: Text(item['label']!));
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Seletor de Cartão
          if (selectedPayment == 'CREDITO') ...[
            const SizedBox(height: 16),
            Consumer<VariableExpensesController>(
              builder: (context, ctrl, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.inputDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryModern.withValues(alpha: 0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text("Selecione o Cartão", style: TextStyle(color: AppTheme.textSilver)),
                      value: selectedCardUuid,
                      dropdownColor: AppTheme.surface,
                      isExpanded: true,
                      icon: const Icon(Icons.credit_card, color: AppTheme.primaryModern),
                      style: const TextStyle(color: AppTheme.textWhite),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCardUuid = newValue;
                        });
                      },
                      items: ctrl.userCards.map<DropdownMenuItem<String>>((CardModel card) {
                        return DropdownMenuItem<String>(
                          value: card.uuid,
                          child: Row(children: [const Icon(Icons.payment, size: 16, color: AppTheme.textSilver), const SizedBox(width: 8), Text("${card.nome} (Final ${card.ultimosDigitos})")]),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }
            ),
          ],

          const SizedBox(height: 32),
          
          // Botão Ação
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonGreen,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              final valor = double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? 0.0;
              if (valor <= 0) {
                KontaSnack.show(context, title: "Erro", message: "Valor inválido", type: KontaSnackType.warning);
                return;
              }
              final success = await controller.addExpense(
                context: context,
                token: user.token!,
                userId: user.id,
                categoriaId: widget.categoriaId,
                valor: valor,
                descricao: descCtrl.text.isEmpty ? "Gasto Variável" : descCtrl.text,
                data: selectedDate,
                formaPagamento: selectedPayment,
                uuidCartao: selectedCardUuid,
              );
              if (success && mounted) Navigator.pop(context);
            },
            child: const Text("ADICIONAR GASTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
    );
  }
}