import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
    final total = widget.dados.fold(0.0, (sum, item) => sum + item.value);

    // Container mais limpo, sem borda pesada
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
      decoration: BoxDecoration(
        // Cor de fundo ligeiramente mais clara que o background principal para destacar suavemente
        color: AppTheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        // Sem border: Border.all(...) aqui
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribuição de Gastos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textWhite,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              // Gráfico
              SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2, // Pequeno espaço para modernidade
                        centerSpaceRadius: 55,
                        sections: _buildSections(),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Total",
                        style: TextStyle(color: AppTheme.textSilver.withValues(alpha: 0.8), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 30),
              // Legenda Limpa
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.dados.asMap().entries.map((entry) {
                    final data = entry.value;
                    final percentage = total == 0 ? 0.0 : (data.value / total * 100);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(int.parse(data.colorHex.replaceFirst('#', '0xFF'))),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              data.name,
                              style: const TextStyle(color: AppTheme.textSilver, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${percentage.toInt()}%',
                            style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.dados.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 58.0 : 50.0;

      return PieChartSectionData(
        color: Color(int.parse(data.colorHex.replaceFirst('#', '0xFF'))),
        value: data.value,
        title: '',
        radius: radius,
      );
    }).toList();
  }
}