import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';

class PremiumGate extends StatelessWidget {
  final Widget child;
  final Widget? replacement; // O que mostrar se não for premium (ex: cadeado, borrão, ou nada)

  const PremiumGate({super.key, required this.child, this.replacement});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    
    // Lógica simples agora, mas preparada para RevenueCat no futuro
    final isPremium = user?.planType == 'premium'; 

    if (isPremium) {
      return child;
    }

    return replacement ?? const SizedBox.shrink(); // Se não for premium, esconde
  }
}