import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/konta_snack.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/creditCards/controllers/credit_card_controller.dart';
import 'package:konta_app/data/models/credit_card_model.dart'; // Import necessário para o model

class AddCardModal extends StatefulWidget {
  final CreditCardController controller;
  final CreditCardModel? cardToEdit; // Se null = Criar, Se preenchido = Editar

  const AddCardModal({
    super.key, 
    required this.controller,
    this.cardToEdit,
  });

  @override
  State<AddCardModal> createState() => _AddCardModalState();
}

class _AddCardModalState extends State<AddCardModal> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController nameCtrl;
  late TextEditingController limitCtrl;
  late TextEditingController last4Ctrl;
  
  // Estado
  String selectedBrand = 'Visa';
  int closingDay = 1;
  int dueDay = 10;
  Color selectedColor = const Color(0xFF000000); 

  final List<Color> cardColors = [
    const Color(0xFF000000), 
    const Color(0xFF820AD1), // Roxo
    const Color(0xFFEA580C), // Laranja
    const Color(0xFFDC2626), // Vermelho
    const Color(0xFF0056b3), // Azul
    const Color(0xFF28a745), // Verde
  ];

  bool get isEditing => widget.cardToEdit != null;

  @override
  void initState() {
    super.initState();
    
    // Inicializa com dados vazios ou dados do cartão a editar
    nameCtrl = TextEditingController(text: widget.cardToEdit?.nome ?? '');
    limitCtrl = TextEditingController(text: widget.cardToEdit?.limite.toString() ?? '');
    last4Ctrl = TextEditingController(text: widget.cardToEdit?.ultimos4 ?? '');
    
    if (isEditing) {
      final card = widget.cardToEdit!;
      selectedBrand = _validBrand(card.bandeira) ? card.bandeira : 'Visa';
      closingDay = card.diaFechamento;
      dueDay = card.diaVencimento;
      
      try {
        if (card.corHex != null && card.corHex!.isNotEmpty) {
          selectedColor = Color(int.parse(card.corHex!.replaceAll('#', '0xFF')));
        }
      } catch (_) {
        selectedColor = cardColors.first;
      }
    }
  }

  // Garante que a bandeira vinda do banco exista na nossa lista fixa
  bool _validBrand(String brand) {
    return ['Visa', 'Mastercard', 'Elo', 'Amex'].contains(brand);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    limitCtrl.dispose();
    last4Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 24, left: 24, right: 24
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? "Editar Cartão" : "Novo Cartão", 
                style: const TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: _buildInput(nameCtrl, "Nome (Ex: Nubank)", Icons.credit_card),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.inputDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedBrand,
                        dropdownColor: AppTheme.inputDark,
                        items: ['Visa', 'Mastercard', 'Elo', 'Amex'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(color: AppTheme.textWhite)),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => selectedBrand = val!),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildInput(last4Ctrl, "Últimos 4 dígitos", Icons.pin, isNumber: true, maxLength: 4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInput(limitCtrl, "Limite (R\$)", Icons.attach_money, isNumber: true),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _buildDateDropdown("Fechamento", closingDay, (v) => setState(() => closingDay = v!))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDateDropdown("Vencimento", dueDay, (v) => setState(() => dueDay = v!))),
                ],
              ),
              const SizedBox(height: 16),

              const Text("Cor do Cartão", style: TextStyle(color: AppTheme.textSilver)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: cardColors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == color ? AppTheme.neonGreen : Colors.transparent, 
                          width: 2
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Botão de Ação
              ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: widget.controller.isLoading ? null : _submit,
                    child: widget.controller.isLoading
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : Text(
                            isEditing ? "SALVAR ALTERAÇÕES" : "ADICIONAR", 
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false, int? maxLength}) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.textWhite),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSilver, size: 18),
        counterText: "",
        filled: true,
        fillColor: AppTheme.inputDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (v) => v!.isEmpty ? "Obrigatório" : null,
    );
  }

  Widget _buildDateDropdown(String label, int value, ValueChanged<int?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.inputDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSilver, fontSize: 10)),
          DropdownButton<int>(
            value: value,
            isExpanded: true,
            dropdownColor: AppTheme.inputDark,
            underline: const SizedBox(),
            items: List.generate(28, (index) => index + 1).map((d) { // Backend limita a 28
              return DropdownMenuItem(value: d, child: Text("Dia $d", style: const TextStyle(color: AppTheme.textWhite)));
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    String hexColor = '#${selectedColor.value.toRadixString(16).substring(2)}';

    // Monta o payload conforme a validação do backend
    final Map<String, dynamic> body = {
      "nome": nameCtrl.text,
      "bandeira": selectedBrand,
      "ultimos4": last4Ctrl.text,
      "corHex": hexColor,
      "limite": double.tryParse(limitCtrl.text.replaceAll(',', '.')) ?? 0.0,
      "diaFechamento": closingDay,
      "diaVencimento": dueDay
    };

    bool success;
    
    if (isEditing) {
      success = await widget.controller.editCard(
        user.token!, 
        user.id, 
        widget.cardToEdit!.uuid, // UUID do cartão a editar
        body
      );
    } else {
      success = await widget.controller.addCard(
        context, 
        user.token!, 
        user.id, 
        body
      );
    }
    
    if (success && mounted) {
      KontaSnack.show(context, title: "Sucesso", message: isEditing ? "Cartão atualizado!" : "Cartão criado!");
      Navigator.pop(context);
    } else if (mounted) {
      KontaSnack.show(
        context, 
        type: KontaSnackType.error, 
        title: "Erro", 
        message: widget.controller.error ?? "Falha na operação."
      );
    }
  }
}