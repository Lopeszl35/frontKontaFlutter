import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart';
// Widgets Globais
import 'package:konta_app/widgets/app_drawer.dart';
import 'package:konta_app/widgets/finance_card.dart';
// Módulos
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/auth/login_page.dart';
import 'package:konta_app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:konta_app/modules/dashboard/widgets/pie_chart_widget.dart';
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
        Provider.of<DashboardController>(context, listen: false)
            .fetchDashboard(auth.user!.token!, mes: 1, ano: 2026);
      }
    });
  }

  // --- WIDGET DE BOTÃO NEON GLASS ---
  Widget _buildHeaderButton({
    required IconData icon, 
    required String label, 
    required Color color, // Cor do tema (Verde/Vermelho)
    required VoidCallback onTap
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            // Fundo translúcido na cor do botão
            color: color.withValues(alpha: 0.15), 
            borderRadius: BorderRadius.circular(12),
            // Borda fina e sólida na cor do botão
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
            // Brilho sutil
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(
                label, 
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5
                )
              ),
            ],
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

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textWhite),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Olá, ${user.nome.split(' ')[0]}', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textWhite)),
            Text('Resumo financeiro', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSilver)),
          ],
        ),
      ),
      body: dashController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppTheme.primaryModern,
              backgroundColor: AppTheme.surface,
              onRefresh: () async {
                if (user.token != null) await dashController.fetchDashboard(user.token!, mes: 1, ano: 2026);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   const SizedBox(height: 20),
                    // --- 1. CARD PRINCIPAL (SALDO) COM BOTÕES DESTAQUE ---
                    FinanceCard(
                      title: 'Saldo Atual',
                      value: Formatters.formatMoney(dashController.data?.resumo.saldoAtual ?? 0),
                      icon: Icons.account_balance_wallet,
                      color: AppTheme.primaryModern,
                      isPrincipal: true,
                      actions: [
                        // Botão Receita (Verde Neon)
                        _buildHeaderButton(
                          icon: Icons.arrow_upward, 
                          label: "Receita", 
                          color: AppTheme.neonGreen,
                          onTap: () {
                             // Navegar para add receita
                          }
                        ),
                        // Botão Despesa (Vermelho Neon)
                        _buildHeaderButton(
                          icon: Icons.arrow_downward, 
                          label: "Despesa", 
                          color: AppTheme.neonRed,
                          onTap: () {
                             Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VariableExpensesPage()));
                          }
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // --- 2. ENTRADAS E SAÍDAS ---
                    Row(
                      children: [
                        Expanded(
                          child: FinanceCard(
                            title: 'Entradas',
                            value: Formatters.formatMoney(dashController.data?.resumo.receitas ?? 0),
                            icon: Icons.arrow_upward_rounded,
                            color: AppTheme.neonGreen,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FinanceCard(
                            title: 'Saídas',
                            value: Formatters.formatMoney(dashController.data?.resumo.despesas ?? 0),
                            icon: Icons.arrow_downward_rounded,
                            color: AppTheme.neonRed,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // --- 3. GRÁFICO DE PIZZA ---
                    if (dashController.data != null && dashController.data!.graficos.isNotEmpty)
                      PieChartWidget(dados: dashController.data!.graficos)
                    else 
                      const Center(child: Text("Sem dados gráficos", style: TextStyle(color: AppTheme.textSilver))),

                    const SizedBox(height: 32),

                    // --- 4. LISTA DE TRANSAÇÕES ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Transações Recentes", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                          InkWell(
                            onTap: (){},
                            child: const Text("Ver todas", style: TextStyle(color: AppTheme.primaryModern, fontWeight: FontWeight.bold))
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (dashController.data?.transacoes.isEmpty ?? true)
                      const Padding(padding: EdgeInsets.all(16.0), child: Center(child: Text("Nenhuma transação recente.", style: TextStyle(color: AppTheme.textSilver))))
                    else
                      ...dashController.data!.transacoes.map((transacao) {
                        return _buildTransactionItem(
                          context,
                          transacao.titulo,
                          transacao.categoria,
                          transacao.tipo == 'despesa' ? -transacao.valor : transacao.valor,
                          transacao.tipo == 'receita' ? Icons.arrow_upward : Icons.shopping_bag_outlined,
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, String title, String category, double value, IconData icon) {
    final isNegative = value < 0;
    final color = isNegative ? AppTheme.neonRed : AppTheme.neonGreen;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.inputDark, borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: AppTheme.textWhite, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textWhite)),
                  const SizedBox(height: 4),
                  Text(category, style: const TextStyle(color: AppTheme.textSilver, fontSize: 12)),
                ],
              ),
            ],
          ),
          Text(Formatters.formatMoney(value), style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
        ],
      ),
    );
  }
}