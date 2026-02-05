import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/expenses/controllers/variable_expenses_controller.dart';

class CategoryModal extends StatefulWidget {
  final dynamic category; // Se null, é criação. Se não, é edição.

  const CategoryModal({super.key, this.category});

  @override
  State<CategoryModal> createState() => _CategoryModalState();
}

class _CategoryModalState extends State<CategoryModal> {
  late TextEditingController nameCtrl;
  late TextEditingController limitCtrl;
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.category != null;
    nameCtrl = TextEditingController(text: isEditing ? widget.category.nome : '');
    limitCtrl = TextEditingController(text: isEditing ? widget.category.limite.toStringAsFixed(2) : '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    limitCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    // 1. Limpa erros anteriores e fecha teclado
    setState(() => _errorMessage = null);
    FocusScope.of(context).unfocus();

    final controller = Provider.of<VariableExpensesController>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    if (user == null || user.token == null) {
      setState(() => _errorMessage = "Sessão expirada. Faça login novamente.");
      return;
    }

    final nome = nameCtrl.text.trim();
    final limite = double.tryParse(limitCtrl.text.replaceAll(',', '.')) ?? 0.0;

    if (nome.isEmpty || limite <= 0) {
      setState(() => _errorMessage = "Preencha um nome e um limite válido.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success = false;

      // Chama o controller
      if (widget.category != null) {
        success = await controller.updateCategory(
          context, 
          user.token!, 
          user.id, 
          widget.category.id, 
          nome, 
          limite
        );
      } else {
        success = await controller.createCategory(
          context, 
          user.token!, 
          user.id, 
          nome, 
          limite
        );
      }

      if (success && mounted) {
        Navigator.pop(context); // Fecha modal APENAS no sucesso
      } else if (mounted) {
        // Fallback caso retorne false sem exception
        setState(() => _errorMessage = "Não foi possível salvar. Tente novamente.");
      }

    } catch (e) {
      String msg = e.toString().replaceAll("Exception:", "").trim();

      // --- TRATAMENTO INTELIGENTE DE JSON ---
      try {
        // Tenta encontrar onde começa o JSON (caso venha "Erro: { ... }")
        final startIndex = msg.indexOf('{');
        final endIndex = msg.lastIndexOf('}');

        if (startIndex != -1 && endIndex != -1) {
          final jsonString = msg.substring(startIndex, endIndex + 1);
          final Map<String, dynamic> errorData = jsonDecode(jsonString);
          
          // Se o backend mandou "message", usamos ela
          if (errorData.containsKey('message')) {
            msg = errorData['message'];
          }
        }
      } catch (_) {
        // Se falhar o decode, mantém a mensagem original
      }
      
      // Tradução amigável para erro 404 se não vier JSON
      if (msg.contains("404") || msg.contains("Not Found")) {
        msg = "Recurso não encontrado (404).";
      }

      if (mounted) {
        setState(() => _errorMessage = msg);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;

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
          // CABEÇALHO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? "Editar Categoria" : "Nova Categoria", 
                style: const TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold)
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: AppTheme.textSilver),
              )
            ],
          ),
          const SizedBox(height: 24),
          
          // INPUT NOME
          TextField(
            controller: nameCtrl,
            style: const TextStyle(color: AppTheme.textWhite),
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: "Nome",
              prefixIcon: Icon(Icons.label_outline, color: AppTheme.textSilver),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // INPUT LIMITE
          TextField(
            controller: limitCtrl,
            style: const TextStyle(color: AppTheme.textWhite),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Limite (R\$)",
              prefixIcon: Icon(Icons.attach_money, color: AppTheme.textSilver),
              hintText: "0.00",
              hintStyle: TextStyle(color: Colors.white24)
            ),
          ),
          
          const SizedBox(height: 24),

          // --- ÁREA DE ERRO (FEEDBACK VISUAL) ---
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neonRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neonRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.neonRed, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppTheme.neonRed, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // BOTÃO SALVAR
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryModern,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor: AppTheme.primaryModern.withValues(alpha: 0.5),
            ),
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading 
              ? const SizedBox(
                  height: 20, 
                  width: 20, 
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
              : Text(
                  isEditing ? "SALVAR" : "CRIAR", 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
          )
        ],
      ),
    );
  }
}