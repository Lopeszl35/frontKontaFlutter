import 'package:flutter/foundation.dart'; // Necessário para kReleaseMode
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  // 🔒 URL DE PRODUÇÃO (Segurança Máxima)
  // Definida aqui para garantir que o APK de loja NUNCA tente acessar um IP local.
  static const String _prodUrl = "https://api.nexor.app"; 

  static String get apiUrl {
    // 1. CHECAGEM DE SEGURANÇA (Modo Release)
    // Se o app foi compilado com 'flutter run --release' ou 'flutter build apk',
    // ele ignora o .env local e retorna a URL de produção.
    if (kReleaseMode) {
      return _prodUrl; 
    }

    // 2. MODO DESENVOLVIMENTO (Debug)
    // Tenta ler a variável do arquivo .env
    final url = dotenv.env['API_BASE_URL'];
    
    // Validação do .env
    if (url == null || url.isEmpty) {
      // debugPrint é melhor que print (só aparece em debug e não spama logs de produção)
      debugPrint("⚠️ AVISO CRÍTICO: .env não carregado ou variável vazia. Usando fallback.");
      
      // Fallback para seu IP local (Útil se o arquivo .env falhar)
      return 'http://192.168.1.4:8080'; 
    }
    
    return url;
  }
}