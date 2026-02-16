import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Core & Theme
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/konta_snack.dart';
import 'package:konta_app/widgets/glass_info_card.dart';
import 'package:konta_app/widgets/data_row_widget.dart';

// Widgets Globais
import 'package:konta_app/widgets/skeleton_container.dart'; 
import 'package:konta_app/widgets/shimmer_loading.dart';

// Controllers
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/creditCards/controllers/credit_card_controller.dart';

// Widgets Específicos
import 'package:konta_app/modules/creditCards/widgets/credit_card_item.dart';
import 'package:konta_app/modules/creditCards/widgets/card_expenses_list.dart';
import 'package:konta_app/modules/creditCards/widgets/add_card_modal.dart';
import 'package:konta_app/modules/creditCards/widgets/add_card_expense_modal.dart';
import 'package:konta_app/modules/creditCards/widgets/summary_highlight_card.dart';
import 'package:konta_app/modules/creditCards/widgets/month_selector.dart';
import 'package:konta_app/modules/creditCards/widgets/credit_cards_skeleton_view.dart';

class CreditCardsScreen extends StatelessWidget {
  const CreditCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreditCardController(),
      child: const _CreditCardsContent(),
    );
  }
}

class _CreditCardsContent extends StatefulWidget {
  const _CreditCardsContent();

  @override
  State<_CreditCardsContent> createState() => _CreditCardsContentState();
}

class _CreditCardsContentState extends State<_CreditCardsContent> {
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  bool _isLocaleLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  Future<void> _initializeData() async {
    await initializeDateFormatting('pt_BR', null);
    if (!mounted) return;
    setState(() => _isLocaleLoaded = true);

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.token != null) {
      await Provider.of<CreditCardController>(context, listen: false)
          .fetchCards(user.token!, user.id);
    }
  }

  Future<void> _refreshData() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null && user.token != null) {
      await Provider.of<CreditCardController>(context, listen: false)
          .fetchCards(user.token!, user.id);
    }
  }

  void _openAddModal() {
    final controller = Provider.of<CreditCardController>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddCardModal(controller: controller),
    ).then((_) => _refreshData());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CreditCardController>(context);
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) return const SizedBox();

    if (!_isLocaleLoaded) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
      );
    }

    if (controller.selectedCard != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          controller.clearSelection();
        },
        child: _DetailView(
          controller: controller,
          userToken: user.token!,
          userId: user.id,
          currencyFormat: _currencyFormat,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        backgroundColor: AppTheme.neonGreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: (controller.isLoading && controller.cards.isEmpty)
              ? const CreditCardsSkeletonView()
              : RefreshIndicator(
                  color: AppTheme.neonGreen,
                  backgroundColor: AppTheme.surface,
                  onRefresh: _refreshData,
                  child: _CardsListView(
                    controller: controller,
                    currencyFormat: _currencyFormat,
                    userToken: user.token!,
                    userId: user.id,
                  ),
                ),
        ),
      ),
    );
  }
}

class _CardsListView extends StatelessWidget {
  final CreditCardController controller;
  final NumberFormat currencyFormat;
  final String userToken;
  final int userId;

  const _CardsListView({
    required this.controller,
    required this.currencyFormat,
    required this.userToken,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.cards.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text("Nenhum cartão encontrado", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    final totalLimit = controller.cards.fold(0.0, (sum, c) => sum + c.limite);

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Cartões de Crédito', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: SummaryHighlightCard(label: 'Total Limite', value: currencyFormat.format(totalLimit), valueColor: AppTheme.neonGreen)),
            const SizedBox(width: 12),
            Expanded(child: SummaryHighlightCard(label: 'Meus Cartões', value: '${controller.cards.length}', valueColor: AppTheme.primaryModern)),
          ],
        ),
        const SizedBox(height: 24),
        
        const Text('Seus Cartões', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSilver)),
        const SizedBox(height: 12),

