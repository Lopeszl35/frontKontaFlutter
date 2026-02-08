import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
// IMPORT CORRETO DO MODELO (Removemos o import da screen)
import 'package:konta_app/data/models/credit_card_model.dart'; 

const Map<String, String> brandLogos = {
  'visa': 'VISA',
  'mastercard': 'MC',
  'elo': 'ELO',
  'amex': 'AMEX',
  'other': 'CARD',
};

class CreditCardItemWidget extends StatelessWidget {
  final CreditCardModel card;
  final bool isSelected;
  final VoidCallback onTap;

  const CreditCardItemWidget({
    super.key,
    required this.card,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    // Se o modelo básico não tiver usagePercent, calculamos aqui ou assumimos 0
    final usage = card.usagePercent; 

    Color progressColor;
    if (usage > 90) {
      progressColor = AppTheme.neonRed;
    } else if (usage > 70) {
      progressColor = AppTheme.neonOrange;
    } else {
      progressColor = AppTheme.neonGreen;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 230,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              card.color, 
              Colors.black 
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: AppTheme.neonGreen, width: 2) 
              : Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppTheme.neonGreen.withValues(alpha: 0.15) 
                  : Colors.black.withValues(alpha: 0.5),
              blurRadius: isSelected ? 16 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
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
                              fontSize: 16
                            )
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
                          brandLogos[card.bandeira.toLowerCase()] ?? 'CARD', // Normaliza para lowerCase
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.w900, 
                            fontSize: 12, 
                            letterSpacing: 1.5,
                            fontStyle: FontStyle.italic
                          )
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),

                  // Card Number
                  Text(
                    '•••• •••• •••• ${card.ultimos4}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9), 
                      fontFamily: 'monospace', 
                      fontSize: 18, 
                      letterSpacing: 3,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 2)]
                    )
                  ),
                  
                  const SizedBox(height: 20),

                  // Usage Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Limite usado', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                      Text('${usage.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: usage / 100,
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation(progressColor),
                      minHeight: 6,
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  // Values
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormat.format(card.usedLimit),
                        style: const TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white
                        )
                      ),
                      Text(
                        currencyFormat.format(card.limite),
                        style: TextStyle(
                          fontSize: 13, 
                          color: Colors.white.withValues(alpha: 0.6)
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
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
}