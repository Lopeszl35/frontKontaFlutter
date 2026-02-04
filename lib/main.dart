import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // carrega variáveis de ambiente
import 'package:provider/provider.dart'; 
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/modules/auth/login_page.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';

// Transformamos o main em async para carregar configurações antes do app abrir
void main() async {
  // 1. Garante que o motor do Flutter está pronto
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Tenta carregar o arquivo .env
  try {
    await dotenv.load(fileName: ".env");
    print("✅ Variáveis de ambiente carregadas!");
  } catch (e) {
    print("⚠️ Atenção: Arquivo .env não encontrado. Usando configurações padrão.");
  }

  runApp(
    // Injeção de Dependência
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const KontaApp(),
    ),
  );
}

class KontaApp extends StatelessWidget {
  const KontaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Konta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}