import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/modules/creditCards/widgets/credit_card_item.dart';
import 'package:konta_app/modules/creditCards/widgets/card_expenses_list.dart';

// ---------- Models ----------

class CreditCard {
  final String id;
  final String name;
  final String lastDigits;
  final String brand;
  final double limit;
  final double usedLimit;
  final int dueDay;
  final int closingDay;
  final Color color;

  const CreditCard({
    required this.id,
    required this.name,
    required this.lastDigits,
    required this.brand,
    required this.limit,
    required this.usedLimit,
    required this.dueDay,
    required this.closingDay,
    required this.color,
  });

  double get availableLimit => limit - usedLimit;
  double get usagePercent => (usedLimit / limit) * 100;
}

class CardExpense {
  final String id;
  final String cardId;
  final String description;
  final double amount;
  final String date;
  final String category;
  final int? currentInstallment;
  final int? totalInstallments;
  final bool isInstallment;

  const CardExpense({
    required this.id,
    required this.cardId,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    this.currentInstallment,
    this.totalInstallments,
    required this.isInstallment,
  });
}

// ---------- Mock Data ----------

final List<CreditCard> mockCards = [
  CreditCard(id: '1', name: 'Nubank', lastDigits: '4532', brand: 'mastercard', limit: 8000, usedLimit: 3250, dueDay: 15, closingDay: 8, color: const Color(0xFF820AD1)), // Roxo Nubank
  CreditCard(id: '2', name: 'Itaú Platinum', lastDigits: '8821', brand: 'visa', limit: 15000, usedLimit: 4800, dueDay: 20, closingDay: 13, color: const Color(0xFFEA580C)),
  CreditCard(id: '3', name: 'Bradesco', lastDigits: '1199', brand: 'elo', limit: 5000, usedLimit: 1200, dueDay: 10, closingDay: 3, color: const Color(0xFFDC2626)),
];

final List<CardExpense> mockExpenses = [
  CardExpense(id: '1', cardId: '1', description: 'Amazon - iPhone Case', amount: 89.90, date: '2026-01-02', category: 'shopping', isInstallment: false),
  CardExpense(id: '2', cardId: '1', description: 'iFood', amount: 45.50, date: '2026-01-03', category: 'food', isInstallment: false),
  CardExpense(id: '3', cardId: '1', description: 'PlayStation 5', amount: 416.58, date: '2026-01-05', category: 'entertainment', currentInstallment: 3, totalInstallments: 12, isInstallment: true),
  CardExpense(id: '4', cardId: '1', description: 'Curso Udemy', amount: 27.90, date: '2026-01-08', category: 'education', isInstallment: false),
  CardExpense(id: '5', cardId: '1', description: 'Uber', amount: 32.40, date: '2026-01-10', category: 'transport', isInstallment: false),
  CardExpense(id: '6', cardId: '2', description: 'Notebook Dell', amount: 583.25, date: '2026-01-04', category: 'shopping', currentInstallment: 5, totalInstallments: 10, isInstallment: true),
  CardExpense(id: '7', cardId: '2', description: 'Restaurante', amount: 180.00, date: '2026-01-06', category: 'food', isInstallment: false),
];

// ---------- Screen ----------

class CreditCardsScreen extends StatefulWidget {
  const CreditCardsScreen({super.key});

  @override
  State<CreditCardsScreen> createState() => _CreditCardsScreenState();
}

class _CreditCardsScreenState extends State<CreditCardsScreen> {
  String? _selectedCardId;

  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  double get totalLimit => mockCards.fold(0, (sum, c) => sum + c.limit);
  double get totalUsed => mockCards.fold(0, (sum, c) => sum + c.usedLimit);

  CreditCard? get selectedCard =>
      _selectedCardId != null ? mockCards.firstWhere((c) => c.id == _selectedCardId) : null;

  List<CardExpense> get cardExpenses =>
      mockExpenses.where((e) => e.cardId == _selectedCardId).toList();

  @override
  Widget build(BuildContext context) {
    // Seletor de tela (Lista ou Detalhes)
    if (selectedCard != null) {
      return _buildDetailView(selectedCard!);
    }
    return _buildListView();
  }

  // ────────── LIST VIEW ──────────

