import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/konta_snack.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/creditCards/controllers/credit_card_controller.dart';

class AddCardExpenseModal extends StatefulWidget {
  final String cardUuid;

  const AddCardExpenseModal({super.key, required this.cardUuid});

  @override
  State<AddCardExpenseModal> createState() => _AddCardExpenseModalState();
}

class _AddCardExpenseModalState extends State<AddCardExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _valorCtrl = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Outros';
  bool _isInstallment = false; // parcelado
  int _installmentsCount = 2; // numeroParcelas

  final List<String> _categories = [
    'Alimentação', 'Transporte', 'Lazer', 'Assinaturas', 
    'Saúde', 'Educação', 'Casa', 'Outros'
  ];

  // Helper para calcular o valor da parcela em tempo real
  String _getParcelaValue() {
    if (_valorCtrl.text.isEmpty) return "R\$ 0,00";
    try {
      double total = double.parse(_valorCtrl.text.replaceAll(',', '.'));
      double parcela = total / _installmentsCount;
      return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(parcela);
    } catch (e) {
      return "R\$ 0,00";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(top: BorderSide(color: AppTheme.borderDark)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabeçalho
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.inputDark, 
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: const Icon(Icons.add_card, color: AppTheme.neonBlue),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Novo Gasto",
                        style: TextStyle(
                          color: AppTheme.textWhite, 
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(context), 
                        child: const Icon(Icons.close, color: AppTheme.textSilver)
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Valor
                  TextFormField(
                    controller: _valorCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
                    // Atualiza a tela ao digitar para recalcular a parcela
                    onChanged: (_) {
                      if (_isInstallment) setState(() {});
                    },
                    decoration: const InputDecoration(
                      prefixText: "R\$ ",
                      prefixStyle: TextStyle(color: AppTheme.primaryModern, fontSize: 24, fontWeight: FontWeight.bold),
                      hintText: "0,00",
                      hintStyle: TextStyle(color: AppTheme.textSilver),
                      filled: true, fillColor: Colors.transparent,
                      border: InputBorder.none,
                    ),
                    validator: (v) {
                      final val = double.tryParse(v?.replaceAll(',', '.') ?? '');
                      if (val == null || val <= 0) return 'Valor inválido';
                      return null;
                    },
                  ),
                  const Divider(color: AppTheme.borderDark),
                  const SizedBox(height: 16),

                  // Descrição
                  TextFormField(
                    controller: _descCtrl,
                    style: const TextStyle(color: AppTheme.textWhite),
                    maxLength: 255,
                    decoration: InputDecoration(
                      labelText: "Descrição",
                      counterText: "",
                      prefixIcon: const Icon(Icons.edit, color: AppTheme.textSilver),
                      filled: true, fillColor: AppTheme.inputDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                    validator: (v) => (v == null || v.length < 2) ? 'Mínimo 2 caracteres' : null,
                  ),
                  const SizedBox(height: 16),

                  // Categoria e Data (Linha com Overflow Corrigido)
                  Row(
                    children: [
                      // Data
                      Expanded(
                        flex: 4,
                        child: InkWell(
                          onTap: _pickDate,
                          child: Container(
                            // CORREÇÃO: Padding reduzido para evitar overflow
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.inputDark,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSilver),
                                const SizedBox(width: 6),
                                Expanded( // Garante que o texto não estoure
                                  child: Text(
                                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // Espaçamento reduzido
                      
                      // Categoria Dropdown
                      Expanded(
                        flex: 6,
                        child: Container(
                          // CORREÇÃO: Padding reduzido
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(color: AppTheme.inputDark, borderRadius: BorderRadius.circular(16)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              dropdownColor: AppTheme.surface,
                              icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSilver),
                              style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                              isExpanded: true, // Garante que ocupa o espaço sem estourar
                              items: _categories.map((c) => DropdownMenuItem(
                                value: c, 
                                child: Text(c, overflow: TextOverflow.ellipsis)
                              )).toList(),
                              onChanged: (v) => setState(() => _selectedCategory = v!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Toggle Parcelado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: _isInstallment ? AppTheme.neonBlue : AppTheme.borderDark),
                      borderRadius: BorderRadius.circular(16),
                      color: _isInstallment ? AppTheme.neonBlue.withValues(alpha: 0.1) : Colors.transparent,
                    ),
                    child: SwitchListTile(
                      title: const Text("Compra Parcelada?", style: TextStyle(color: AppTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(_isInstallment ? "Selecione as parcelas" : "Pagamento à vista (1x)", style: const TextStyle(color: AppTheme.textSilver, fontSize: 12)),
                      value: _isInstallment,
                      activeColor: AppTheme.neonBlue,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _isInstallment = val),
                    ),
                  ),

                  // Seletor de Parcelas + Valor Calculado
                  if (_isInstallment) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.inputDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _installmentsCount,
                          dropdownColor: AppTheme.inputDark,
                          isExpanded: true,
                          icon: const Icon(Icons.layers, color: AppTheme.neonBlue),
                          style: const TextStyle(color: AppTheme.textWhite, fontSize: 16),
                          items: List.generate(59, (index) => index + 2).map((i) {
                            return DropdownMenuItem(value: i, child: Text("$i vezes"));
                          }).toList(),
                          onChanged: (v) => setState(() => _installmentsCount = v!),
                        ),
                      ),
                    ),
                    
                    // Exibição do valor da parcela
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 14, color: AppTheme.textSilver),
                          const SizedBox(width: 6),
                          Text(
                            "Cada parcela será de ", 
                            style: TextStyle(color: AppTheme.textSilver.withValues(alpha: 0.8), fontSize: 12)
                          ),
                          Text(
                            _getParcelaValue(),
                            style: const TextStyle(color: AppTheme.neonBlue, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Botão Salvar
                  Consumer<CreditCardController>(
                    builder: (context, controller, _) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: controller.isLoading ? null : () => _submit(controller),
                        child: controller.isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("ADICIONAR LANÇAMENTO", style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: AppTheme.lightTheme, child: child!),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit(CreditCardController controller) async {
    if (!_formKey.currentState!.validate()) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    final valor = double.parse(_valorCtrl.text.replaceAll(',', '.'));

    final Map<String, dynamic> payload = {
      "descricao": _descCtrl.text,
      "categoria": _selectedCategory,
      "valorTotal": valor,
      "dataCompra": DateFormat('yyyy-MM-dd').format(_selectedDate),
      "parcelado": _isInstallment,
      "numeroParcelas": _isInstallment ? _installmentsCount : 1, 
    };

    final success = await controller.addTransaction(
      user.token!, 
      user.id, 
      widget.cardUuid, 
      payload
    );

    if (success && mounted) {
      KontaSnack.show(context, title: "Sucesso", message: "Gasto lançado no cartão!");
      Navigator.pop(context);
    } else if (mounted) {
      KontaSnack.show(
        context, 
        type: KontaSnackType.error, 
        title: "Erro", 
        message: controller.error ?? "Falha ao lançar gasto."
      );
    }
  }
}