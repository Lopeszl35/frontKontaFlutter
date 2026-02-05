import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/expenses/controllers/variable_expenses_controller.dart';
// Importamos os novos widgets extraídos
import 'package:konta_app/modules/expenses/widgets/expenses_summary_card.dart';
import 'package:konta_app/modules/expenses/widgets/expenses_grid.dart';
import 'package:konta_app/modules/expenses/widgets/expenses_header_actions.dart';
// Modais
import 'package:konta_app/modules/expenses/widgets/modals/add_expense_modal.dart';
import 'package:konta_app/modules/expenses/widgets/modals/category_modal.dart';
import 'package:konta_app/modules/expenses/widgets/modals/history_modal.dart';
import 'package:konta_app/modules/expenses/widgets/modals/limit_modal.dart';

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
      ctrl.fetchCards(user.token!, user.id);
    }
  }

  // --- MÉTODOS DE ABERTURA DE MODAL (COM CORREÇÃO DE PROVIDER) ---
  
  void _openAddExpense(int catId, String catNome) {
    final controller = Provider.of<VariableExpensesController>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller, // Repassa o controller existente
        child: AddExpenseModal(categoriaId: catId, categoriaNome: catNome),
      ),
    );
  }

  void _openCategoryModal({dynamic category}) {
    final controller = Provider.of<VariableExpensesController>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: CategoryModal(category: category),
      ),
    );
  }

  void _openHistoryModal() {
    final controller = Provider.of<VariableExpensesController>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: const HistoryModal(),
      ),
    );
  }

  void _openLimitModal() {
    final controller = Provider.of<VariableExpensesController>(context, listen: false);
    showDialog(
      context: context, 
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: const LimitModal(),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VariableExpensesController>(context);
    final user = Provider.of<AuthProvider>(context, listen: false).user!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Gastos Variáveis"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openLimitModal,
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
                    // 1. Resumo do Mês 
                    const ExpensesSummaryCard(),

                    const SizedBox(height: 32),

                    // 2. Cabeçalho e Ações 
                    ExpensesHeaderActions(
                      onHistoryTap: _openHistoryModal,
                      onNewCategoryTap: () => _openCategoryModal(),
                    ),

                    const SizedBox(height: 16),

                    // 3. Grid de Categorias
                    ExpensesGrid(
                      onEditCategory: (cat) => _openCategoryModal(category: cat),
                      onAddExpense: (id, nome) => _openAddExpense(id, nome),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}