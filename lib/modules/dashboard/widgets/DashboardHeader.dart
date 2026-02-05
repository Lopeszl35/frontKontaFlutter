import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';

class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userName;

  const DashboardHeader({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    // Lógica de formatação do nome (Pega apenas o primeiro nome)
    final firstName = userName.split(' ')[0];

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      // Garante que o ícone do Drawer (Hamburguer) seja branco
      iconTheme: const IconThemeData(color: AppTheme.textWhite),
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá, $firstName',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Resumo financeiro',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSilver,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}