  Widget _buildListView() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.neonGreen, // Destaque Neon
        child: const Icon(Icons.add, color: Colors.black), // Ícone preto para contraste no verde
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.neonGreen,
          backgroundColor: AppTheme.surface,
          onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cartões de Crédito',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Global
              Row(
                children: [
                  Expanded(child: _summaryCard('Total Limite', currencyFormat.format(totalLimit), AppTheme.neonGreen)),
                  const SizedBox(width: 12),
                  Expanded(child: _summaryCard('Total Usado', currencyFormat.format(totalUsed), AppTheme.neonRed)),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Seus Cartões',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSilver)),
              const SizedBox(height: 12),

              // Cards List
              ...mockCards.map((card) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CreditCardItemWidget(
                  card: card,
                  onTap: () => setState(() => _selectedCardId = card.id),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  // ────────── DETAIL VIEW ──────────

  Widget _buildDetailView(CreditCard card) {
    final expenses = cardExpenses;
    final installments = expenses.where((e) => e.isInstallment).toList();

    // Stats por Categoria
    final Map<String, double> categoryStats = {};
    for (final exp in expenses) {
      categoryStats[exp.category] = (categoryStats[exp.category] ?? 0) + exp.amount;
    }
    final sortedCategories = categoryStats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Botão Voltar
            GestureDetector(
              onTap: () => setState(() => _selectedCardId = null),
              child: Row(
                children: [
                  const Icon(Icons.chevron_left, color: AppTheme.textSilver, size: 20),
                  const SizedBox(width: 4),
                  const Text('Voltar', style: TextStyle(color: AppTheme.textSilver, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Preview do Cartão Selecionado
            CreditCardItemWidget(card: card, isSelected: true, onTap: () {}),
            const SizedBox(height: 16),

            // Resumo do Cartão Específico
            Row(
              children: [
                Expanded(child: _summaryCard('Limite Usado', currencyFormat.format(card.usedLimit), AppTheme.neonRed)),
                const SizedBox(width: 12),
                Expanded(child: _summaryCard('Disponível', currencyFormat.format(card.availableLimit), AppTheme.neonGreen)),
              ],
            ),
            const SizedBox(height: 16),

            // Info Card (Fechamento/Vencimento)
            _glassCard(
              title: 'Resumo da Fatura',
              icon: Icons.calendar_today,
              child: Column(
                children: [
                  _infoRow('Limite Total', currencyFormat.format(card.limit)),
                  _infoRow('Fechamento', 'Dia ${card.closingDay}'),
                  _infoRow('Vencimento', 'Dia ${card.dueDay}'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Categorias
            if (sortedCategories.isNotEmpty)
              _glassCard(
                title: 'Por Categoria',
                icon: Icons.pie_chart,
                iconColor: AppTheme.neonOrange,
                child: Column(
                  children: sortedCategories.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.inputDark, // Fundo levemente mais claro que o surface
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_capitalize(entry.key),
                              style: const TextStyle(fontSize: 14, color: AppTheme.textWhite)),
                          Text(currencyFormat.format(entry.value),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            if (sortedCategories.isNotEmpty) const SizedBox(height: 16),

            // Parcelas
            if (installments.isNotEmpty) ...[
              _glassCard(
                title: 'Parcelas Ativas',
                icon: Icons.trending_down,
                iconColor: AppTheme.neonBlue,
                child: Column(
                  children: installments.map((exp) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.inputDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(exp.description,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textWhite),
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppTheme.borderDark),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('${exp.currentInstallment}/${exp.totalInstallments}',
                                      style: TextStyle(fontSize: 10, color: AppTheme.textSilver.withValues(alpha: 0.8))),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(currencyFormat.format(exp.amount),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
                              const SizedBox(height: 2),
                              Text('Restam ${(exp.totalInstallments ?? 0) - (exp.currentInstallment ?? 0)}x',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textSilver)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Lista Completa de Despesas (Assume que CardExpensesListWidget aceita estilo customizável ou herda tema)
            const Text("Histórico da Fatura", style: TextStyle(color: AppTheme.textSilver, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CardExpensesListWidget(expenses: expenses, selectedMonth: 'Janeiro 2026'),
          ],
        ),
      ),
    );
  }

  // ────────── Helpers Visuais ──────────

  Widget _summaryCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSilver)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _glassCard({required String title, required IconData icon, Color? iconColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor ?? AppTheme.neonGreen),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textSilver)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
        ],
      ),
    );
  }

  String _capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}