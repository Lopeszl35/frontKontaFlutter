import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart';
// Widgets Globais
import 'package:konta_app/widgets/app_drawer.dart';
import 'package:konta_app/modules/dashboard/widgets/finance_card.dart'; // Card Grande
// Widgets do Dashboard
import 'package:konta_app/modules/dashboard/widgets/DashboardHeader.dart';
import 'package:konta_app/modules/dashboard/widgets/pie_chart_widget.dart';
import 'package:konta_app/modules/dashboard/widgets/RecentTransactionsList.dart';
import 'package:konta_app/modules/dashboard/widgets/finance_summary_card.dart'; // Novos Cards Pequenos
// Módulos
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user?.token != null) {
        final now = DateTime.now();
        Provider.of<DashboardController>(context, listen: false)
            .fetchDashboard(auth.user!.token!, mes: now.month, ano: now.year);
      }
    });
  }

  // Botões de ação do Card Principal
  Widget _buildActionButton({
    required IconData icon, 
    required String label, 
    required Color color, 
    required VoidCallback onTap
  }) {
    return Expanded( 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 15),
                  const SizedBox(width: 8),
                  Text(
                    label, 
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 13, 
                      fontWeight: FontWeight.w600
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final dashController = Provider.of<DashboardController>(context);

    if (user == null) {
      Future.microtask(() => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage())));
      return const SizedBox();
    }

    final resumo = dashController.data?.resumo;
    final saldo = resumo?.saldoAtual ?? 0;
    final receitas = resumo?.receitas ?? 0;
    final despesas = resumo?.despesas ?? 0;
    final graficos = dashController.data?.graficos ?? [];
    final transacoes = dashController.data?.transacoes ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const AppDrawer(),
      appBar: DashboardHeader(userName: user.nome),
      
      body: dashController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppTheme.primaryModern,
              backgroundColor: AppTheme.surface,
              onRefresh: () async {
                if (user.token != null) {
                  final now = DateTime.now();
                  await dashController.fetchDashboard(user.token!, mes: now.month, ano: now.year);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    
                    // 1. CARD PRINCIPAL (SALDO)
                    FinanceCard(
                      title: 'Saldo Atual',
                      value: Formatters.formatMoney(saldo),
                      icon: Icons.account_balance_wallet,
                      color: AppTheme.primaryModern,
                      isPrincipal: true,
                      actions: [
                        _buildActionButton(
                          icon: Icons.arrow_upward, 
                          label: "Receita", 
                          color: AppTheme.neonGreen,
                          onTap: () { /* Navegar */ }
                        ),
                        _buildActionButton(
                          icon: Icons.arrow_downward, 
                          label: "Despesa", 
                          color: AppTheme.neonRed,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VariableExpensesPage())),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24), // Espaçamento maior

                    // 2. NOVOS CARDS DE RESUMO
                    Row(
                      children: [
                        Expanded(
                          child: FinanceSummaryCard(
                            title: 'Entradas',
                            value: Formatters.formatMoney(receitas),
                            icon: Icons.arrow_upward_rounded,
                            color: AppTheme.neonGreen,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FinanceSummaryCard(
                            title: 'Saídas',
                            value: Formatters.formatMoney(despesas),
                            icon: Icons.arrow_downward_rounded,
                            color: AppTheme.neonRed,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // 3. GRÁFICO (Novo design limpo)
                    if (graficos.isNotEmpty)
                      PieChartWidget(dados: graficos),

                    const SizedBox(height: 32),

                    // 4. LISTA DE TRANSAÇÕES (Novo design com ícones)
                    RecentTransactionsList(
                      transactions: transacoes,
                      onViewAllTap: () {
                        // Navegar para extrato
                      },
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}