import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/konta_snack.dart'; // Importe o snack
import 'package:konta_app/data/models/financing_model.dart';

// Controller e Auth
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/financings/controllers/financing_controller.dart';

// Widgets
import 'package:konta_app/modules/financings/widgets/financing_card_widget.dart';
import 'package:konta_app/modules/financings/widgets/amortization_calculator.dart';
import 'package:konta_app/modules/financings/widgets/amortization_table.dart';
import 'package:konta_app/modules/financings/widgets/financings_skeleton_view.dart';
import 'package:konta_app/modules/financings/widgets/add_financing_modal.dart'; // Importe o modal

class FinancingsScreen extends StatelessWidget {
  const FinancingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinancingController(),
      child: const _FinancingsContent(),
    );
  }
}

class _FinancingsContent extends StatefulWidget {
  const _FinancingsContent();

  @override
  State<_FinancingsContent> createState() => _FinancingsContentState();
}

class _FinancingsContentState extends State<_FinancingsContent> {
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      await Provider.of<FinancingController>(context, listen: false)
          .fetchAll(user.token!, user.id);
    }
  }

  // Abre Modal de Criação
  void _openAddModal() {
    final controller = Provider.of<FinancingController>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeNotifierProvider.value(
        value: controller,
        child: const AddFinancingModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FinancingController>(context);
    
    final selectedFinancing = _selectedId != null 
        ? controller.financings.where((f) => f.id == _selectedId).firstOrNull 
        : null;

    if (_selectedId != null && selectedFinancing != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          setState(() => _selectedId = null);
        },
        child: _FinancingDetailView(
          financing: selectedFinancing,
          onBack: () => setState(() => _selectedId = null),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal, // Conectado!
        backgroundColor: AppTheme.neonGreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: controller.isLoading && controller.financings.isEmpty
            ? const FinancingsSkeletonView()
            : RefreshIndicator(
                color: AppTheme.neonGreen,
                backgroundColor: AppTheme.surface,
                onRefresh: _refreshData,
                child: _FinancingsListView(
                  controller: controller,
                  onSelect: (id) => setState(() => _selectedId = id),
                ),
              ),
      ),
    );
  }
}

// ... (_FinancingsListView permanece igual ao anterior) ...
class _FinancingsListView extends StatelessWidget {
  final FinancingController controller;
  final ValueChanged<int> onSelect;

  const _FinancingsListView({required this.controller, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final summary = controller.summary;
    final list = controller.financings;

    if (list.isEmpty) {
      return Center(
        child: Text(
          controller.error ?? "Nenhum financiamento ativo",
          style: TextStyle(color: controller.error != null ? AppTheme.neonRed : AppTheme.textSilver),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Financiamentos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite)),
            ],
          ),
          const SizedBox(height: 20),

          if (summary != null)
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _StatChip(icon: Icons.account_balance_wallet, label: 'Dívida Total', value: currencyFormat.format(summary.totalDebt), color: AppTheme.neonRed),
                  const SizedBox(width: 12),
                  _StatChip(icon: Icons.calendar_today, label: 'Parcela Total', value: currencyFormat.format(summary.totalMonthly), color: AppTheme.neonBlue),
                  const SizedBox(width: 12),
                  _StatChip(icon: Icons.percent, label: 'Taxa Média', value: '${summary.avgRate.toStringAsFixed(2)}%', color: AppTheme.neonOrange),
                ],
              ),
            ),
          const SizedBox(height: 24),

          const Text('Seus Contratos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSilver)),
          const SizedBox(height: 12),

          ...list.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Hero(
              tag: 'financing_card_${f.id}',
              child: Material(
                type: MaterialType.transparency,
                child: FinancingCardWidget(financing: f, onTap: () => onSelect(f.id)),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// VIEW: DETALHES DO FINANCIAMENTO (Com Deletar)
// ---------------------------------------------------------------------------
class _FinancingDetailView extends StatelessWidget {
  final Financing financing;
  final VoidCallback onBack;

  const _FinancingDetailView({required this.financing, required this.onBack});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text("Excluir Financiamento?", style: TextStyle(color: AppTheme.textWhite)),
        content: const Text("Essa ação é irreversível. Todo o histórico de pagamentos será perdido.", style: TextStyle(color: AppTheme.textSilver)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: AppTheme.textSilver))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Fecha Dialog
              final user = Provider.of<AuthProvider>(context, listen: false).user;
              final controller = Provider.of<FinancingController>(context, listen: false);
              
              if (user != null) {
                final success = await controller.delete(user.token!, user.id, financing.id);
                if (success && context.mounted) {
                  KontaSnack.show(context, title: "Excluído", message: "Financiamento removido.");
                  onBack(); // Volta para a lista
                } else if (context.mounted) {
                  KontaSnack.show(context, type: KontaSnackType.error, title: "Erro", message: controller.error ?? "Falha ao excluir");
                }
              }
            }, 
            child: const Text("Excluir", style: TextStyle(color: AppTheme.neonRed, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.chevron_left, color: AppTheme.textWhite), onPressed: onBack),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(financing.title, style: const TextStyle(color: AppTheme.textWhite, fontSize: 16)),
        centerTitle: true,
        actions: [
          // Botão de Deletar
          IconButton(
            onPressed: () => _confirmDelete(context), 
            icon: const Icon(Icons.delete_outline, color: AppTheme.neonRed)
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Hero(
              tag: 'financing_card_${financing.id}',
              child: Material(
                type: MaterialType.transparency,
                child: FinancingCardWidget(financing: financing, isSelected: true, onTap: () {}),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _SummaryStatCard(label: 'Parcela', value: currencyFormat.format(financing.currentInstallmentValue), color: AppTheme.neonBlue)),
                const SizedBox(width: 12),
                Expanded(child: _SummaryStatCard(label: 'Restantes', value: '${financing.remainingInstallments}x', color: AppTheme.textWhite)),
              ],
            ),
            const SizedBox(height: 20),

            AmortizationCalculatorWidget(financing: financing),
            const SizedBox(height: 20),

            AmortizationTableWidget(financing: financing),
          ],
        ),
      ),
    );
  }
}

// Widgets Auxiliares (Mesmos de antes)
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderDark)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSilver))]),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
      ]),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryStatCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderDark)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSilver)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}