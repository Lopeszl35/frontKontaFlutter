import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/konta_snack.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/expenses/controllers/variable_expenses_controller.dart';
import 'package:konta_app/data/models/credit_card_model.dart';
import 'package:konta_app/modules/creditCards/pages/credit_cards_screen.dart';

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
  final _formKey = GlobalKey<FormState>(); // Adicionado para validação real
  final _valorCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  
  String _selectedPayment = 'DINHEIRO';
  String? _selectedCardUuid;
  DateTime _selectedDate = DateTime.now();

  static const List<Map<String, String>> _paymentMethods = [
    {'id': 'DINHEIRO', 'label': 'Dinheiro'},
    {'id': 'PIX', 'label': 'Pix'},
    {'id': 'DEBITO', 'label': 'Débito'},
    {'id': 'CREDITO', 'label': 'Crédito'},
  ];

  @override
  void dispose() {
    _valorCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  // --- Lógica de Negócio da UI ---

  Future<void> _onPaymentChanged(String? newValue, VariableExpensesController controller, String userToken, int userId) async {
    if (newValue == null) return;
    
    setState(() => _selectedPayment = newValue);

    if (newValue == 'CREDITO') {
      // Busca cartões apenas se necessário
      await controller.fetchCards(userToken, userId);
      
      if (!mounted) return;

      if (controller.userCards.isEmpty) {
        _showNoCardDialog();
      } else {
        // Pré-seleciona o primeiro cartão para UX melhor
        setState(() => _selectedCardUuid = controller.userCards.first.uuid);
      }
    } else {
      setState(() => _selectedCardUuid = null);
    }
  }

  Future<void> _handleSave(VariableExpensesController controller) async {
    if (!_formKey.currentState!.validate()) return;
    
    // Esconde o teclado
    FocusScope.of(context).unfocus();

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final valor = double.tryParse(_valorCtrl.text.replaceAll(',', '.')) ?? 0.0;

    final success = await controller.addExpense(
      context: context,
      token: user.token!,
      userId: user.id,
      categoriaId: widget.categoriaId,
      valor: valor,
      descricao: _descCtrl.text.isEmpty ? "Gasto Variável" : _descCtrl.text,
      data: _selectedDate,
      formaPagamento: _selectedPayment,
      uuidCartao: _selectedCardUuid,
    );

    if (success && mounted) {
      Navigator.pop(context);
      KontaSnack.show(context, title: "Sucesso", message: "Gasto registrado!");
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: AppTheme.lightTheme, child: child!),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // --- Construção da UI ---

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return const SizedBox();

    return Consumer<VariableExpensesController>(
      builder: (context, controller, _) {
        return Container(
          // Padding inteligente que respeita o teclado
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24, left: 24, right: 24
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
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildValueInput(),
                  const Divider(color: AppTheme.borderDark),
                  const SizedBox(height: 16),
                  _buildDescriptionInput(),
                  const SizedBox(height: 16),
                  _buildDateAndPaymentRow(controller, user.token!, user.id),
                  
                  // Seletor de Cartão Condicional
                  if (_selectedPayment == 'CREDITO' && controller.userCards.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildCardSelector(controller),
                  ],

                  const SizedBox(height: 32),
                  _buildSubmitButton(controller),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildHeader() {
    return Row(
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
        InkWell(
          onTap: () => Navigator.pop(context), 
          child: const Icon(Icons.close, color: AppTheme.textSilver)
        )
      ],
    );
  }

  Widget _buildValueInput() {
    return TextFormField(
      controller: _valorCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppTheme.textWhite, fontSize: 28, fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
        prefixText: "R\$ ",
        prefixStyle: TextStyle(color: AppTheme.primaryModern, fontSize: 28, fontWeight: FontWeight.bold),
        hintText: "0,00",
        hintStyle: TextStyle(color: AppTheme.textSilver),
        filled: true, fillColor: Colors.transparent,
        border: InputBorder.none,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Informe o valor';
        final v = double.tryParse(value.replaceAll(',', '.'));
        if (v == null || v <= 0) return 'Valor inválido';
        return null;
      },
    );
  }

  Widget _buildDescriptionInput() {
    return TextFormField(
      controller: _descCtrl,
      style: const TextStyle(color: AppTheme.textWhite),
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: "Descrição (Opcional)",
        prefixIcon: const Icon(Icons.edit_note, color: AppTheme.textSilver),
        filled: true, fillColor: AppTheme.inputDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDateAndPaymentRow(VariableExpensesController controller, String token, int userId) {
    return Row(
      children: [
        // Data
        Expanded(
          flex: 4,
          child: TextFormField(
            controller: _dateCtrl,
            readOnly: true,
            onTap: _pickDate,
            style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
            decoration: InputDecoration(
              labelText: "Data",
              prefixIcon: const Icon(Icons.calendar_today, size: 18, color: AppTheme.textSilver),
              filled: true, fillColor: AppTheme.inputDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Pagamento
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: AppTheme.inputDark, borderRadius: BorderRadius.circular(16)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPayment,
                dropdownColor: AppTheme.surface,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSilver),
                style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                onChanged: (val) => _onPaymentChanged(val, controller, token, userId),
                items: _paymentMethods.map((item) {
                  return DropdownMenuItem(value: item['id'], child: Text(item['label']!));
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardSelector(VariableExpensesController controller) {
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
          value: _selectedCardUuid,
          dropdownColor: AppTheme.surface,
          isExpanded: true,
          icon: const Icon(Icons.credit_card, color: AppTheme.primaryModern),
          style: const TextStyle(color: AppTheme.textWhite),
          onChanged: (val) => setState(() => _selectedCardUuid = val),
          items: controller.userCards.map((CreditCardModel card) {
            return DropdownMenuItem(
              value: card.uuid,
              child: Row(
                children: [
                  const Icon(Icons.payment, size: 16, color: AppTheme.textSilver),
                  const SizedBox(width: 8),
                  Text("${card.nome} (Final ${card.ultimos4})", overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(VariableExpensesController controller) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.neonGreen,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        disabledBackgroundColor: AppTheme.neonGreen.withValues(alpha: 0.5),
      ),
      onPressed: controller.isLoading ? null : () => _handleSave(controller),
      child: controller.isLoading
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
          : const Text("ADICIONAR GASTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  void _showNoCardDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text("Nenhum Cartão", style: TextStyle(color: AppTheme.textWhite)),
        content: const Text("Você não possui cartões cadastrados. Deseja cadastrar um agora?", style: TextStyle(color: AppTheme.textSilver)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _selectedPayment = 'DINHEIRO');
            },
            child: const Text("Cancelar", style: TextStyle(color: AppTheme.neonRed)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Fecha Dialog
              Navigator.pop(context); // Fecha Modal de Gasto
              // Navega para tela de Cartões
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditCardsScreen()));
            },
            child: const Text("Cadastrar", style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      )
    );
  }
}