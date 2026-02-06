import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/modules/creditCards/pages/credit_cards_screen.dart'; 

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

// Cores adaptadas para o modo dark (mais vibrantes)
const Map<String, Color> categoryColors = {
  'shopping': Color(0xFFF472B6), // Rosa
  'food': Color(0xFFFB923C),     // Laranja
  'transport': Color(0xFF60A5FA), // Azul
  'travel': Color(0xFFC084FC),   // Roxo
  'entertainment': Color(0xFF4ADE80), // Verde
  'health': Color(0xFFF87171),   // Vermelho
  'education': Color(0xFFFACC15), // Amarelo
  'other': Color(0xFF9CA3AF),    // Cinza
};

class CardExpensesListWidget extends StatelessWidget {
  final List<CardExpense> expenses;
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
    final totalMonth = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface, // Fundo Escuro
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
                final icon = categoryIcons[expense.category] ?? Icons.more_horiz;
                final color = categoryColors[expense.category] ?? Colors.grey;
                final date = DateTime.tryParse(expense.date);

                return Row(
                  children: [
                    // Ícone com fundo translúcido
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Detalhes
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.description,
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
                              if (expense.isInstallment) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.inputDark,
                                    border: Border.all(color: AppTheme.borderDark),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${expense.currentInstallment}/${expense.totalInstallments}',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.textSilver)
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Valor
                    Text(
                      currencyFormat.format(expense.amount),
                      style: const TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold, 
                        color: AppTheme.textWhite // Valor em branco para limpeza visual
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