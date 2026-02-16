import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart';

// Widgets Globais e Compartilhados
import 'package:konta_app/widgets/app_drawer.dart';
// IMPORTANTE: Importe o Skeleton que criamos
import 'package:konta_app/features/dashboard/presentation/widgets/dashboard_skeleton_view.dart';

// Widgets do Dashboard
import 'package:konta_app/modules/dashboard/widgets/balance_card_widget.dart';
import 'package:konta_app/modules/dashboard/widgets/DashboardHeader.dart';
import 'package:konta_app/modules/dashboard/widgets/pie_chart_widget.dart';
import 'package:konta_app/modules/dashboard/widgets/RecentTransactionsList.dart';
import 'package:konta_app/modules/dashboard/widgets/finance_summary_card.dart';

// Módulos
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/auth/login_page.dart';
import 'package:konta_app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:konta_app/modules/expenses/pages/variable_expenses_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Injeção de Dependência isolada
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
    // Executa após o primeiro frame para evitar erros de build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  // Método isolado para buscar dados (Clean Code)
  Future<void> _loadDashboardData() async {
    // Verificação de segurança: O widget ainda está na árvore?
    if (!mounted) return;
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;

    // Redirecionamento de segurança se não houver usuário
    if (user?.token == null) {
      if (mounted) { // Check duplo por causa do async gap
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
      return;
    }

    final now = DateTime.now();
    
    // A chamada ao provider deve ser segura
    await Provider.of<DashboardController>(context, listen: false)
        .fetchDashboard(user!.token!, mes: now.month, ano: now.year);
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppTheme.borderDark)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.borderDark, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text("Adicionar Novo", style: TextStyle(color: AppTheme.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Botão Receita
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.neonGreen.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_upward, color: AppTheme.neonGreen),
              ),
              title: const Text('Nova Receita', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Salário, investimentos, extras...', style: TextStyle(color: AppTheme.textSilver)),
              onTap: () {
                Navigator.pop(context);
                // Navegação futura aqui
              },
            ),
            const Divider(color: AppTheme.borderDark),
            
            // Botão Despesa
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.neonRed.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_downward, color: AppTheme.neonRed),
              ),
              title: const Text('Nova Despesa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Contas, mercado, lazer...', style: TextStyle(color: AppTheme.textSilver)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VariableExpensesPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listeners
    final user = Provider.of<AuthProvider>(context).user;
    final dashController = Provider.of<DashboardController>(context);

    // Fail-fast para Auth
    if (user == null) {
      return const SizedBox(); 
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      drawer: const AppDrawer(),
      appBar: DashboardHeader(userName: user.nome),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        backgroundColor: AppTheme.neonGreen,
        shape: const CircleBorder(),
        elevation: 10,
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),

      // AnimatedSwitcher
      // Troca suavemente entre o Skeleton e o Conteúdo Real
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: dashController.isLoading
            ? const DashboardSkeletonView() // SEU NOVO SKELETON
            : RefreshIndicator(
                color: AppTheme.neonGreen,
                backgroundColor: AppTheme.surface,
                onRefresh: _loadDashboardData, // Chama o método seguro criado acima
                // Conteúdo extraído para manter o build limpo
                child: _DashboardSuccessView( 
                  controller: dashController,
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// VIEW PRIVADA: Só desenha quando tem dados (Separation of Concerns)
// ---------------------------------------------------------------------------
class _DashboardSuccessView extends StatelessWidget {
  final DashboardController controller;

  const _DashboardSuccessView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final resumo = controller.data?.resumo;
    final saldo = resumo?.saldoAtual ?? 0;
    final receitas = resumo?.receitas ?? 0;
    final despesas = resumo?.despesas ?? 0;
    final graficos = controller.data?.graficos ?? [];
    final transacoes = controller.data?.transacoes ?? [];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          
          // 1. CARD PRINCIPAL
          BalanceCardWidget(
            saldoTotal: saldo,
            receitasMes: receitas,
            despesasMes: despesas,
          ),

          const SizedBox(height: 24),

          // 2. CARDS DE RESUMO
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

          // 3. GRÁFICO
          if (graficos.isNotEmpty)
            PieChartWidget(dados: graficos),

          const SizedBox(height: 32),

          // 4. LISTA DE TRANSAÇÕES
          RecentTransactionsList(
            transactions: transacoes,
            onViewAllTap: () {
              // Navegar para extrato
            },
          ),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}