import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Necessário apenas para o AuthProvider
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/konta_snack.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/creditCards/controllers/credit_card_controller.dart';

class AddCardModal extends StatefulWidget {
  // 1. Recebemos o controller aqui direto da tela pai
  final CreditCardController controller;

  const AddCardModal({
    super.key, 
    required this.controller
  });

  @override
  State<AddCardModal> createState() => _AddCardModalState();
}

class _AddCardModalState extends State<AddCardModal> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final limitCtrl = TextEditingController();
  final last4Ctrl = TextEditingController();
  
  String selectedBrand = 'Visa';
  int closingDay = 1;
  int dueDay = 10;
  Color selectedColor = const Color(0xFF000000); 

  final List<Color> cardColors = [
    const Color(0xFF000000), 
    const Color(0xFF820AD1), 
    const Color(0xFFEA580C), 
    const Color(0xFFDC2626), 
    const Color(0xFF0056b3), 
    const Color(0xFF28a745), 
  ];

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
              const Text("Novo Cartão", style: TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
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
                    child: DropdownButton<String>(
                      value: selectedBrand,
                      dropdownColor: AppTheme.inputDark,
                      underline: const SizedBox(),
                      items: ['Visa', 'Mastercard', 'Elo', 'Amex'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(color: AppTheme.textWhite)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedBrand = val!),
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

              // 2. Usamos ListenableBuilder para ouvir o controller passado no construtor
              ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: widget.controller.isLoading ? null : _saveCard,
                    child: widget.controller.isLoading
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : const Text("ADICIONAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            items: List.generate(31, (index) => index + 1).map((d) {
              return DropdownMenuItem(value: d, child: Text("Dia $d", style: const TextStyle(color: AppTheme.textWhite)));
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    // AuthProvider geralmente é global, então Provider.of funciona
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    if (user != null) {
      String hexColor = '#${selectedColor.value.toRadixString(16).substring(2)}';

      final body = {
        "nome": nameCtrl.text,
        "bandeira": selectedBrand,
        "ultimos4": last4Ctrl.text,
        "corHex": hexColor,
        "limite": double.tryParse(limitCtrl.text.replaceAll(',', '.')) ?? 0.0,
        "diaFechamento": closingDay,
        "diaVencimento": dueDay
      };

      // 3. Chamamos o método no controller que recebemos
      final success = await widget.controller.addCard(context, user.token!, user.id, body);
      
      if (success && mounted) {
        KontaSnack.show(context, title: "Sucesso", message: "Cartão adicionado com sucesso!");
        Navigator.pop(context);
      } else if (mounted) {
        KontaSnack.show(context, type: KontaSnackType.error, title: "Erro", message: widget.controller.error ?? "Falha ao adicionar cartão.");
      }
    }
  }
}