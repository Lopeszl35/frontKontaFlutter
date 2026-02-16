import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  
  // Cores ajustadas para Dark Mode (Baseado no seu SkeletonContainer)
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    // Base transparente, quase invisível
    this.baseColor = const Color(0xFF2A2A2A), 
    // O brilho que passa (mais claro)
    this.highlightColor = const Color(0xFF505050), 
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Ciclo de 1.5 segundos cria um efeito "calmo" e premium, não frenético
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(); // Repete infinitamente

    // A animação move o gradiente da esquerda (-1.0) para a direita (2.0)
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop, // O SEGREDO: Só pinta onde tem conteúdo no child
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor, // O brilho no meio
                widget.baseColor,
              ],
              stops: const [
                0.1,
                0.5,
                0.9,
              ],
              // Move o gradiente baseado na animação
              transform: _SlidingGradientTransform(percent: _animation.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// Classe auxiliar para mover o gradiente matematicamente
class _SlidingGradientTransform extends GradientTransform {
  final double percent;
  const _SlidingGradientTransform({required this.percent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Translada o X do gradiente baseado na largura do widget
    return Matrix4.translationValues(bounds.width * percent, 0, 0);
  }
}