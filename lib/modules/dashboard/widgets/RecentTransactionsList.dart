import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/data/models/dashboard_model.dart';
import 'package:konta_app/modules/dashboard/widgets/TransactionItem.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<TransacaoFeed> transactions;
  final VoidCallback onViewAllTap;
  final bool showValues;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.showValues,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho da Seção
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Últimas Movimentações",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18, 
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textWhite
                ),
              ),
              InkWell(
                onTap: onViewAllTap,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    "Ver todas", 
                    style: TextStyle(
                      color: AppTheme.primaryModern, 
                      fontWeight: FontWeight.w600,
                      fontSize: 13
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        if (transactions.isEmpty)
          // Estado vazio mais limpo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              children: [
                Icon(Icons.receipt_long, color: AppTheme.textSilver, size: 32),
                SizedBox(height: 12),
                Text("Sem movimentações recentes", style: TextStyle(color: AppTheme.textSilver)),
              ],
            ),
          )
        else
          // Lista de Transações usando o novo design
          ...transactions.map((transacao) {
            return TransactionItem(
              title: transacao.titulo,
              category: transacao.categoria,
              value: transacao.valor,
              type: transacao.tipo,
              // Ícone foi removido daqui pois o widget agora decide sozinho
            );
          }),
      ],
    );
  }
}