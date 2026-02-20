class FixedExpense {
  final int id;
  final String tipo;
  final String categoriaExibicao;
  final String titulo;
  final String? descricao;
  final double valor;
  final int diaVencimento;
  final String recorrencia;
  final bool ativo;

  FixedExpense({
    required this.id,
    required this.tipo,
    required this.categoriaExibicao,
    required this.titulo,
    this.descricao,
    required this.valor,
    required this.diaVencimento,
    required this.recorrencia,
    required this.ativo,
  });

  factory FixedExpense.fromJson(Map<String, dynamic> json) {
    return FixedExpense(
      id: json['id_gasto_fixo'] ?? 0,
      tipo: json['tipo'] ?? 'outros',
      categoriaExibicao: json['categoria_exibicao'] ?? 'Outros',
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'],
      valor: _parseDouble(json['valor']),
      diaVencimento: json['dia_vencimento'] ?? 1,
      recorrencia: json['recorrencia'] ?? 'mensal',
      // Backend envia 1 ou 0 para ativo
      ativo: json['ativo'] == 1 || json['ativo'] == true, 
    );
  }
}

class FixedExpenseSummary {
  final double totalMensal;
  final double totalAnual;
  final double proximos7DiasTotal;
  final int proximos7DiasQuantidade;

  FixedExpenseSummary({
    required this.totalMensal,
    required this.totalAnual,
    required this.proximos7DiasTotal,
    required this.proximos7DiasQuantidade,
  });

  factory FixedExpenseSummary.fromJson(Map<String, dynamic> json) {
    final prox7 = json['proximos7Dias'] ?? {};
    return FixedExpenseSummary(
      totalMensal: _parseDouble(json['totalMensal']),
      totalAnual: _parseDouble(json['totalAnual']),
      proximos7DiasTotal: _parseDouble(prox7['total']),
      proximos7DiasQuantidade: prox7['quantidade'] ?? 0,
    );
  }
}

class CategoryTotal {
  final String categoria;
  final double total;

  CategoryTotal({required this.categoria, required this.total});

  factory CategoryTotal.fromJson(Map<String, dynamic> json) {
    return CategoryTotal(
      categoria: json['categoria'] ?? '',
      total: _parseDouble(json['total']),
    );
  }
}

// O Objeto Mestre que a tela consumirá
class FixedExpensesScreenData {
  final FixedExpenseSummary resumo;
  final List<CategoryTotal> gastosPorCategoria;
  final List<FixedExpense> lista;

  FixedExpensesScreenData({
    required this.resumo,
    required this.gastosPorCategoria,
    required this.lista,
  });

  factory FixedExpensesScreenData.fromJson(Map<String, dynamic> json) {
    return FixedExpensesScreenData(
      resumo: FixedExpenseSummary.fromJson(json['resumo'] ?? {}),
      gastosPorCategoria: (json['gastosPorCategoria'] as List? ?? [])
          .map((i) => CategoryTotal.fromJson(i))
          .toList(),
      lista: (json['lista'] as List? ?? [])
          .map((i) => FixedExpense.fromJson(i))
          .toList(),
    );
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}