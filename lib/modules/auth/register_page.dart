import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/dashboard/pages/dashboard_page.dart';
import 'package:konta_app/core/utils/konta_snack.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _salaryController = TextEditingController();
  final _balanceController = TextEditingController(); 
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Perfil Financeiro (Dropdown)
  String _selectedProfile = 'moderado'; // Valor padrão
  final List<String> _perfis = ['conservador', 'moderado', 'agressivo'];

  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); 

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      double cleanMoney(String text) {
        return double.tryParse(text.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
      }

      try {
        await authProvider.register(
          nome: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          salario: cleanMoney(_salaryController.text),
          saldoAtual: cleanMoney(_balanceController.text),
          perfil: _selectedProfile,
        );

        if (!mounted) return;

        KontaSnack.show(
          context,
          type: KontaSnackType.success,
          title: "Bem-vindo ao Konta!",
          message: "Sua conta foi criada com sucesso.",
        );

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
          (route) => false,
        );

      } catch (e) {
        if (!mounted) return;
        KontaSnack.show(
          context,
          type: KontaSnackType.error,
          title: "Ops, algo deu errado",
          message: e.toString().replaceAll("Exception: ", ""), 
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background, // DARK VOID
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER CURVADO (PREMIUM GRADIENT) ---
            Container(
              height: 180, // Compacto e elegante
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTheme.premiumGradient, // Aurora
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))
                ]
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 50,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Nova Conta",
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- FORMULÁRIO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // NOME
                    _buildModernInput(
                      controller: _nameController,
                      label: "Nome Completo",
                      icon: Icons.person_outline
                    ),
                    const SizedBox(height: 16),
                    
                    // EMAIL
                    _buildModernInput(
                      controller: _emailController, 
                      label: "E-mail", 
                      icon: Icons.email_outlined, 
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => !v!.contains('@') ? 'E-mail inválido' : null
                    ),
                    const SizedBox(height: 16),
                    
                    // SALÁRIO E SALDO (Lado a Lado)
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernInput(
                            controller: _salaryController, 
                            label: "Salário (R\$)", 
                            icon: Icons.attach_money, 
                            keyboardType: TextInputType.number
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildModernInput(
                            controller: _balanceController, 
                            label: "Saldo (R\$)", 
                            icon: Icons.account_balance_wallet_outlined, 
                            keyboardType: TextInputType.number
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // PERFIL FINANCEIRO (Dropdown Estilizado Dark)
                    DropdownButtonFormField<String>(
                      value: _selectedProfile,
                      dropdownColor: AppTheme.surface, // Menu escuro
                      style: const TextStyle(color: AppTheme.textWhite),
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSilver),
                      decoration: InputDecoration(
                        labelText: "Perfil Financeiro",
                        labelStyle: const TextStyle(color: AppTheme.textSilver),
                        prefixIcon: const Icon(Icons.psychology_outlined, color: AppTheme.textSilver),
                        filled: true,
                        fillColor: AppTheme.inputDark,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppTheme.borderDark)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryModern, width: 2)),
                      ),
                      items: _perfis.map((String perfil) {
                        return DropdownMenuItem<String>(
                          value: perfil,
                          child: Text(
                            perfil[0].toUpperCase() + perfil.substring(1),
                            style: const TextStyle(color: AppTheme.textWhite),
                          ), 
                        );
                      }).toList(),
                      onChanged: (newValue) => setState(() => _selectedProfile = newValue!),
                    ),
                    
                    const SizedBox(height: 16),

                    // SENHA
                    _buildModernInput(
                      controller: _passwordController, 
                      label: "Senha", 
                      icon: Icons.lock_outline, 
                      isPassword: true, 
                      validator: (v) => v!.length < 6 ? 'Min. 6 caracteres' : null
                    ),
                    const SizedBox(height: 16),

                    // CONFIRMAR SENHA
                    _buildModernInput(
                      controller: _confirmPasswordController, 
                      label: "Confirmar Senha", 
                      icon: Icons.verified_user_outlined, 
                      isPassword: true,
                      validator: (v) => v != _passwordController.text ? 'Senhas diferentes' : null
                    ),

                    const SizedBox(height: 32),

                    // BOTÃO CRIAR CONTA
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryModern, // Roxo Digital
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              shadowColor: AppTheme.primaryModern.withValues(alpha: 0.4),
                            ),
                            child: auth.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "CRIAR CONTA",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                                  ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    
                    // RODAPÉ: KONTA BY NEXOR
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Konta By ", style: TextStyle(color: AppTheme.textSilver)),
                          Text(
                            "Nexor", 
                            style: TextStyle(
                              color: AppTheme.primaryModern.withValues(alpha: 0.8), 
                              fontWeight: FontWeight.bold
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Input Moderno Reutilizável (Versão Dark)
  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      validator: validator ?? (v) => v!.isEmpty ? 'Campo obrigatório' : null,
      style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSilver),
        prefixIcon: Icon(icon, color: AppTheme.textSilver),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.textSilver,
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: AppTheme.inputDark, // Fundo Escuro
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryModern, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.neonRed, width: 1),
        ),
      ),
    );
  }
}