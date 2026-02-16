import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/data/models/financing_model.dart'; // Certifique-se que o modelo existe
import 'package:konta_app/modules/financings/widgets/financing_card_widget.dart';
import 'package:konta_app/modules/financings/widgets/amortization_calculator.dart';
import 'package:konta_app/modules/financings/widgets/amortization_table.dart';
// Importe o novo Skeleton
import 'package:konta_app/modules/financings/widgets/financings_skeleton_view.dart';

class FinancingsScreen extends StatefulWidget {
  const FinancingsScreen({super.key});

  @override
  State<FinancingsScreen> createState() => _FinancingsScreenState();
}

class _FinancingsScreenState extends State<FinancingsScreen> {
  String? _selectedId;
  bool _isLoading = true; // Simulando carregamento inicial

  @override
  void initState() {
    super.initState();
    // Simulação de fetch de dados (remova quando tiver controller real)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Financing? get _selectedFinancing {
    try {
      return mockFinancings.firstWhere((f) => f.id == _selectedId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gestão de Estado de Navegação Local (Master-Detail)
    if (_selectedId != null && _selectedFinancing != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          setState(() => _selectedId = null);
        },
        child: _FinancingDetailView(
          financing: _selectedFinancing!,
          onBack: () => setState(() => _selectedId = null),
        ),
      );
    }

    // Tela Principal com Loading
    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementar navegação para Adicionar Financiamento
        },
        backgroundColor: AppTheme.neonGreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _isLoading
            ? const FinancingsSkeletonView()
            : _FinancingsListView(
                financings: mockFinancings,
                onSelect: (id) => setState(() => _selectedId = id),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// VIEW: LISTA DE FINANCIAMENTOS (Extraída)
// ---------------------------------------------------------------------------
class _FinancingsListView extends StatelessWidget {
  final List<Financing> financings;
  final ValueChanged<String> onSelect;

  const _FinancingsListView({
    required this.financings,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    // Cálculos de Resumo (poderiam estar no Controller)
    final totalDebt = financings.fold(0.0, (sum, f) => sum + f.remainingAmount);
    final totalMonthly = financings.fold(0.0, (sum, f) => sum + f.monthlyPayment);
    final avgRate = financings.isNotEmpty
        ? financings.fold<double>(0.0, (sum, f) => sum + f.interestRate) / financings.length
        : 0.0;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Financiamentos',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats Chips
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _StatChip(icon: Icons.account_balance_wallet, label: 'Dívida Total', value: currencyFormat.format(totalDebt), color: AppTheme.neonRed),
                const SizedBox(width: 12),
                _StatChip(icon: Icons.calendar_today, label: 'Parcela Total', value: currencyFormat.format(totalMonthly), color: AppTheme.neonBlue),
                const SizedBox(width: 12),
                _StatChip(icon: Icons.percent, label: 'Taxa Média', value: '${avgRate.toStringAsFixed(2)}%', color: AppTheme.neonOrange),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('Seus Contratos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSilver)),
          const SizedBox(height: 12),

          // Lista de Cards com Hero
          ...financings.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Hero(
              tag: 'financing_card_${f.id}', // Tag única para o Hero
              child: Material(
                type: MaterialType.transparency,
                child: FinancingCardWidget(
                  financing: f,
                  onTap: () => onSelect(f.id),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// VIEW: DETALHES DO FINANCIAMENTO (Extraída)
// ---------------------------------------------------------------------------
class _FinancingDetailView extends StatelessWidget {
  final Financing financing;
  final VoidCallback onBack;

  const _FinancingDetailView({
    required this.financing,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppTheme.textWhite),
          onPressed: onBack,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(financing.name, style: const TextStyle(color: AppTheme.textWhite, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Card Expandido com Hero (Transição suave da lista para cá)
            Hero(
              tag: 'financing_card_${financing.id}',
              child: Material(
                type: MaterialType.transparency,
                child: FinancingCardWidget(
                  financing: financing, 
                  isSelected: true, 
                  onTap: () {}, // Sem ação no detalhe
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Stats
            Row(
              children: [
                Expanded(child: _SummaryStatCard(label: 'Parcela', value: currencyFormat.format(financing.monthlyPayment), color: AppTheme.neonBlue)),
                const SizedBox(width: 12),
                Expanded(child: _SummaryStatCard(label: 'Restantes', value: '${financing.remainingInstallments}x', color: AppTheme.textWhite)),
              ],
            ),
            const SizedBox(height: 20),

            AmortizationCalculatorWidget(financing: financing),
            const SizedBox(height: 20),

            AmortizationTableWidget(financing: financing),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGETS AUXILIARES (Puros e Reutilizáveis)
// ---------------------------------------------------------------------------

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSilver)),
          ]),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
        ],
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryStatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
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
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSilver)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}