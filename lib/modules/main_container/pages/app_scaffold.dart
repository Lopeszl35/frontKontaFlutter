import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';

// Páginas
import 'package:konta_app/modules/dashboard/pages/dashboard_page.dart'; 
// Supondo que você já tenha criado a tela de Extrato com o código anterior, importe-a. 
// Se não, mantenha o placeholder.
// import 'package:konta_app/modules/transactions/pages/transactions_page.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentIndex = 0;

  // 1. Chave para controlar a navegação interna da aba Início
  final GlobalKey<NavigatorState> _dashboardNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    // 2. PopScope controla o botão "Voltar" do Android
    return PopScope(
      canPop: false, // Gerenciamos o pop manualmente
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Se estiver na aba Início e houver telas empilhadas (ex: Gastos Variáveis), volta uma tela
        if (_currentIndex == 0 && _dashboardNavigatorKey.currentState!.canPop()) {
          _dashboardNavigatorKey.currentState!.pop();
          return;
        }

        // Se não houver nada para voltar, fecha o app ou minimiza (padrão do sistema)
        // Aqui permitimos fechar se estiver na raiz
        if (context.mounted) {
           Navigator.of(context).pop(); 
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        
        // 3. O corpo agora usa IndexedStack para manter o estado
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // --- ABA 0: INÍCIO (COM NAVEGAÇÃO INTERNA) ---
            // Isso permite que 'Gastos Variáveis' abra mantendo o menu
            Navigator(
              key: _dashboardNavigatorKey,
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => const DashboardPage(),
                );
              },
            ),

            // --- ABA 1: EXTRATO ---
            // Se esta tela também tiver navegação interna, precisará de um Navigator igual acima
            const _PlaceholderScreen(title: "Extrato", icon: Icons.receipt_long), 
            // const TransactionsPage(), // Use esta linha quando criar o arquivo do extrato

            // --- ABA 2: NEXO (IA) ---
            const _PlaceholderScreen(title: "Nexo AI", icon: Icons.auto_awesome),

            // --- ABA 3: INVESTIR ---
            const _PlaceholderScreen(title: "Investir", icon: Icons.show_chart),

            // --- ABA 4: APRENDER ---
            const _PlaceholderScreen(title: "Aprender", icon: Icons.school),
          ],
        ),

        // --- MENU INFERIOR (SEMPRE VISÍVEL) ---
        bottomNavigationBar: Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: const Border(top: BorderSide(color: AppTheme.borderDark, width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, -5),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, "Início"),
                _buildNavItem(1, Icons.receipt_long_rounded, "Extrato"),
                _buildCentralAiButton(),
                _buildNavItem(3, Icons.show_chart_rounded, "Investir"),
                _buildNavItem(4, Icons.school_rounded, "Aprender"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.neonGreen : AppTheme.textSilver;

    return InkWell(
      onTap: () {
        // Se clicar na aba que já está ativa, volta para a raiz daquela aba
        if (_currentIndex == index && index == 0) {
          _dashboardNavigatorKey.currentState?.popUntil((route) => route.isFirst);
        }
        setState(() => _currentIndex = index);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color, 
                fontSize: 10, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCentralAiButton() {
    final isSelected = _currentIndex == 2;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        width: 60, height: 60,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected 
              ? [AppTheme.neonGreen, const Color(0xFF22c55e)] 
              : [const Color(0xFF2A2A2A), const Color(0xFF1A1A1A)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonGreen.withValues(alpha: isSelected ? 0.4 : 0.0),
              blurRadius: 15,
              spreadRadius: 1,
            )
          ],
          border: Border.all(
            color: isSelected ? Colors.white.withValues(alpha: 0.5) : AppTheme.borderDark,
            width: 1
          )
        ),
        child: Icon(
          Icons.auto_awesome,
          color: isSelected ? Colors.black : AppTheme.neonGreen,
          size: 28,
        ),
      ),
    );
  }
}

// Widget Placeholder para as telas que ainda não existem
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppTheme.textSilver.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: AppTheme.textWhite, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Em breve", style: TextStyle(color: AppTheme.neonGreen)),
        ],
      ),
    );
  }
}