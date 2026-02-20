import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/auth/login_page.dart';
import 'package:konta_app/modules/dashboard/pages/dashboard_page.dart';
import 'package:konta_app/modules/expenses/pages/variable_expenses_page.dart';
import 'package:konta_app/modules/creditCards/pages/credit_cards_screen.dart';
import 'package:konta_app/modules/financings/pages/financings_screen.dart';
import 'package:konta_app/modules/expenses/pages/fixed_expenses_page.dart';
import 'package:konta_app/modules/reminders/pages/payment_reminders_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    const version = "v1.0.0 (Beta)"; // Idealmente viria do package_info_plus

    return Drawer(
      backgroundColor: AppTheme.background, // Fundo escuro total para imersão
      child: Column(
        children: [
          // --- 1. CABEÇALHO CUSTOMIZADO (PREMIUM) ---
          _buildCustomHeader(user),

          // --- 2. LISTA DE NAVEGAÇÃO ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              children: [
                _buildSectionTitle("Visão Geral"),
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: "Dashboard",
                  color: Colors.white,
                  onTap: () => _navigate(context, const DashboardPage()),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle("Gestão Financeira"),
                
                _buildMenuItem(
                  context,
                  icon: Icons.pie_chart_outline_rounded,
                  title: "Gastos Variáveis",
                  color: AppTheme.neonOrange,
                  onTap: () => _navigate(context, const VariableExpensesPage()),
                ),

                 _buildMenuItem(
                  context,
                  icon: Icons.event_repeat_outlined,
                  title: "Lembretes de Pagamento",
                  color: Colors.deepOrange,
                  onTap: () => _navigate(context, const PaymentRemindersPage()),
                ),
                
                _buildMenuItem(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  title: "Receitas",
                  color: AppTheme.neonGreen,
                  onTap: () {
                    // TODO: Navegar para Receitas
                    Navigator.pop(context);
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.vpn_key_outlined,
                  title: "Financiamentos",
                  color: AppTheme.neonBlue,
                  onTap: () => _navigate(context, const FinancingsScreen()),
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.credit_card_outlined,
                  title: "Cartões de Crédito",
                  color: Colors.purpleAccent,
                  onTap: () => _navigate(context, const CreditCardsScreen()),
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.event_repeat_outlined,
                  title: "Gastos Fixos",
                  color: Colors.deepOrange,
                  onTap: () => _navigate(context, const FixedExpensesPage()),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle("Sistema"),

                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: "Configurações",
                  color: AppTheme.textSilver,
                  onTap: () {
                    // TODO: Configurações
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // --- 3. RODAPÉ (LOGOUT + VERSÃO) ---
          _buildFooter(context, version),
        ],
      ),
    );
  }

  // Helper para navegação limpa
  void _navigate(BuildContext context, Widget page) {
    Navigator.pop(context); // Fecha o drawer
    // Usa pushReplacement se for Dashboard para não empilhar, push normal para outros
    if (page is DashboardPage) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => page));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    }
  }

  Widget _buildCustomHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(bottom: BorderSide(color: AppTheme.borderDark)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Avatar com Borda Gradiente
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.premiumGradient, // Borda premium
            ),
            child: CircleAvatar(
              radius: 28,
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
          ),
          const SizedBox(width: 16),
          // Info do Usuário
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user?.nome ?? "Usuário",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textWhite,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? "email@konta.com",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSilver,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Badge "Free" ou "Pro" (Placeholder para monetização futura)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.inputDark,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: const Text(
                    "PLANO FREE",
                    style: TextStyle(fontSize: 10, color: AppTheme.textSilver, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.textSilver.withValues(alpha: 0.5),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {
    required IconData icon,
    required String title,
    required Color color, // Cor semântica obrigatória
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Efeito visual no toque
        splashColor: color.withValues(alpha: 0.1), 
        
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), // Fundo "Neon Glow"
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: Icon(Icons.chevron_right, size: 18, color: AppTheme.textSilver.withValues(alpha: 0.5)),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, String version) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderDark)),
        color: AppTheme.surface,
      ),
      child: Column(
        children: [
          // Botão Sair com estilo de alerta
          InkWell(
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.neonRed.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.neonRed.withValues(alpha: 0.05),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20, color: AppTheme.neonRed),
                  SizedBox(width: 8),
                  Text(
                    "Sair da Conta",
                    style: TextStyle(
                      color: AppTheme.neonRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Konta App $version",
            style: TextStyle(color: AppTheme.textSilver.withValues(alpha: 0.4), fontSize: 11),
          ),
        ],
      ),
    );
  }
}