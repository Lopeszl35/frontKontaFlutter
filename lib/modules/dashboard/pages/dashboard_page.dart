import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para Haptics
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';

// Widgets
import 'package:konta_app/widgets/app_drawer.dart';
import 'package:konta_app/features/dashboard/presentation/widgets/dashboard_skeleton_view.dart';
import 'package:konta_app/modules/dashboard/widgets/balance_card_widget.dart';
import 'package:konta_app/modules/dashboard/widgets/pie_chart_widget.dart';
import 'package:konta_app/modules/dashboard/widgets/RecentTransactionsList.dart';
import 'package:konta_app/modules/dashboard/widgets/finance_summary_card.dart';

// Controllers & Auth
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/auth/login_page.dart';
import 'package:konta_app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:konta_app/modules/expenses/pages/variable_expenses_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardController(),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  const _DashboardContent();
  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  // Controle de privacidade (Olho)
  final ValueNotifier<bool> _showValues = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDashboardData());
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;

    if (user?.token == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
      return;
    }

    final now = DateTime.now();
    await Provider.of<DashboardController>(context, listen: false)
        .fetchDashboard(user!.token!, mes: now.month, ano: now.year);
  }

  void _showAddOptions(BuildContext context) {
    HapticFeedback.mediumImpact(); // Feedback Tátil
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Transparente para ver o glass
      builder: (context) => _buildGlassBottomSheet(context),
    );
  }

  // BottomSheet com visual fosco (Glassmorphism)
  Widget _buildGlassBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textSilver.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          const Text("Nova Movimentação", style: TextStyle(color: AppTheme.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          _buildActionTile(
            context, 
            icon: Icons.arrow_upward, 
            color: AppTheme.neonGreen, 
            title: "Nova Receita", 
            subtitle: "Salário, investimentos...", 
            onTap: () { /* Navegar */ }
          ),
          const Divider(color: AppTheme.borderDark, height: 32),
          _buildActionTile(
            context, 
            icon: Icons.arrow_downward, 
            color: AppTheme.neonRed, 
            title: "Nova Despesa", 
            subtitle: "Mercado, contas, lazer...", 
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VariableExpensesPage()));
            }
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSilver, fontSize: 13)),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSilver),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final dashController = Provider.of<DashboardController>(context);

    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const AppDrawer(),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        backgroundColor: AppTheme.neonGreen,
        elevation: 0, // Flat design
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), // Squircle (Apple style)
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),

      // MUDANÇA PRINCIPAL: CustomScrollView
      body: dashController.isLoading
          ? const DashboardSkeletonView()
          : ValueListenableBuilder<bool>(
              valueListenable: _showValues,
              builder: (context, showValues, child) {
                return RefreshIndicator(
                  color: AppTheme.neonGreen,
                  backgroundColor: AppTheme.surface,
                  edgeOffset: 100, // Ajuste para Sliver
                  onRefresh: _loadDashboardData,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(), // Efeito elástico (iOS)
                    slivers: [
                      // 1. App Bar que expande/contrai
                      _buildSliverAppBar(user.nome, showValues),

                      // 2. Conteúdo com Adapter
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _DashboardBody(
                            controller: dashController,
                            showValues: showValues,
                          ),
                        ),
                      ),
                      
                      // Espaço extra para o FAB não cobrir conteúdo
                      const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                    ],
                  ),
                );
              },
            ),
    );
  }

  SliverAppBar _buildSliverAppBar(String userName, bool showValues) {
    final firstName = userName.split(' ')[0];
    return SliverAppBar(
      backgroundColor: AppTheme.background,
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppTheme.textWhite),
      actions: [
        // Botão de Privacidade
        IconButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            _showValues.value = !_showValues.value;
          },
          icon: Icon(
            showValues ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppTheme.textSilver,
          ),
        ),
        const SizedBox(width: 8),
        // Avatar clicável
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.inputDark,
            child: Text(
              firstName[0].toUpperCase(),
              style: const TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'Olá, $firstName',
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 20, // O Sliver vai animar o tamanho da fonte
          ),
        ),
      ),
    );
  }
}

// Corpo separado para organização
class _DashboardBody extends StatelessWidget {
  final DashboardController controller;
  final bool showValues;

  const _DashboardBody({required this.controller, required this.showValues});

  @override
  Widget build(BuildContext context) {
    final resumo = controller.data?.resumo;
    final saldo = resumo?.saldoAtual ?? 0;
    final receitas = resumo?.receitas ?? 0;
    final despesas = resumo?.despesas ?? 0;
    final graficos = controller.data?.graficos ?? [];
    final transacoes = controller.data?.transacoes ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        
        // Passamos o estado de privacidade para os widgets
        BalanceCardWidget(
          saldoTotal: saldo,
          receitasMes: receitas,
          despesasMes: despesas,
          showValues: showValues, // Atualize o widget para aceitar isso
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: FinanceSummaryCard(
                title: 'Entradas',
                value: receitas,
                icon: Icons.arrow_upward_rounded,
                color: AppTheme.neonGreen,
                showValues: showValues,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FinanceSummaryCard(
                title: 'Saídas',
                value: despesas,
                icon: Icons.arrow_downward_rounded,
                color: AppTheme.neonRed,
                showValues: showValues,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        if (graficos.isNotEmpty)
          PieChartWidget(dados: graficos),

        const SizedBox(height: 32),

        RecentTransactionsList(
          transactions: transacoes,
          showValues: showValues, 
          onViewAllTap: () {},
        ),
      ],
    );
  }
}