import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';

enum KontaSnackType { success, error, warning, info }

class KontaSnack {
  static void show(
    BuildContext context, {
    required String title,
    String? message,
    KontaSnackType type = KontaSnackType.success,
  }) {
    // 1. Definição de Estilo baseado no Tipo
    Color color;
    IconData icon;
    Color bgIconColor;

    switch (type) {
      case KontaSnackType.success:
        color = const Color(0xFF10B981); // Verde Esmeralda
        icon = Icons.check_circle_rounded;
        break;
      case KontaSnackType.error:
        color = AppTheme.neonRed; // Vermelho
        icon = Icons.error_rounded;
        break;
      case KontaSnackType.warning:
        color = const Color(0xFFF59E0B); // Âmbar
        icon = Icons.warning_rounded;
        break;
      case KontaSnackType.info:
        color = AppTheme.primaryModern; 
        icon = Icons.info_rounded;
        break;
    }
    
    // Cor de fundo do ícone (versão clarinha da cor principal)
    bgIconColor = color.withValues(alpha: 0.1);

    // 2. Limpa snacks anteriores para não empilhar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // 3. Exibe o SnackBar Customizado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0, // Remove sombra padrão 
        backgroundColor: Colors.transparent, // Fundo transparente 
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(20), // Margem externa
        padding: EdgeInsets.zero, // Remove padding interno padrão
        
        content: Stack(
          clipBehavior: Clip.none,
          children: [
            // O CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF94A3B8).withValues(alpha: 0.2), // Sombra suave
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  )
                ],
                border: Border.all(color: Colors.grey.shade100), // Borda sutil
              ),
              child: Row(
                children: [
                  // ÍCONE LATERAL
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgIconColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // TEXTOS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Ocupa altura mínima
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B), // Slate 800
                          ),
                        ),
                        if (message != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B), // Slate 500
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // BOTÃO FECHAR (Posicionado no topo direito)
            Positioned(
              right: 8,
              top: 8,
              child: GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                child: const Icon(Icons.close, size: 16, color: Color(0xFFCBD5E1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}