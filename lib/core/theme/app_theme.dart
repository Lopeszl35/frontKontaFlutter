import 'package:flutter/material.dart';

class AppTheme {
  // --- LEGADO (MANTIDO PARA NÃO QUEBRAR O RESTO) ---
  static const Color primary = Color(0xFF1E293B); 
  static const Color accent = Color(0xFF10B981); 
  static const Color accentDark = Color(0xFF059669); 
  static const Color success = Color(0xFF10B981); 
  static const Color warning = Color(0xFFF59E0B); 
  static const Color error = Color(0xFFEF4444); 
  static const Color textDark = Color(0xFF0F172A); 
  static const Color textLight = Color(0xFF64748B); 

  
  // Fundo: "Void Blue" (Profundo, quase preto, muito elegante)
  static const Color background = Color(0xFF020617); 
  
  // Superfície dos Cards: "Slate Dark" (Destaca do fundo sem ser cinza burro)
  static const Color surface = Color(0xFF1E293B); 
  
  // Cor Primária: Um Azul Elétrico / Roxo Digital
  static const Color primaryModern = Color(0xFF6366F1); 
  
  // Textos para Fundo Escuro
  static const Color textWhite = Color(0xFFF8FAFC); // Branco Gelo (Títulos)
  static const Color textSilver = Color(0xFF94A3B8); // Prata (Subtítulos)
  
  // Acentos Neon (Brilham no escuro)
  static const Color neonGreen = Color(0xFF34D399); // Sucesso/Adicionar
  static const Color neonRed = Color(0xFFF87171);   // Erro/Deletar
  static const Color neonBlue = Color(0xFF38BDF8);  // Ação/Editar
  static const Color neonOrange = Color(0xFFFBBF24); // Alerta
  
  // Inputs (Fundo dos campos de texto)
  static const Color inputDark = Color(0xFF0F172A); 
  static const Color borderDark = Color(0xFF334155); 

  // Gradiente "Aurora" (Para o card principal)
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [
      Color(0xFF4F46E5), // Indigo forte
      Color(0xFF0F172A), // Fade para o fundo
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- TEMA FLUTTER GLOBAL (DARK) ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Avisa o Flutter que é tema escuro
      
      scaffoldBackgroundColor: background, 
      primaryColor: primaryModern,
      fontFamily: 'Inter',
      
      colorScheme: const ColorScheme.dark(
        primary: primaryModern,
        secondary: neonGreen,
        surface: surface,
        background: background,
        error: neonRed,
        onSurface: textWhite,
      ),

      // Tipografia adaptada para fundo escuro
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textWhite),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textWhite),
        bodyLarge: TextStyle(fontSize: 16, color: textSilver),
        bodyMedium: TextStyle(fontSize: 14, color: textSilver),
      ),
      
      // Cards Escuros
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderDark, width: 1), // Borda sutil para separar do fundo
        ),
      ),
      
      // Inputs Escuros
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputDark,
        labelStyle: const TextStyle(color: textSilver),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryModern)),
      ),

      // AppBar
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