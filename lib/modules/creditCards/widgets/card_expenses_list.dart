import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/data/models/credit_card_model.dart';

// Mapeamento estático movido para constante privada ou classe de configuração
class _CategoryConfig {
  static const Map<String, IconData> icons = {
    'shopping': Icons.shopping_bag_outlined,
    'food': Icons.restaurant,
    'transporte': Icons.directions_car_outlined, // Corrigido para pt-BR comum
    'transport': Icons.directions_car_outlined,
    'travel': Icons.flight,
    'viagem': Icons.flight,
    'lazer': Icons.sports_esports,
    'entertainment': Icons.sports_esports,
    'saude': Icons.favorite_outline,
    'health': Icons.favorite_outline,
    'educacao': Icons.school_outlined,
    'education': Icons.school_outlined,
    'outros': Icons.more_horiz,
    'other': Icons.more_horiz,
  };

  static const Map<String, Color> colors = {
    'shopping': Color(0xFFF472B6),
    'food': Color(0xFFFB923C),
    'transporte': Color(0xFF60A5FA),
    'transport': Color(0xFF60A5FA),
    'travel': Color(0xFFC084FC),
    'viagem': Color(0xFFC084FC),
    'lazer': Color(0xFF4ADE80),
    'entertainment': Color(0xFF4ADE80),
    'saude': Color(0xFFF87171),
    'health': Color(0xFFF87171),
    'educacao': Color(0xFFFACC15),
    'education': Color(0xFFFACC15),
    'outros': Color(0xFF9CA3AF),
    'other': Color(0xFF9CA3AF),
  };

  static IconData getIcon(String category) => 
      icons[category.toLowerCase()] ?? Icons.more_horiz;
  
  static Color getColor(String category) => 
      colors[category.toLowerCase()] ?? Colors.grey;
}

class CardExpensesListWidget extends StatelessWidget {
  final List<CardTransaction> expenses;
  final String selectedMonth;

  const CardExpensesListWidget({
    super.key,
    required this.expenses,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    // Cálculo otimizado (pode ser movido para o Controller se for muito pesado)
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
          _buildHeader(totalMonth, currencyFormat),

          const SizedBox(height: 20),
          Divider(height: 1, color: AppTheme.borderDark.withValues(alpha: 0.5)),
          const SizedBox(height: 20),

          // Lista ou Empty State
          if (expenses.isEmpty)
            const _EmptyStateWidget()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _ExpenseItemWidget(
                expense: expenses[index],
                currencyFormat: currencyFormat,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(double total, NumberFormat formatter) {
    return Row(
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
                letterSpacing: 1,
              ),
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
            formatter.format(total),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
            ),
          ),
        ),
      ],
    );
  }
}

// --- SUB-WIDGETS PRIVADOS (Clean Code & Performance) ---

class _ExpenseItemWidget extends StatelessWidget {
  final CardTransaction expense;
  final NumberFormat currencyFormat;

  const _ExpenseItemWidget({
    required this.expense,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM', 'pt_BR');
    final icon = _CategoryConfig.getIcon(expense.categoria);
    final color = _CategoryConfig.getColor(expense.categoria);
    
    // Tratamento de segurança para data inválida
    DateTime? date;
    try {
      date = DateTime.parse(expense.data);
    } catch (_) {}

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
                  color: AppTheme.textWhite,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (date != null)
                    Text(
                      dateFormat.format(date),
                      style: TextStyle(
                        fontSize: 12, 
                        color: AppTheme.textSilver.withValues(alpha: 0.6)
                      ),
                    ),
                  
                  if (expense.isParcelado) ...[
                    const SizedBox(width: 8),
                    _buildInstallmentBadge(),
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
            color: AppTheme.textWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildInstallmentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.inputDark,
        border: Border.all(color: AppTheme.borderDark),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${expense.parcelaAtual}/${expense.totalParcelas}',
        style: const TextStyle(fontSize: 10, color: AppTheme.textSilver),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.credit_card_off, color: AppTheme.textSilver, size: 32),
            SizedBox(height: 8),
            Text(
              'Nenhum gasto registrado',
              style: TextStyle(fontSize: 14, color: AppTheme.textSilver),
            ),
          ],
        ),
      ),
    );
  }
}