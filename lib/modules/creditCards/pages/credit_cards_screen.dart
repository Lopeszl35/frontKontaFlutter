import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/konta_snack.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/creditCards/controllers/credit_card_controller.dart';
import 'package:konta_app/modules/creditCards/widgets/credit_card_item.dart';
import 'package:konta_app/modules/creditCards/widgets/card_expenses_list.dart';
import 'package:konta_app/modules/creditCards/widgets/add_card_modal.dart';

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
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  bool _isLocaleLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await initializeDateFormatting('pt_BR', null);
    if (mounted) setState(() => _isLocaleLoaded = true);

    if (mounted) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<CreditCardController>(context, listen: false).fetchCards(user.token!, user.id);
      }
    }
  }

  // Abre Modal de Criação (Reutiliza AddCardModal existente)
  void _openAddModal() {
    final existingController = Provider.of<CreditCardController>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddCardModal(controller: existingController),
    ).then((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) existingController.fetchCards(user.token!, user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CreditCardController>(context);
    final user = Provider.of<AuthProvider>(context).user;

    if (!_isLocaleLoaded || user == null) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
      );
    }

    if (controller.selectedCard != null) {
      return _buildDetailView(context, controller, user.token!, user.id);
    }

    return _buildListView(context, controller);
  }

  // ────────── LIST VIEW (PRINCIPAL) ──────────
  Widget _buildListView(BuildContext context, CreditCardController controller) {
    final totalLimit = controller.cards.fold(0.0, (sum, c) => sum + c.limite);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        backgroundColor: AppTheme.neonGreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: SafeArea(
        child: controller.isLoading && controller.cards.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen))
            : RefreshIndicator(
                color: AppTheme.neonGreen,
                backgroundColor: AppTheme.surface,
                onRefresh: () async {
                  final user = Provider.of<AuthProvider>(context, listen: false).user!;
                  await controller.fetchCards(user.token!, user.id);
                },
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header
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

                    if (controller.cards.isEmpty && !controller.isLoading)
                      _buildEmptyState()
                    else ...[
                      Row(
                        children: [
                          Expanded(child: _summaryCard('Total Limite', currencyFormat.format(totalLimit), AppTheme.neonGreen)),
                          const SizedBox(width: 12),
                          // Aqui poderia vir o total usado se a API de listagem trouxesse
                          Expanded(child: _summaryCard('Meus Cartões', '${controller.cards.length}', AppTheme.primaryModern)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('Seus Cartões', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSilver)),
                      const SizedBox(height: 12),
                      
                      ...controller.cards.map((card) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: CreditCardItemWidget(
                          card: card,
                          onTap: () {
                            final user = Provider.of<AuthProvider>(context, listen: false).user!;
                            controller.selectCard(user.token!, user.id, card);
                          },
                        ),
                      )),
                    ]
                  ],
                ),
              ),
      ),
    );
  }

  // ────────── DETAIL VIEW (DETALHES DO CARTÃO) ──────────
  Widget _buildDetailView(BuildContext context, CreditCardController controller, String token, int userId) {
    final card = controller.selectedCard!;
    final overview = controller.cardOverview;

    if (controller.isLoading || overview == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.chevron_left, color: AppTheme.textWhite), onPressed: () => controller.clearSelection()),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
      );
    }

    final sortedCategories = overview.gastosPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.chevron_left, color: AppTheme.textWhite), onPressed: () => controller.clearSelection()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // MENU DE OPÇÕES (EDITAR, EXCLUIR, ATIVAR)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textWhite),
            color: AppTheme.surface,
            onSelected: (value) {
              if (value == 'edit') {
                KontaSnack.show(context, title: "Em Breve", message: "Edição será implementada no próximo passo.");
                // _showEditModal(context, controller, card); // Futuro
              } else if (value == 'delete') {
                _confirmDelete(context, controller, token, userId, card.uuid);
              } else if (value == 'toggle') {
                controller.toggleActive(token, userId, card.uuid, !card.ativo);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(children: [Icon(Icons.edit, size: 18, color: AppTheme.textSilver), SizedBox(width: 8), Text('Editar', style: TextStyle(color: AppTheme.textWhite))]),
              ),
              PopupMenuItem<String>(
                value: 'toggle',
                child: Row(children: [
                  Icon(card.ativo ? Icons.lock : Icons.lock_open, size: 18, color: AppTheme.textSilver), 
                  const SizedBox(width: 8), 
                  Text(card.ativo ? 'Bloquear' : 'Desbloquear', style: const TextStyle(color: AppTheme.textWhite))
                ]),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(children: [Icon(Icons.delete, size: 18, color: AppTheme.neonRed), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: AppTheme.neonRed))]),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Preview
            CreditCardItemWidget(card: card, isSelected: true, onTap: () {}),
            const SizedBox(height: 24),

            // AÇÕES RÁPIDAS (Pagar Fatura, Add Gasto)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showPayInvoiceDialog(context, controller, token, userId, card.id),
                    icon: const Icon(Icons.payment, size: 18, color: Colors.black),
                    label: const Text("Pagar Fatura", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonGreen, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                       // Implementar modal de gasto manual específico do cartão aqui
                       KontaSnack.show(context, title: "Em Breve", message: "Lançamento manual no cartão.");
                    },
                    icon: const Icon(Icons.add, size: 18, color: AppTheme.textWhite),
                    label: const Text("Add Gasto", style: TextStyle(color: AppTheme.textWhite)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.borderDark), padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Resumo Financeiro
            Row(
              children: [
                Expanded(child: _summaryCard('Limite Usado', currencyFormat.format(overview.limiteUsado), AppTheme.neonRed)),
                const SizedBox(width: 12),
                Expanded(child: _summaryCard('Disponível', currencyFormat.format(overview.limiteDisponivel), AppTheme.neonGreen)),
              ],
            ),
            const SizedBox(height: 16),

            _glassCard(
              title: 'Resumo da Fatura',
              icon: Icons.calendar_today,
              child: Column(
                children: [
                  _infoRow('Limite Total', currencyFormat.format(overview.limiteTotal)),
                  _infoRow('Fechamento', 'Dia ${card.diaFechamento}'),
                  _infoRow('Vencimento', 'Dia ${card.diaVencimento}'),
                ],
              ),
            ),
            
            // ... Resto dos Widgets (Categorias, Parcelas, Histórico) mantidos iguais ao anterior ...
            const SizedBox(height: 16),
            if (sortedCategories.isNotEmpty) _glassCard(title: 'Por Categoria', icon: Icons.pie_chart, iconColor: AppTheme.neonOrange, child: Column(children: sortedCategories.map((entry) => _categoryRow(entry, currencyFormat)).toList())),
            
            if (overview.parcelasAtivas.isNotEmpty) ...[
              const SizedBox(height: 16),
              _glassCard(title: 'Parcelas Ativas', icon: Icons.trending_down, iconColor: AppTheme.neonBlue, child: Column(children: overview.parcelasAtivas.map((p) => _installmentRow(p, currencyFormat)).toList())),
            ],

            const SizedBox(height: 16),
            const Text("Histórico da Fatura", style: TextStyle(color: AppTheme.textSilver, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CardExpensesListWidget(expenses: overview.transacoesMes, selectedMonth: DateFormat('MMMM yyyy', 'pt_BR').format(DateTime.now())),
          ],
        ),
      ),
    );
  }

  // --- MODALS AUXILIARES SIMPLES (Para manter tudo num arquivo por enquanto) ---

  void _confirmDelete(BuildContext context, CreditCardController controller, String token, int userId, String uuid) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text("Excluir Cartão?", style: TextStyle(color: AppTheme.textWhite)),
        content: const Text("Essa ação não pode ser desfeita e excluirá o histórico local deste cartão.", style: TextStyle(color: AppTheme.textSilver)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: AppTheme.textSilver))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteCard(token, userId, uuid);
            }, 
            child: const Text("Excluir", style: TextStyle(color: AppTheme.neonRed, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  void _showPayInvoiceDialog(BuildContext context, CreditCardController controller, String token, int userId, int cardId) {
    final valorCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text("Pagar Fatura", style: TextStyle(color: AppTheme.textWhite)),
        content: TextField(
          controller: valorCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(
            labelText: "Valor do Pagamento",
            prefixText: "R\$ ",
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.neonGreen)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: AppTheme.neonRed))),
          TextButton(
            onPressed: () {
              final valor = double.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? 0.0;
              if (valor > 0) {
                Navigator.pop(ctx);
                controller.payInvoice(token, userId, cardId, valor);
              }
            }, 
            child: const Text("Confirmar", style: TextStyle(color: AppTheme.neonGreen, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  // --- HELPERS VISUAIS (Reutilizados) ---
  Widget _summaryCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderDark), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSilver)), const SizedBox(height: 4), FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)))]),
    );
  }

  Widget _glassCard({required String title, required IconData icon, Color? iconColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderDark)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, size: 16, color: iconColor ?? AppTheme.neonGreen), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textWhite))]), const SizedBox(height: 12), child]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textSilver)), Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textWhite))]));
  }

  Widget _categoryRow(MapEntry<String, double> entry, NumberFormat fmt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.inputDark, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_capitalize(entry.key), style: const TextStyle(fontSize: 14, color: AppTheme.textWhite)), Text(fmt.format(entry.value), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textWhite))]),
    );
  }

  Widget _installmentRow(dynamic p, NumberFormat fmt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.inputDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderDark)),
      child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.descricao, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textWhite), overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(border: Border.all(color: AppTheme.borderDark), borderRadius: BorderRadius.circular(6)), child: Text('${p.parcelaAtual}/${p.totalParcelas}', style: TextStyle(fontSize: 10, color: AppTheme.textSilver.withValues(alpha: 0.8))))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(fmt.format(p.valor), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textWhite)), const SizedBox(height: 2), Text('Restam ${p.totalParcelas - p.parcelaAtual}x', style: const TextStyle(fontSize: 12, color: AppTheme.textSilver))])]),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.credit_card_off, size: 60, color: Colors.grey), SizedBox(height: 16), Text("Nenhum cartão encontrado", style: TextStyle(color: Colors.white))]));
  }

  String _capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
}