        ...controller.cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Opacity(
            opacity: card.ativo ? 1.0 : 0.5,
            child: Hero(
              tag: 'card_${card.uuid}',
              child: Material(
                type: MaterialType.transparency,
                child: CreditCardItemWidget(
                  card: card,
                  onTap: () => controller.selectCard(userToken, userId, card),
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }
}

class _DetailView extends StatelessWidget {
  final CreditCardController controller;
  final String userToken;
  final int userId;
  final NumberFormat currencyFormat;

  const _DetailView({
    required this.controller,
    required this.userToken,
    required this.userId,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Capture em variável local para permitir Flow Analysis (Promoção de Null para Non-Null)
    final card = controller.selectedCard!;
    final overview = controller.cardOverview;
    final isLoading = controller.isLoading;

    // 2. Lógica de decisão limpa
    final bool showContent = overview != null && !isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppTheme.textWhite), 
          onPressed: () => controller.clearSelection(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _buildPopupMenu(context),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Opacity(
              opacity: card.ativo ? 1.0 : 0.6,
              child: Hero(
                tag: 'card_${card.uuid}',
                child: Material(
                  type: MaterialType.transparency,
                  child: CreditCardItemWidget(card: card, isSelected: true, onTap: () {}),
                ),
              ),
            ),

            if (!card.ativo)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.neonRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.neonRed.withValues(alpha: 0.5))),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.info_outline, size: 16, color: AppTheme.neonRed), SizedBox(width: 8), Text("Cartão Desativado", style: TextStyle(color: AppTheme.neonRed, fontWeight: FontWeight.bold))]),
              ),

            const SizedBox(height: 16),
            
            MonthSelector(
              currentDate: controller.currentDate,
              onMonthChanged: (val) => controller.changeInvoiceMonth(userToken, userId, val),
            ),
            
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showPayInvoiceDialog(context, card.id),
                    icon: const Icon(Icons.payment, size: 18, color: Colors.black),
                    label: const Text("Pagar Fatura", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonGreen, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddExpenseModal(context, card.uuid),
                    icon: const Icon(Icons.add, size: 18, color: AppTheme.textWhite),
                    label: const Text("Add Gasto", style: TextStyle(color: AppTheme.textWhite)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.borderDark), padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. AnimatedSwitcher sem '!'
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: showContent
                  // Como 'showContent' é true, o Dart sabe que 'overview' não é nulo aqui.
                  ? _DetailContent(
                      overview: overview, // Sem '!'
                      currencyFormat: currencyFormat, 
                      card: card, 
                      currentDate: controller.currentDate
                    )
                  : const _DetailSkeletonView(),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayInvoiceDialog(BuildContext context, int cardId) {
     final valorCtrl = TextEditingController();
     DateTime selectedDate = controller.currentDate; 
     showDialog(
       context: context,
       builder: (ctx) => StatefulBuilder(
         builder: (context, setStateModal) => AlertDialog(
           backgroundColor: AppTheme.surface,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
           title: const Text("Pagar Fatura", style: TextStyle(color: AppTheme.textWhite)),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextField(controller: valorCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: AppTheme.textWhite, fontSize: 18), decoration: const InputDecoration(labelText: "Valor", prefixText: "R\$ ", enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.borderDark)))),
               const SizedBox(height: 16),
               InkWell(
                 onTap: () async {
                   final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030), builder: (ctx, child) => Theme(data: AppTheme.lightTheme, child: child!));
                   if(picked != null) setStateModal(() => selectedDate = picked);
                 },
                 child: Row(children: [const Icon(Icons.calendar_today, color: AppTheme.neonGreen), const SizedBox(width: 8), Text(DateFormat('MMMM yyyy', 'pt_BR').format(selectedDate).toUpperCase(), style: const TextStyle(color: AppTheme.textWhite))]),
               )
             ],
           ),
           actions: [
             TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
             ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonGreen),
               onPressed: () {
                 final valor = double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? 0.0;
                 if(valor > 0) {
                   Navigator.pop(ctx);
                   controller.payInvoice(userToken, userId, cardId, valor, selectedDate.month, selectedDate.year).then((success) {
                     if (success && context.mounted) {
                       KontaSnack.show(context, title: "Sucesso", message: "Pago!");
                     } else if (context.mounted) {
                       KontaSnack.show(context, type: KontaSnackType.error, title: "Erro", message: controller.error ?? "Erro");
                     }
                   });
                 }
               }, 
               child: const Text("Pagar", style: TextStyle(color: Colors.black))
             )
           ],
         ),
       ),
     );
  }

  void _showAddExpenseModal(BuildContext context, String cardUuid) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => ChangeNotifierProvider.value(value: controller, child: AddCardExpenseModal(cardUuid: cardUuid)),
    );
  }

  PopupMenuButton<String> _buildPopupMenu(BuildContext context) {
    final card = controller.selectedCard!;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppTheme.textWhite),
      color: AppTheme.surface,
      onSelected: (value) {
        if (value == 'edit') {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => AddCardModal(controller: controller, cardToEdit: card),
          ).then((_) => controller.selectCard(userToken, userId, card));
        } else if (value == 'delete') {
          _confirmDelete(context, card.uuid);
        } else if (value == 'toggle') {
          controller.toggleActive(userToken, userId, card.uuid, !card.ativo);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18, color: AppTheme.textSilver), SizedBox(width: 8), Text('Editar', style: TextStyle(color: AppTheme.textWhite))])),
        PopupMenuItem<String>(value: 'toggle', child: Row(children: [Icon(card.ativo ? Icons.visibility_off : Icons.visibility, size: 18, color: AppTheme.textSilver), const SizedBox(width: 8), Text(card.ativo ? 'Desativar' : 'Ativar', style: const TextStyle(color: AppTheme.textWhite))])),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: AppTheme.neonRed), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: AppTheme.neonRed))])),
      ],
    );
  }

  void _confirmDelete(BuildContext context, String uuid) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text("Excluir Cartão?", style: TextStyle(color: AppTheme.textWhite)),
        content: const Text("Essa ação não pode ser desfeita.", style: TextStyle(color: AppTheme.textSilver)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: AppTheme.textSilver))),
          TextButton(onPressed: () { Navigator.pop(ctx); controller.deleteCard(userToken, userId, uuid); }, child: const Text("Excluir", style: TextStyle(color: AppTheme.neonRed, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final dynamic overview;
  final NumberFormat currencyFormat;
  final dynamic card;
  final DateTime currentDate;

  const _DetailContent({required this.overview, required this.currencyFormat, required this.card, required this.currentDate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: SummaryHighlightCard(label: 'Limite Usado', value: currencyFormat.format(overview.limiteUsado), valueColor: AppTheme.neonRed)),
            const SizedBox(width: 12),
            Expanded(child: SummaryHighlightCard(label: 'Disponível', value: currencyFormat.format(overview.limiteDisponivel), valueColor: AppTheme.neonGreen)),
          ],
        ),
        const SizedBox(height: 16),

        GlassInfoCard(
          title: 'Detalhes da Fatura',
          icon: Icons.calendar_today,
          child: Column(
            children: [
              DataRowWidget(label: 'Valor da Fatura', value: currencyFormat.format(overview.limiteUsado)),
              DataRowWidget(label: 'Vencimento', value: '${card.diaVencimento}/${currentDate.month}/${currentDate.year}'),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        if (overview.gastosPorCategoria.isNotEmpty) 
          GlassInfoCard(
            title: 'Por Categoria', 
            icon: Icons.pie_chart, 
            iconColor: AppTheme.neonOrange, 
            child: Column(
              children: (overview.gastosPorCategoria.entries.toList()
                ..sort((a, b) {
                   final double valA = (a.value is num) ? (a.value as num).toDouble() : 0.0;
                   final double valB = (b.value is num) ? (b.value as num).toDouble() : 0.0;
                   return valB.compareTo(valA);
                }))
                .map<Widget>((entry) => _categoryRow(entry))
                .toList(),
            )
          ),
        
        if (overview.parcelasAtivas.isNotEmpty) ...[
          const SizedBox(height: 16),
          GlassInfoCard(title: 'Parcelas Futuras', icon: Icons.trending_down, iconColor: AppTheme.neonBlue, child: Column(children: overview.parcelasAtivas.map<Widget>((p) => _installmentRow(p)).toList())),
        ],

        const SizedBox(height: 16),
        const Align(alignment: Alignment.centerLeft, child: Text("Lançamentos", style: TextStyle(color: AppTheme.textSilver, fontSize: 16, fontWeight: FontWeight.bold))),
        const SizedBox(height: 10),
        
        CardExpensesListWidget(
          expenses: overview.transacoesMes, 
          selectedMonth: DateFormat('MMMM yyyy', 'pt_BR').format(currentDate)
        ),
      ],
    );
  }

  Widget _categoryRow(MapEntry<String, dynamic> entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(entry.key.isNotEmpty ? entry.key[0].toUpperCase() + entry.key.substring(1) : entry.key, style: const TextStyle(fontSize: 14, color: AppTheme.textWhite)), 
        Text(currencyFormat.format(entry.value), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textWhite))
      ]),
    );
  }

  Widget _installmentRow(dynamic p) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.descricao, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textWhite), overflow: TextOverflow.ellipsis),
          Text('${p.parcelaAtual}/${p.totalParcelas}', style: TextStyle(fontSize: 10, color: AppTheme.textSilver.withValues(alpha: 0.8))),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(currencyFormat.format(p.valor), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
          Text('Restam ${p.totalParcelas - p.parcelaAtual}x', style: const TextStyle(fontSize: 12, color: AppTheme.textSilver))
        ])
      ]),
    );
  }
}

class _DetailSkeletonView extends StatelessWidget {
  const _DetailSkeletonView();

  @override
  Widget build(BuildContext context) {
    // 4. Correção dos const: O const está no topo (ShimmerLoading),
    // então os filhos diretos não precisam repetir const.
    return const ShimmerLoading(
      child: Column(
        children: [
           Row(children: [
             Expanded(child: SkeletonContainer(height: 80)), 
             SizedBox(width: 12), 
             Expanded(child: SkeletonContainer(height: 80))
           ]),
           SizedBox(height: 16),
           SkeletonContainer(height: 100),
           SizedBox(height: 16),
           SkeletonContainer(height: 150),
        ],
      ),
    );
  }
}