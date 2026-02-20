import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/expenses/controllers/fixed_expenses_controller.dart';
import 'package:konta_app/data/models/fixed_expense_model.dart';
import 'package:konta_app/modules/expenses/widgets/add_fixed_expense_modal.dart';

// Configuração visual para mapear o backend 'categoria_exibicao'
class CategoryConfig {
  final IconData icon;
  final Color color;
  const CategoryConfig(this.icon, this.color);
}

final Map<String, CategoryConfig> visualConfigs = {
  'Utilidades': const CategoryConfig(Icons.bolt_rounded, AppTheme.neonOrange),
  'Assinaturas': const CategoryConfig(Icons.subscriptions_rounded, Colors.purpleAccent),
  'Saúde': const CategoryConfig(Icons.favorite_rounded, AppTheme.neonRed),
  'Educação': const CategoryConfig(Icons.school_rounded, AppTheme.neonBlue),
  'Moradia': const CategoryConfig(Icons.home_rounded, AppTheme.neonGreen),
  'Outros': const CategoryConfig(Icons.more_horiz_rounded, AppTheme.textSilver),
};

class FixedExpensesPage extends StatelessWidget {
  const FixedExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FixedExpensesController(),
      child: const _FixedExpensesContent(),
    );
  }
}

class _FixedExpensesContent extends StatefulWidget {
  const _FixedExpensesContent();

  @override
  State<_FixedExpensesContent> createState() => _FixedExpensesContentState();
}

class _FixedExpensesContentState extends State<_FixedExpensesContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      await Provider.of<FixedExpensesController>(context, listen: false).fetchScreenData(user.token!, user.id);
    }
  }

  void _showAddModal(BuildContext context) {
    HapticFeedback.mediumImpact();
    final controller = Provider.of<FixedExpensesController>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: const AddFixedExpenseModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FixedExpensesController>(context);
    final data = controller.screenData;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite), onPressed: () => Navigator.pop(context)),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gastos Fixos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
            Text('Despesas recorrentes', style: TextStyle(fontSize: 12, color: AppTheme.textSilver)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.neonGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showAddModal(context),
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 28),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: controller.isLoading && data == null
            ? const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)) // Troque pelo seu SkeletonWidget
            : RefreshIndicator(
                color: AppTheme.neonGreen,
                backgroundColor: AppTheme.surface,
                onRefresh: _loadData,
                child: data == null
                    ? Center(child: Text(controller.error ?? "Nenhum dado", style: const TextStyle(color: AppTheme.neonRed)))
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          _buildStatCards(data.resumo),
                          const SizedBox(height: 24),
                          _buildCategorySummary(data.gastosPorCategoria),
                          const SizedBox(height: 24),
                          _buildFilterTabs(controller, data.gastosPorCategoria),
                          const SizedBox(height: 16),
                          
                          if (controller.filteredList.isEmpty)
                            const Center(child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("Nenhum gasto encontrado.", style: TextStyle(color: AppTheme.textSilver)),
                            )),

                          ...controller.filteredList.map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _FixedExpenseCard(expense: e, controller: controller),
                              )),
                          const SizedBox(height: 80),
                        ],
                      ),
              ),
      ),
    );
  }

  Widget _buildStatCards(FixedExpenseSummary resumo) {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _StatCard(title: 'Total Mensal', value: Formatters.formatMoney(resumo.totalMensal), subtitle: 'Mês atual', icon: Icons.trending_up_rounded, color: AppTheme.neonBlue),
          const SizedBox(width: 12),
          _StatCard(title: 'Total Anual', value: Formatters.formatMoney(resumo.totalAnual), subtitle: 'Projeção 12 meses', icon: Icons.calendar_today_rounded, color: AppTheme.neonOrange),
          const SizedBox(width: 12),
          _StatCard(title: 'Em 7 dias', value: Formatters.formatMoney(resumo.proximos7DiasTotal), subtitle: '${resumo.proximos7DiasQuantidade} vencimentos', icon: Icons.warning_amber_rounded, color: AppTheme.neonRed),
        ],
      ),
    );
  }

  Widget _buildCategorySummary(List<CategoryTotal> categorias) {
    if (categorias.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.borderDark)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Por Categoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categorias.map((cat) {
              final cfg = visualConfigs[cat.categoria] ?? visualConfigs['Outros']!;
              return Container(
                width: 150,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(color: cfg.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: cfg.color.withValues(alpha: 0.2))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Icon(cfg.icon, size: 14, color: cfg.color), const SizedBox(width: 6), Expanded(child: Text(cat.categoria, style: TextStyle(fontSize: 11, color: cfg.color, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis))]),
                    const SizedBox(height: 8),
                    Text(Formatters.formatMoney(cat.total), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(FixedExpensesController controller, List<CategoryTotal> categorias) {
    final filters = ['all', ...categorias.map((e) => e.categoria)];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final f = filters[i];
          final selected = controller.activeFilter == f;
          final label = f == 'all' ? 'Todas' : f;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              controller.setFilter(f);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppTheme.neonBlue : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? AppTheme.neonBlue : AppTheme.borderDark),
              ),
              child: Text(label, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.bold : FontWeight.normal, color: selected ? Colors.black : AppTheme.textSilver)),
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGETS PRIVADOS ---

class _FixedExpenseCard extends StatelessWidget {
  final FixedExpense expense;
  final FixedExpensesController controller;

  const _FixedExpenseCard({required this.expense, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cfg = visualConfigs[expense.categoriaExibicao] ?? visualConfigs['Outros']!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: expense.ativo ? cfg.color.withValues(alpha: 0.3) : AppTheme.borderDark),
      ),
      child: Opacity(
        opacity: expense.ativo ? 1.0 : 0.4,
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: cfg.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)), child: Icon(cfg.icon, size: 24, color: cfg.color)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text(expense.categoriaExibicao, style: TextStyle(fontSize: 12, color: cfg.color)),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.textSilver, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('Vence dia ${expense.diaVencimento}', style: const TextStyle(fontSize: 12, color: AppTheme.textSilver)),
                  ]),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Formatters.formatMoney(expense.valor), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                const SizedBox(height: 4),
                SizedBox(
                  height: 24, width: 40,
                  child: Switch(
                    value: expense.ativo,
                    activeColor: AppTheme.neonGreen,
                    inactiveTrackColor: AppTheme.inputDark,
                    onChanged: (val) async {
                      HapticFeedback.lightImpact();
                      final user = Provider.of<AuthProvider>(context, listen: false).user;
                      if(user != null) {
                        await controller.toggleExpense(user.token!, user.id, expense.id, expense.ativo);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title; final String value; final String subtitle; final IconData icon; final Color color;
  const _StatCard({required this.title, required this.value, required this.subtitle, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.borderDark)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle), child: Icon(icon, size: 14, color: color)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSilver, fontWeight: FontWeight.w500))]),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textWhite, letterSpacing: -0.5)),
          const SizedBox(height: 2), Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSilver)),
        ],
      ),
    );
  }
}