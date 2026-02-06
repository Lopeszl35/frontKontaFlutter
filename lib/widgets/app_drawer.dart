import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/auth/login_page.dart';
import 'package:konta_app/modules/dashboard/pages/dashboard_page.dart';
import 'package:konta_app/modules/expenses/pages/variable_expenses_page.dart';
import 'package:konta_app/modules/creditCards/pages/credit_cards_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Drawer(
      backgroundColor: AppTheme.surface, 
      child: Column(
        children: [
          // --- 1. CABEÇALHO ---
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppTheme.premiumGradient,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.background,
              child: Text(
                user?.nome.substring(0, 1).toUpperCase() ?? "U",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
              ),
            ),
            accountName: Text(
              user?.nome ?? "Usuário",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textWhite),
            ),
            accountEmail: Text(
              user?.email ?? "email@konta.com",
              style: const TextStyle(color: AppTheme.textSilver),
            ),
          ),

          // --- 2. ITENS DE NAVEGAÇÃO ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: "Dashboard",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const DashboardPage()),
                    );
                  },
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.pie_chart_outline_rounded,
                  title: "Gastos Variáveis",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VariableExpensesPage()),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Receitas",
                  onTap: () {
                      Navigator.pop(context);
                      // TODO: Navegar para Receitas
                  },
                ),

                 _buildMenuItem(
                  context,
                  icon: Icons.credit_card_outlined,
                  title: "Cartões de crédito",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreditCardsScreen()),
                    );
                  },
                ),

                
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Divider(color: AppTheme.borderDark),
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: "Configurações",
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navegar para Configurações
                  },
                ),
              ],
            ),
          ),

          // --- 3. BOTÃO DE SAIR (Rodapé) ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: AppTheme.borderDark),
          ),
          
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            // Ícone de Sair com container Vermelho Translúcido
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.neonRed.withValues(alpha: 0.1), // Fundo vermelho suave
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neonRed.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.logout, color: AppTheme.neonRed, size: 20),
            ),
            title: const Text(
              "Sair da conta",
              style: TextStyle(
                color: AppTheme.neonRed,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- WIDGET AUXILIAR COM BORDA ARREDONDA ---
  Widget _buildMenuItem(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      // AQUI ESTÁ A MUDANÇA: Container em volta do ícone
      leading: Container(
        padding: const EdgeInsets.all(10), // Espaço interno
        decoration: BoxDecoration(
          color: AppTheme.inputDark, // Fundo do ícone (Slate mais escuro)
          borderRadius: BorderRadius.circular(12), // Borda Arredondada
          border: Border.all(color: AppTheme.borderDark), // Borda fina
        ),
        child: Icon(icon, color: AppTheme.textSilver, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textWhite,
          fontWeight: FontWeight.w500,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      hoverColor: AppTheme.primaryModern.withValues(alpha: 0.1),
      onTap: onTap,
    );
  }
}