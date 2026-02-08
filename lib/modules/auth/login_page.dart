import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/auth/register_page.dart';
import 'package:konta_app/modules/main_container/pages/app_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final sucesso = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );
      
      if (!mounted) return;

      if (sucesso) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AppScaffold()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Falha no login. Verifique suas credenciais.'),
            backgroundColor: AppTheme.neonRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder nos dá as constraints do pai (tamanho da tela)
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // ConstrainedBox garante altura MÍNIMA da tela, mas deixa crescer se precisar (scroll)
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // --- HEADER CURVADO ---
                    Container(
                      height: 320,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.premiumGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(60),
                          bottomRight: Radius.circular(60),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))
                        ]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryModern.withValues(alpha: 0.5),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                )
                              ]
                            ),
                            child: Image.asset(
                              'assets/images/logo_konta.png',
                              height: 70, 
                              width: 70,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Konta",
                            style: TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Gestão Inteligente",
                            style: TextStyle(color: AppTheme.textSilver.withValues(alpha: 0.8), fontSize: 14, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- FORMULÁRIO ---
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Bem-vindo de volta",
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textWhite,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              _buildModernInput(
                                controller: _emailController,
                                label: "E-mail",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => !v!.contains('@') ? 'E-mail inválido' : null,
                              ),
                              
                              const SizedBox(height: 20),

                              _buildModernInput(
                                controller: _passwordController,
                                label: "Senha",
                                icon: Icons.lock_outline,
                                obscureText: !_isPasswordVisible,
                                isPassword: true,
                                onTogglePassword: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                              ),

                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text("Esqueceu a senha?", style: TextStyle(color: AppTheme.textSilver)),
                                ),
                              ),

                              const SizedBox(height: 32),

                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return SizedBox(
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: auth.isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryModern,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        elevation: 4,
                                        shadowColor: AppTheme.primaryModern.withValues(alpha: 0.4),
                                      ),
                                      child: auth.isLoading
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : const Text(
                                            "ENTRAR",
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                                          ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Não tem uma conta? ", style: TextStyle(color: AppTheme.textSilver)),
                                  GestureDetector(
                                    onTap: () {
                                       Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
                                    },
                                    child: const Text(
                                      "Cadastre-se",
                                      style: TextStyle(
                                        color: AppTheme.neonBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // --- RODAPÉ ---
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Konta By ",
                            style: TextStyle(
                              color: AppTheme.textSilver,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Nexor",
                            style: TextStyle(
                              color: AppTheme.primaryModern.withValues(alpha: 0.8), 
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSilver),
        prefixIcon: Icon(icon, color: AppTheme.textSilver),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.textSilver,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: AppTheme.inputDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.borderDark),
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