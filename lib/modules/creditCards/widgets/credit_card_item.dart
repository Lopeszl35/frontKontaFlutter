import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/data/models/credit_card_model.dart';

class CreditCardItemWidget extends StatelessWidget {
  final CreditCardModel card;
  final bool isSelected;
  final VoidCallback onTap;

  const CreditCardItemWidget({
    super.key,
    required this.card,
    required this.onTap,
    this.isSelected = false,
  });

  // Mapeamento de Logos
  String get _brandLogo {
    const logos = {
      'visa': 'VISA',
      'mastercard': 'MC',
      'elo': 'ELO',
      'amex': 'AMEX',
    };
    return logos[card.bandeira.toLowerCase()] ?? 'CARD';
  }

  // Lógica de Cor da Barra de Progresso
  Color get _progressColor {
    final usage = card.usagePercent;
    if (usage > 90) return AppTheme.neonRed;
    if (usage > 70) return AppTheme.neonOrange;
    return AppTheme.neonGreen;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final usage = card.usagePercent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic, // Curva mais suave "Apple-like"
        height: 230,
        decoration: _buildDecoration(),
        child: Stack(
          children: [
            // Círculos Decorativos (Background Noise)
            _buildBackgroundCircle(top: -20, right: -20, size: 150),
            _buildBackgroundCircle(bottom: -40, left: -20, size: 120),

            // Conteúdo Principal
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardHeader(),
                  const Spacer(),
                  _buildCardNumber(),
                  const SizedBox(height: 20),
                  _buildUsageInfo(usage),
                  const SizedBox(height: 8),
                  _buildProgressBar(usage),
                  const SizedBox(height: 8),
                  _buildValuesRow(currencyFormat),
                ],
              ),
            ),

            // Badge de Seleção
            if (isSelected)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.neonGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          card.color,
          Colors.black, // Dark Mode Gradient End
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      // Borda animada
      border: isSelected
          ? Border.all(color: AppTheme.neonGreen, width: 2)
          : Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      // Sombra dinâmica
      boxShadow: [
        BoxShadow(
          color: isSelected
              ? AppTheme.neonGreen.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.5),
          blurRadius: isSelected ? 16 : 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _buildBackgroundCircle({double? top, double? right, double? bottom, double? left, required double size}) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.05), // Efeito de vidro sutil
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.credit_card, color: Colors.white.withValues(alpha: 0.9), size: 20),
            const SizedBox(width: 10),
            Text(
              card.nome,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _brandLogo,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardNumber() {
    return Text(
      '•••• •••• •••• ${card.ultimos4}',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontFamily: 'monospace',
        fontSize: 18,
        letterSpacing: 3,
        shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 2)],
      ),
    );
  }

  Widget _buildUsageInfo(double usage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Limite usado',
          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
        ),
        Text(
          '${usage.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double usage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: usage / 100,
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        valueColor: AlwaysStoppedAnimation(_progressColor),
        minHeight: 6,
      ),
    );
  }

  Widget _buildValuesRow(NumberFormat currencyFormat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          currencyFormat.format(card.usedLimit),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          currencyFormat.format(card.limite),
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}