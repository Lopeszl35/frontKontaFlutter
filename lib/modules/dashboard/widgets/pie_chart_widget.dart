import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:konta_app/core/theme/app_theme.dart';
import 'package:konta_app/data/models/dashboard_model.dart';

class PieChartWidget extends StatefulWidget {
  final List<GraficoData> dados;

  const PieChartWidget({super.key, required this.dados});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Se não tiver dados ou tudo for zero, mostra mensagem
    if (widget.dados.isEmpty || widget.dados.every((e) => e.value == 0)) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: const Text("Sem dados para o gráfico", style: TextStyle(color: AppTheme.textSilver)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderDark),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Distribuição de Gastos", style: TextStyle(color: AppTheme.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 4, // Espaço entre as fatias
                      centerSpaceRadius: 40, // Donut Chart
                      sections: List.generate(widget.dados.length, (i) {
                        final isTouched = i == touchedIndex;
                        final fontSize = isTouched ? 16.0 : 12.0;
                        final radius = isTouched ? 60.0 : 50.0;
                        final item = widget.dados[i];
                        
                        return PieChartSectionData(
                          color: _hexToColor(item.colorHex),
                          value: item.value,
                          title: '${item.value.toInt()}%',
                          radius: radius,
                          titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Legenda
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.dados.map((e) => _buildLegendItem(e)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(GraficoData item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _hexToColor(item.colorHex)),
          ),
          const SizedBox(width: 8),
          Text(item.name, style: const TextStyle(color: AppTheme.textSilver, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return Color(int.parse("0x$hex"));
  }
}