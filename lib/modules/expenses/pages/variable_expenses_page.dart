import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart';
import 'package:konta_app/core/utils/konta_snack.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/expenses/controllers/variable_expenses_controller.dart';
import 'package:konta_app/data/models/card_model.dart';

class VariableExpensesPage extends StatelessWidget {
  const VariableExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VariableExpensesController(),
      child: const _PageContent(),
    );
  }
}

class _PageContent extends StatefulWidget {
  const _PageContent();
  @override
  State<_PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<_PageContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final ctrl = Provider.of<VariableExpensesController>(context, listen: false);
      await ctrl.fetchAllData(user.token!, user.id);
      // Carrega cartões preventivamente
      ctrl.fetchCards(user.token!, user.id);
    }
  }

  // --- 1. LÓGICA DE SALVAR CATEGORIA (O erro estava aqui por falta de uso) ---
  void _handleSaveCategory({int? id, required String nome, required String limiteStr}) async {
    final controller = Provider.of<VariableExpensesController>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    final limite = double.tryParse(limiteStr.replaceAll(',', '.')) ?? 0.0;

    if (nome.isEmpty || limite <= 0) {
      KontaSnack.show(context, title: "Atenção", message: "Dados inválidos.", type: KontaSnackType.warning);
      return;
    }

    bool success;
    if (id != null) {
      success = await controller.updateCategory(context, user.token!, user.id, id, nome, limite);
    } else {
      success = await controller.createCategory(context, user.token!, user.id, nome, limite);
    }

    if (success && mounted) Navigator.pop(context);
  }

  // --- 2. MODAL EXCLUIR ---
  void _confirmDelete(int id, String nome) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppTheme.borderDark)),
        title: const Text("Arquivar Categoria?", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
        content: Text("A categoria '$nome' será enviada para o histórico.", style: const TextStyle(color: AppTheme.textSilver)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar", style: TextStyle(color: AppTheme.textSilver)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonRed.withValues(alpha: 0.2),
              foregroundColor: AppTheme.neonRed,
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final controller = Provider.of<VariableExpensesController>(context, listen: false);
              final user = Provider.of<AuthProvider>(context, listen: false).user!;
              await controller.deleteCategory(context, user.token!, user.id, id);
            },
            child: const Text("Arquivar", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- 3. MODAL UNIFICADO (CRIAR/EDITAR CATEGORIA) ---
  void _showCategoryDialog(BuildContext context, {dynamic category}) {
    final isEditing = category != null;
    final nameCtrl = TextEditingController(text: isEditing ? category.nome : '');
    final limitCtrl = TextEditingController(text: isEditing ? category.limite.toStringAsFixed(2) : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 30,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isEditing ? "Editar Categoria" : "Nova Categoria", style: const TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
                InkWell(
                  onTap: () => Navigator.pop(ctx),
                  child: const Icon(Icons.close, color: AppTheme.textSilver),
                )
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: const InputDecoration(
                labelText: "Nome",
                prefixIcon: Icon(Icons.label_outline, color: AppTheme.textSilver),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: limitCtrl,
              style: const TextStyle(color: AppTheme.textWhite),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Limite (R\$)",
                prefixIcon: Icon(Icons.attach_money, color: AppTheme.textSilver),
              ),
            ),
            const SizedBox(height: 32),
            
            // CORREÇÃO: Aqui conectamos a função que estava "unused"
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryModern,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _handleSaveCategory(
                id: isEditing ? category.id : null,
                nome: nameCtrl.text,
                limiteStr: limitCtrl.text
              ),
              child: Text(
                isEditing ? "SALVAR" : "CRIAR", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- 4. MODAL LIMITE GLOBAL ---
  void _showEditLimitDialog(BuildContext context, VariableExpensesController controller) {
    final limitCtrl = TextEditingController(text: controller.limiteMensal.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: AppTheme.textSilver))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryModern),
            onPressed: () {
              final user = Provider.of<AuthProvider>(context, listen: false).user!;
              final val = double.tryParse(limitCtrl.text.replaceAll(',', '.')) ?? 0.0;
              controller.updateMonthlyLimit(context, user.token!, user.id, val);
              Navigator.pop(ctx);
            },
            child: const Text("Salvar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- 5. MODAL INATIVAS ---
  void _showInativasDialog(BuildContext context, VariableExpensesController controller) {
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    controller.fetchInativas(user.token!, user.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: controller, 
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (_, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border(top: BorderSide(color: AppTheme.borderDark)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(width: 40, height: 4, color: AppTheme.borderDark, margin: const EdgeInsets.only(bottom: 20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Histórico", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                        IconButton(icon: const Icon(Icons.close, color: AppTheme.textSilver), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Consumer<VariableExpensesController>(
                        builder: (context, ctrl, _) {
                          if (ctrl.categoriasInativas.isEmpty) {
                            return const Center(child: Text("Lixeira vazia.", style: TextStyle(color: AppTheme.textSilver)));
                          }
                          return ListView.builder(
                            controller: scrollController,
                            itemCount: ctrl.categoriasInativas.length,
                            itemBuilder: (ctx, index) {
                              final cat = ctrl.categoriasInativas[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.inputDark,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.borderDark),
                                ),
                                child: ListTile(
                                  title: Text(cat.nome, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSilver)),
                                  subtitle: Text("Limite: ${Formatters.formatMoney(cat.limite)}", style: TextStyle(color: AppTheme.textSilver.withValues(alpha: 0.5))),
                                  trailing: IconButton(
                                    onPressed: () {
                                      ctrl.reactivateCategory(context, user.token!, user.id, cat.id);
                                      Navigator.pop(ctx);
                                    },
                                    icon: const Icon(Icons.refresh, color: AppTheme.primaryModern),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // --- 6. MODAL ADICIONAR GASTO (INTEGRADO) ---
  void _showAddExpenseDialog(BuildContext context, int categoriaId, String categoriaNome) {
    final controller = Provider.of<VariableExpensesController>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 30,
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
                          Text(categoriaNome, style: const TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    InkWell(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, color: AppTheme.textSilver))
                  ],
                ),
                const SizedBox(height: 24),

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
                            selectedDate = picked;
                            dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
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
                              setModalState(() {
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

                if (selectedPayment == 'CREDITO') ...[
                  const SizedBox(height: 16),
                  Container(
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
                          setModalState(() {
                            selectedCardUuid = newValue;
                          });
                        },
                        items: controller.userCards.map<DropdownMenuItem<String>>((CardModel card) {
                          return DropdownMenuItem<String>(
                            value: card.uuid,
                            child: Row(children: [const Icon(Icons.payment, size: 16, color: AppTheme.textSilver), const SizedBox(width: 8), Text("${card.nome} (Final ${card.ultimosDigitos})")]),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
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
                      categoriaId: categoriaId,
                      valor: valor,
                      descricao: descCtrl.text.isEmpty ? "Gasto Variável" : descCtrl.text,
                      data: selectedDate,
                      formaPagamento: selectedPayment,
                      uuidCartao: selectedCardUuid,
                    );
                    if (success && mounted) Navigator.pop(ctx);
                  },
                  child: const Text("ADICIONAR GASTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // --- BUILD PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VariableExpensesController>(context);
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    
    final progressoTotal = controller.limiteMensal > 0 ? (controller.gastoTotalMes / controller.limiteMensal) : 0.0;
    final saldoRestante = controller.limiteMensal - controller.gastoTotalMes;

    return Scaffold(
      backgroundColor: AppTheme.background, 
      appBar: AppBar(
        title: const Text("Gastos Variáveis"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showEditLimitDialog(context, controller),
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppTheme.primaryModern,
              backgroundColor: AppTheme.surface,
              onRefresh: () async => await controller.fetchAllData(user.token!, user.id),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // CARD RESUMO
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.premiumGradient,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primaryModern.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Janeiro/2026", style: TextStyle(color: AppTheme.textSilver, fontSize: 14, fontWeight: FontWeight.w500)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  "${(progressoTotal * 100).toInt()}% Usado", 
                                  style: const TextStyle(color: AppTheme.neonBlue, fontSize: 12, fontWeight: FontWeight.bold)
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("GASTO", style: TextStyle(color: AppTheme.textSilver, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text(Formatters.formatMoney(controller.gastoTotalMes), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Container(height: 40, width: 1, color: Colors.white10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("META", style: TextStyle(color: AppTheme.textSilver, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                      const SizedBox(height: 4),
                                      Text(Formatters.formatMoney(controller.limiteMensal), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progressoTotal.clamp(0.0, 1.0),
                              backgroundColor: Colors.black38,
                              valueColor: AlwaysStoppedAnimation(progressoTotal > 1 ? AppTheme.neonRed : AppTheme.neonGreen),
                              minHeight: 8,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Saldo Restante:", style: TextStyle(color: AppTheme.textSilver, fontSize: 13)),
                                Text(
                                  Formatters.formatMoney(saldoRestante),
                                  style: TextStyle(
                                    color: saldoRestante < 0 ? AppTheme.neonRed : AppTheme.neonGreen, 
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 16,
                                    shadows: [Shadow(color: (saldoRestante < 0 ? AppTheme.neonRed : AppTheme.neonGreen).withValues(alpha: 0.5), blurRadius: 10)]
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // CABEÇALHO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Categorias", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _showInativasDialog(context, controller),
                              icon: const Icon(Icons.history_outlined, color: AppTheme.textSilver),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _showCategoryDialog(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryModern,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: AppTheme.primaryModern.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.add, size: 18, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text("Nova", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // GRID
                    if (controller.categoriasAtivas.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              Icon(Icons.grid_off_rounded, size: 48, color: AppTheme.textSilver.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              const Text("Nenhuma categoria ativa", style: TextStyle(color: AppTheme.textSilver)),
                            ],
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: controller.categoriasAtivas.length,
                        itemBuilder: (ctx, index) {
                          final cat = controller.categoriasAtivas[index];
                          return _buildModernCard(context, cat, controller);
                        },
                      ),
                      
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // --- CARD MODERNO ---
  Widget _buildModernCard(BuildContext context, dynamic cat, VariableExpensesController controller) {
    final percent = cat.limite > 0 ? (cat.totalGasto / cat.limite) : 0.0;
    
    Color statusColor = AppTheme.neonGreen; 
    if (percent > 1.0) {
      statusColor = AppTheme.neonRed; 
    } else if (percent > 0.8) {
      statusColor = AppTheme.neonOrange;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface, 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderDark, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppTheme.inputDark, borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.category_rounded, color: AppTheme.textWhite, size: 20),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                        child: Text("${(percent * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 11)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(cat.nome, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textWhite)),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: Formatters.formatMoney(cat.totalGasto), style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 13, fontFamily: 'Inter')),
                        TextSpan(text: " / ${Formatters.formatMoney(cat.limite)}", style: const TextStyle(color: AppTheme.textSilver, fontSize: 11, fontFamily: 'Inter')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent.clamp(0.0, 1.0), 
                      backgroundColor: AppTheme.inputDark,
                      valueColor: AlwaysStoppedAnimation(statusColor), 
                      minHeight: 6
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Container(
            height: 48,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _showCategoryDialog(context, category: cat),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24)),
                    child: const Center(child: Icon(Icons.edit_outlined, size: 20, color: AppTheme.textSilver)),
                  ),
                ),
                Container(width: 1, height: 20, color: AppTheme.borderDark),
                Expanded(
                  child: InkWell(
                    onTap: () => _confirmDelete(cat.id, cat.nome),
                    child: const Center(child: Icon(Icons.delete_outline, size: 20, color: AppTheme.neonRed)),
                  ),
                ),
                Container(width: 1, height: 20, color: AppTheme.borderDark),
                Expanded(
                  child: InkWell(
                    onTap: () => _showAddExpenseDialog(context, cat.id, cat.nome),
                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryModern,
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
                      ),
                      child: const Center(child: Icon(Icons.add, size: 22, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}