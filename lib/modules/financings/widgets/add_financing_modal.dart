import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/konta_snack.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/financings/controllers/financing_controller.dart';

class AddFinancingModal extends StatefulWidget {
  const AddFinancingModal({super.key});

  @override
  State<AddFinancingModal> createState() => _AddFinancingModalState();
}

class _AddFinancingModalState extends State<AddFinancingModal> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers de Texto
  final _titleCtrl = TextEditingController();
  final _institutionCtrl = TextEditingController();
  final _totalValueCtrl = TextEditingController();
  final _installmentsCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _dayCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.now()));

  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _institutionCtrl.dispose();
    _totalValueCtrl.dispose();
    _installmentsCtrl.dispose();
    _rateCtrl.dispose();
    _dayCtrl.dispose();
    _startDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final controller = Provider.of<FinancingController>(context, listen: false);

    if (user == null) return;

    // Preparar Payload
    final payload = {
      "titulo": _titleCtrl.text.trim(),
      "instituicao": _institutionCtrl.text.trim(),
      "valorTotal": double.parse(_totalValueCtrl.text.replaceAll(',', '.')),
      "numeroParcelas": int.parse(_installmentsCtrl.text),
      "taxaJurosMensal": double.parse(_rateCtrl.text.replaceAll(',', '.')),
      "diaVencimento": int.parse(_dayCtrl.text),
      "dataInicio": DateFormat('yyyy-MM-dd').format(_selectedDate),
      "sistemaAmortizacao": "PRICE", // Default ou adicione um selector se necessário
    };

    final success = await controller.create(user.token!, user.id, payload);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      KontaSnack.show(context, title: "Sucesso", message: "Financiamento criado!");
    } else {
      KontaSnack.show(context, type: KontaSnackType.error, title: "Erro", message: controller.error ?? "Erro desconhecido");
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (context, child) => Theme(data: AppTheme.lightTheme, child: child!),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _startDateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder para ouvir o loading do controller sem reconstruir a tela toda desnecessariamente
    final controller = Provider.of<FinancingController>(context, listen: false); // Apenas referência

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Novo Financiamento", style: TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: AppTheme.textSilver),
                  )
                ],
              ),
              const SizedBox(height: 24),

              // Inputs Principais
              _buildInput(_titleCtrl, "Título (ex: Moto, Casa)", Icons.title, validator: (v) => v!.length < 3 ? 'Mínimo 3 letras' : null),
              const SizedBox(height: 16),
              _buildInput(_institutionCtrl, "Instituição (ex: Yamaha)", Icons.account_balance),
              const SizedBox(height: 16),
              _buildInput(_totalValueCtrl, "Valor Total (R\$)", Icons.attach_money, isNumber: true, validator: (v) => (double.tryParse(v!.replaceAll(',', '.')) ?? 0) <= 0 ? 'Valor inválido' : null),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildInput(_installmentsCtrl, "Nº Parcelas", Icons.format_list_numbered, isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(_rateCtrl, "Taxa Juros (%)", Icons.percent, isNumber: true)),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  // Dia Vencimento
                  Expanded(
                    child: _buildInput(_dayCtrl, "Dia Vencimento", Icons.event, isNumber: true, validator: (v) {
                      final day = int.tryParse(v ?? '');
                      if (day == null || day < 1 || day > 31) return 'Dia inválido';
                      return null;
                    }),
                  ),
                  const SizedBox(width: 12),
                  // Data Inicio
                  Expanded(
                    child: TextFormField(
                      controller: _startDateCtrl,
                      readOnly: true,
                      onTap: _pickDate,
                      style: const TextStyle(color: AppTheme.textWhite),
                      decoration: InputDecoration(
                        labelText: "Início",
                        prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.textSilver, size: 18),
                        filled: true, fillColor: AppTheme.inputDark,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Botão Salvar
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: controller.isLoading ? null : _submit,
                    child: controller.isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : const Text("CRIAR CONTRATO", style: TextStyle(fontWeight: FontWeight.bold)),
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.textWhite),
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textSilver, size: 18),
        filled: true,
        fillColor: AppTheme.inputDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: validator ?? (v) => v!.isEmpty ? "Obrigatório" : null,
    );
  }
}