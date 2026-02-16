import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/expenses/controllers/variable_expenses_controller.dart';

// Widgets
import 'package:konta_app/modules/expenses/widgets/expenses_summary_card.dart';
import 'package:konta_app/modules/expenses/widgets/expenses_grid.dart';
import 'package:konta_app/modules/expenses/widgets/expenses_header_actions.dart';
import 'package:konta_app/modules/expenses/widgets/variable_expenses_skeleton.dart'; // Import do Skeleton

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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    
    if (user != null && user.token != null) {
      final ctrl = Provider.of<VariableExpensesController>(context, listen: false);
      // Fetch data in parallel for performance? Or sequential? Sequential is safer for dependency.
      await ctrl.fetchAllData(user.token!, user.id);
      // Fetch cards in background (fire and forget unless needed immediately)
      ctrl.fetchCards(user.token!, user.id);
    }
  }

  // --- MÉTODOS DE ABERTURA DE MODAL (Clean Architecture) ---
  // Passamos o controller via value provider para garantir que o estado persista
  
  void _openAddExpense(int catId, String catNome) {
    final controller = Provider.of<VariableExpensesController>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller, 
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
    // Dialogs precisam de Material transparente se tiverem bordas arredondadas customizadas
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
    final user = Provider.of<AuthProvider>(context).user;

    // Fail safe
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Gastos Variáveis",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.textWhite),
            onPressed: _openLimitModal,
          ),
          const SizedBox(width: 8),
        ],
      ),
      // AnimatedSwitcher para transição suave entre Loading e Conteúdo
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: controller.isLoading
            ? const VariableExpensesSkeleton() // Skeleton ao carregar
            : RefreshIndicator(
                color: AppTheme.neonGreen, // Ou sua cor primária de destaque
                backgroundColor: AppTheme.surface,
                onRefresh: () async => await controller.fetchAllData(user.token!, user.id),
                child: _ExpensesContentList(
                  onHistoryTap: _openHistoryModal,
                  onNewCategoryTap: () => _openCategoryModal(),
                  onEditCategory: (cat) => _openCategoryModal(category: cat),
                  onAddExpense: (id, nome) => _openAddExpense(id, nome),
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// VIEW ISOLADA (Performance: Build separado)
// ---------------------------------------------------------------------------
class _ExpensesContentList extends StatelessWidget {
  final VoidCallback onHistoryTap;
  final VoidCallback onNewCategoryTap;
  final Function(dynamic) onEditCategory; // Tipar corretamente se tiver o Model
  final Function(int, String) onAddExpense;

  const _ExpensesContentList({
    required this.onHistoryTap,
    required this.onNewCategoryTap,
    required this.onEditCategory,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView com physics always scrollable para permitir refresh mesmo se conteúdo for pequeno
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Resumo do Mês 
          const ExpensesSummaryCard(),

          const SizedBox(height: 32),

          // 2. Cabeçalho e Ações (Passando callbacks para manter o widget puro)
          ExpensesHeaderActions(
            onHistoryTap: onHistoryTap,
            onNewCategoryTap: onNewCategoryTap,
          ),

          const SizedBox(height: 16),

          // 3. Grid de Categorias
          ExpensesGrid(
            onEditCategory: onEditCategory,
            onAddExpense: onAddExpense,
          ),

          const SizedBox(height: 40), // Espaço final
        ],
      ),
    );
  }
}