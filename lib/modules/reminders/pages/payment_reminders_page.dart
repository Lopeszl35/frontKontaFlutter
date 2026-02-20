import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart';
import 'package:konta_app/core/utils/konta_snack.dart';
import 'package:konta_app/modules/reminders/controllers/payment_reminders_controller.dart';
import 'package:konta_app/modules/reminders/widgets/add_edit_reminder_modal.dart';

class PaymentRemindersPage extends StatelessWidget {
  const PaymentRemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentRemindersController(),
      child: const _PaymentRemindersContent(),
    );
  }
}

class _PaymentRemindersContent extends StatelessWidget {
  const _PaymentRemindersContent();

  bool _isOverdue(String dueDate) {
    try {
      final due = DateTime.parse(dueDate);
      return due.isBefore(DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0));
    } catch (_) {
      return false;
    }
  }

  String _formatDate(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  void _showReminderModal(BuildContext context, {PaymentReminder? reminder}) {
    HapticFeedback.mediumImpact();
    final controller = Provider.of<PaymentRemindersController>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: AddEditReminderModal(reminderToEdit: reminder),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Excluir lembrete?', style: TextStyle(color: AppTheme.textWhite)),
        content: const Text('Esta ação não pode ser desfeita.', style: TextStyle(color: AppTheme.textSilver)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSilver))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<PaymentRemindersController>(context, listen: false).deleteReminder(id);
              KontaSnack.show(context, title: "Excluído", message: "Lembrete removido.");
            },
            child: const Text('Excluir', style: TextStyle(color: AppTheme.neonRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PaymentRemindersController>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite), onPressed: () => Navigator.pop(context)),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lembretes de Pagamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
            Text('Compras a prazo ou fiado', style: TextStyle(fontSize: 12, color: AppTheme.textSilver)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.neonGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showReminderModal(context),
        child: const Icon(Icons.add_rounded, color: Colors.black, size: 28),
      ),
      body: ListView(
        padding: const EdgeInsets.all(1),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSummaryCard(controller),
          const SizedBox(height: 24),
          
          _sectionHeader('Pagamentos Pendentes', Icons.access_time_rounded, AppTheme.neonOrange, controller.pending.length),
          const SizedBox(height: 12),
          
          if (controller.pending.isEmpty)
            _emptyState('Nenhum pagamento pendente 🎉')
          else
            ...controller.pending.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPendingCard(context, r, controller),
            )),
            
          const SizedBox(height: 24),
          
          if (controller.paid.isNotEmpty) ...[
            _sectionHeader('Pagamentos Realizados', Icons.check_circle_outline_rounded, AppTheme.neonGreen, controller.paid.length),
            const SizedBox(height: 20),
            ...controller.paid.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPaidCard(context, r),
            )),
          ],
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _buildSummaryCard(PaymentRemindersController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.neonOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Pendente', style: TextStyle(fontSize: 13, color: AppTheme.textSilver)),
              const SizedBox(height: 4),
              Text(Formatters.formatMoney(controller.totalPending),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
            ],
          ),
          Row(children: [
            _miniStat('${controller.pending.length}', 'Pendentes', AppTheme.neonOrange),
            const SizedBox(width: 20),
            _miniStat('${controller.paid.length}', 'Pagos', AppTheme.neonGreen),
          ]),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSilver)),
    ]);
  }

  Widget _sectionHeader(String title, IconData icon, Color color, int count) {
    return Row(children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textWhite)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
        child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ),
    ]);
  }

  Widget _emptyState(String text) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.borderDark)),
      child: Center(child: Text(text, style: const TextStyle(color: AppTheme.textSilver))),
    );
  }

  Widget _buildPendingCard(BuildContext context, PaymentReminder r, PaymentRemindersController controller) {
    final overdue = _isOverdue(r.dueDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: overdue ? AppTheme.neonRed.withValues(alpha: 0.5) : AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.description, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                    const SizedBox(height: 2),
                    Text(r.vendorName, style: const TextStyle(fontSize: 12, color: AppTheme.textSilver)),
                  ],
                ),
              ),
              _paymentMethodBadge(r.paymentMethod),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Formatters.formatMoney(r.amount), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Vencimento', style: TextStyle(fontSize: 11, color: AppTheme.textSilver)),
                  Text(
                    '${_formatDate(r.dueDate)}${overdue ? ' (Atrasado)' : ''}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: overdue ? AppTheme.neonRed : AppTheme.textWhite),
                  ),
                ],
              ),
            ],
          ),
          if (r.notes != null && r.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('"${r.notes}"', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textSilver.withValues(alpha: 0.8))),
          ],
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen.withValues(alpha: 0.15),
                  foregroundColor: AppTheme.neonGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12)
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.markAsPaid(r.id);
                  KontaSnack.show(context, title: "Pago", message: "Marcado como pago!");
                },
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('MARCAR PAGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 8),
            _actionIconButton(Icons.edit_rounded, AppTheme.neonBlue, () => _showReminderModal(context, reminder: r)),
            const SizedBox(width: 8),
            _actionIconButton(Icons.delete_rounded, AppTheme.neonRed, () => _confirmDelete(context, r.id)),
          ]),
        ],
      ),
    );
  }

  Widget _buildPaidCard(BuildContext context, PaymentReminder r) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.borderDark)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(r.description, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.neonGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: const Text('Pago', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.neonGreen)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(r.vendorName, style: const TextStyle(fontSize: 12, color: AppTheme.textSilver)),
                ],
              ),
            ),
            Text(Formatters.formatMoney(r.amount), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
            const SizedBox(width: 12),
            _actionIconButton(Icons.delete_rounded, AppTheme.textSilver, () => _confirmDelete(context, r.id)),
          ],
        ),
      ),
    );
  }

  Widget _paymentMethodBadge(String method) {
    final isPix = method == 'pix';
    final color = isPix ? AppTheme.neonBlue : AppTheme.neonOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(isPix ? Icons.qr_code_rounded : Icons.money_rounded, size: 14, color: color),
        const SizedBox(width: 4),
        Text(isPix ? 'PIX' : 'Dinheiro', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }

  Widget _actionIconButton(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(width: 45, height: 45, child: Icon(icon, size: 20, color: color)),
      ),
    );
  }
}