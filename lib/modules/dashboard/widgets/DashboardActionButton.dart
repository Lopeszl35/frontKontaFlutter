import 'package:flutter/material.dart';

class DashboardActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const DashboardActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<DashboardActionButton> createState() => _DashboardActionButtonState();
}

class _DashboardActionButtonState extends State<DashboardActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Cor de fundo levemente transparente
    final backgroundColor = widget.color.withValues(alpha: 0.15);
    
    // Cor da "espessura" 3D (sombra sólida)
    final shadowColor = widget.color.withValues(alpha: 0.5);

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50), // Animação rápida (mecânica)
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          
          // EFEITO DE MOVIMENTO FÍSICO:
          // Quando pressionado, aumentamos a margem superior para o botão "descer"
          margin: EdgeInsets.only(
            top: _isPressed ? 4 : 0, 
            bottom: _isPressed ? 0 : 4, // Compensa o espaço para não pular o layout
            left: 4, 
            right: 4
          ),
          
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            
            // Borda uniforme (Isso resolve o erro do Flutter)
            border: Border.all(
              color: widget.color.withValues(alpha: 0.3),
              width: 1,
            ),
            
            // A MÁGICA DO 3D ESTÁ AQUI:
            boxShadow: _isPressed 
              ? [] // Sem sombra quando pressionado (botão afundado)
              : [
                  BoxShadow(
                    color: shadowColor, // Cor da "lateral" do botão
                    offset: const Offset(0, 4), // Desloca para baixo (4px de altura)
                    blurRadius: 0, // Zero blur = Sombra sólida (parece bloco 3D)
                  ),
                ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}