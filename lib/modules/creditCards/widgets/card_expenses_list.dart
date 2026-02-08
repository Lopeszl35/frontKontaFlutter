import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/data/models/credit_card_model.dart'; 

const Map<String, IconData> categoryIcons = {
  'shopping': Icons.shopping_bag_outlined,
  'food': Icons.restaurant,
  'transport': Icons.directions_car_outlined,
  'travel': Icons.flight,
  'entertainment': Icons.sports_esports,
  'health': Icons.favorite_outline,
  'education': Icons.school_outlined,
  'other': Icons.more_horiz,
};

const Map<String, Color> categoryColors = {
  'shopping': Color(0xFFF472B6), 
  'food': Color(0xFFFB923C),     
  'transport': Color(0xFF60A5FA), 
  'travel': Color(0xFFC084FC),   
  'entertainment': Color(0xFF4ADE80), 
  'health': Color(0xFFF87171),   
  'education': Color(0xFFFACC15), 
  'other': Color(0xFF9CA3AF),    
};

class CardExpensesListWidget extends StatelessWidget {
  final List<CardTransaction> expenses; // <--- Tipagem correta usando o Model
  final String selectedMonth;

  const CardExpensesListWidget({
    super.key,
    required this.expenses,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd MMM', 'pt_BR');
    // Para CardTransaction, usamos 'valor' em vez de 'amount'
    final totalMonth = expenses.fold<double>(0, (sum, e) => sum + e.valor); 

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface, 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, size: 18, color: AppTheme.neonGreen),
                  const SizedBox(width: 8),
                  Text(
                    selectedMonth.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold, 
                      color: AppTheme.textSilver,
                      letterSpacing: 1
                    )
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.inputDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: Text(
                  currencyFormat.format(totalMonth),
                  style: const TextStyle(
                    fontSize: 13, 
                    fontWeight: FontWeight.bold, 
                    color: AppTheme.textWhite
                  )
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          Divider(height: 1, color: AppTheme.borderDark.withValues(alpha: 0.5)),
          const SizedBox(height: 20),

          if (expenses.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.credit_card_off, color: AppTheme.textSilver, size: 32),
                    SizedBox(height: 8),
                    Text('Nenhum gasto registrado',
                        style: TextStyle(fontSize: 14, color: AppTheme.textSilver)),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final expense = expenses[index];
                // Usando campos do CardTransaction (descricao, valor, data, etc)
                final icon = categoryIcons[expense.categoria] ?? Icons.more_horiz;
                final color = categoryColors[expense.categoria] ?? Colors.grey;
                final date = DateTime.tryParse(expense.data);

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.descricao,
                            style: const TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.w600, 
                              color: AppTheme.textWhite
                            ),
                            overflow: TextOverflow.ellipsis
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (date != null)
                                Text(
                                  dateFormat.format(date),
                                  style: TextStyle(fontSize: 12, color: AppTheme.textSilver.withValues(alpha: 0.6))
                                ),
                              if (expense.isParcelado) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.inputDark,
                                    border: Border.all(color: AppTheme.borderDark),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${expense.parcelaAtual}/${expense.totalParcelas}',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.textSilver)
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currencyFormat.format(expense.valor),
                      style: const TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold, 
                        color: AppTheme.textWhite
                      )
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}