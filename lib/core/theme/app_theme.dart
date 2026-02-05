import 'package:flutter/material.dart';

class AppTheme {
  // --- PALETA "STEALTH WEALTH" (PRETO & VERDE) ---

  // Fundo: "True Black" (Preto Absoluto para contraste máximo e economia de bateria OLED)
  static const Color background = Color(0xFF000000); 
  
  // Superfície dos Cards: "Carbon" (Cinza muito escuro, quase preto)
  static const Color surface = Color(0xFF111111); 
  
  // Cor Primária: "Konta Green" (Verde Neon Vibrante)
  // Substitui o antigo azul roxo como a cor da marca
  static const Color primaryModern = Color(0xFF00E676); 
  
  // Textos
  static const Color textWhite = Color(0xFFFFFFFF); // Branco Puro
  static const Color textSilver = Color(0xFF9E9E9E); // Cinza Médio
  
  // Acentos Funcionais
  static const Color neonGreen = Color(0xFF00E676); // Sucesso/Adicionar (Mesmo tom do primário)
  static const Color neonRed = Color(0xFFFF5252);   // Vermelho vivo para destacar erros no fundo preto
  static const Color neonBlue = Color(0xFF2979FF);  // Azul elétrico (para links ou informações neutras)
  static const Color neonOrange = Color(0xFFFFAB00); // Laranja Âmbar
  
  // Inputs (Campos de texto precisam ser levemente mais claros que o fundo)
  static const Color inputDark = Color(0xFF1C1C1E); 
  static const Color borderDark = Color(0xFF2C2C2E); 

  // Gradiente "Night Vision" (Verde escuro profundo para preto)
  // Usado no card de Saldo para dar profundidade
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [
      Color(0xFF004D40), // Verde Petróleo Profundo
      Color(0xFF000000), // Preto
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- TEMA FLUTTER GLOBAL (DARK) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Avisa o Flutter que é tema escuro
      
      // Define a cor de fundo principal
      scaffoldBackgroundColor: background, 
      primaryColor: primaryModern,
      fontFamily: 'Inter',
      
      // Esquema de cores atualizado
      colorScheme: const ColorScheme.dark(
        primary: primaryModern,
        secondary: neonGreen,
        surface: surface,
        // background: background, <--- REMOVIDO (Depreciado)
        error: neonRed,
        onSurface: textWhite,
      ),

      // Tipografia nítida para fundo preto
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textWhite),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textWhite),
        bodyLarge: TextStyle(fontSize: 16, color: textSilver),
        bodyMedium: TextStyle(fontSize: 14, color: textSilver),
      ),
      
      // Estilo dos Cards (Agora pretos/cinza escuro com borda sutil)
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderDark, width: 1), 
        ),
      ),
      
      // Campos de Texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputDark,
        labelStyle: const TextStyle(color: textSilver),
        hintStyle: TextStyle(color: textSilver.withValues(alpha: 0.5)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        // A borda de foco agora brilha com o verde neon
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryModern, width: 1.5)),
      ),

      // AppBar Transparente
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textWhite),
        titleTextStyle: TextStyle(color: textWhite, fontWeight: FontWeight.w700, fontSize: 20),
      ),
    );
  }
}