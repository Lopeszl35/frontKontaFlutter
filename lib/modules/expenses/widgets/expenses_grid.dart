import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/core/utils/formatters.dart';
import 'package:konta_app/modules/auth/controllers/auth_provider.dart';
import 'package:konta_app/modules/expenses/controllers/variable_expenses_controller.dart';

class ExpensesGrid extends StatelessWidget {
  final Function(dynamic) onEditCategory;
  final Function(int id, String nome) onAddExpense;

  const ExpensesGrid({
    super.key,
    required this.onEditCategory,
    required this.onAddExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VariableExpensesController>(
      builder: (context, controller, _) {
        if (controller.categoriasAtivas.isEmpty) {
          return _buildEmptyState();
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75, // Ajustado para dar respiro ao layout
          ),
          itemCount: controller.categoriasAtivas.length,
          itemBuilder: (ctx, index) {
            final cat = controller.categoriasAtivas[index];
            return _CategoryCard(
              category: cat,
              onEdit: () => onEditCategory(cat),
              onAdd: () => onAddExpense(cat.id, cat.nome),
              onDelete: () => _confirmDelete(context, cat.id, cat.nome, controller),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(Icons.grid_off_rounded, size: 48, color: AppTheme.textSilver.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text("Nenhuma categoria ativa", style: TextStyle(color: AppTheme.textSilver)),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, String nome, VariableExpensesController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppTheme.borderDark)),
        title: const Text("Arquivar Categoria?", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textWhite)),
        content: Text("A categoria '$nome' será enviada para o histórico.", style: const TextStyle(color: AppTheme.textSilver)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: AppTheme.textSilver))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonRed.withValues(alpha: 0.2), foregroundColor: AppTheme.neonRed, elevation: 0),
            onPressed: () async {
              Navigator.pop(ctx);
              final user = Provider.of<AuthProvider>(context, listen: false).user;
              if (user != null) {
                await controller.deleteCategory(context, user.token!, user.id, id);
              }
            },
            child: const Text("Arquivar", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET DO CARD EXTRAÍDO (Performance & Clean Code) ---
class _CategoryCard extends StatelessWidget {
  final dynamic category; // Idealmente use o Model tipado
  final VoidCallback onEdit;
  final VoidCallback onAdd;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final percent = category.limite > 0 ? (category.totalGasto / category.limite) : 0.0;
    final statusColor = _getStatusColor(percent);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderDark, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Área de Informações (Expanded)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // HERO: Ícone pronto para animar
                      Hero(
                        tag: 'category_icon_${category.id}',
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppTheme.inputDark, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.category_rounded, color: AppTheme.textWhite, size: 20),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                        child: Text("${(percent * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 11)),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(category.nome, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textWhite)),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: Formatters.formatMoney(category.totalGasto), style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 13, fontFamily: 'Inter')),
                        TextSpan(text: " / ${Formatters.formatMoney(category.limite)}", style: const TextStyle(color: AppTheme.textSilver, fontSize: 11, fontFamily: 'Inter')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent.clamp(0.0, 1.0),
                      backgroundColor: AppTheme.inputDark,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Barra de Ações Inferior
          Container(
            height: 48,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.borderDark)),
            ),
            child: Row(
              children: [
                _buildActionButton(icon: Icons.edit_outlined, color: AppTheme.textSilver, onTap: onEdit, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24))),
                Container(width: 1, height: 20, color: AppTheme.borderDark),
                _buildActionButton(icon: Icons.delete_outline, color: AppTheme.neonRed, onTap: onDelete),
                Container(width: 1, height: 20, color: AppTheme.borderDark),
                _buildActionButton(icon: Icons.attach_money, color: Colors.white, bg: AppTheme.primaryModern, onTap: onAdd, borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onTap, BorderRadius? borderRadius, Color? bg}) {
    return Expanded(
      child: Material(
        color: bg ?? Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Center(child: Icon(icon, size: 20, color: color)),
        ),
      ),
    );
  }

  Color _getStatusColor(double percent) {
    if (percent > 1.0) return AppTheme.neonRed;
    if (percent > 0.8) return AppTheme.neonOrange;
    return AppTheme.neonGreen;
  }
}