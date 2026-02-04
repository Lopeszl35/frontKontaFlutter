class DashboardModel {
  final ResumoFinanceiro resumo;
  final DetalhamentoDespesas detalhamento;
  final List<TransacaoFeed> transacoes;
  final List<GraficoData> graficos;

  DashboardModel({
    required this.resumo,
    required this.detalhamento,
    required this.transacoes,
    required this.graficos,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      resumo: ResumoFinanceiro.fromJson(json['resumoFinanceiro'] ?? {}),
      detalhamento: DetalhamentoDespesas.fromJson(json['detalhamentoDespesas'] ?? {}),
      transacoes: (json['feedTransacoes'] as List? ?? [])
          .map((e) => TransacaoFeed.fromJson(e))
          .toList(),
      graficos: (json['graficos'] as List? ?? []) // Parseamento da lista de gráficos
          .map((e) => GraficoData.fromJson(e))
          .toList(),
    );
  }
}


class ResumoFinanceiro {
  final double saldoAtual;
  final double receitas;
  final double despesas;
  final double balanco;

  ResumoFinanceiro({
    required this.saldoAtual,
    required this.receitas,
    required this.despesas,
    required this.balanco,
  });

  factory ResumoFinanceiro.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return ResumoFinanceiro(
      saldoAtual: toDouble(json['saldoAtual']),
      receitas: toDouble(json['receitas']),
      despesas: toDouble(json['despesas']),
      balanco: toDouble(json['balanco']),
    );
  }
}

class DetalhamentoDespesas {
  final double fixas;
  final double variaveis;
  final double cartaoCredito;

  DetalhamentoDespesas({
    required this.fixas,
    required this.variaveis,
    required this.cartaoCredito,
  });

  factory DetalhamentoDespesas.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }
    
    return DetalhamentoDespesas(
      fixas: toDouble(json['fixas']),
      variaveis: toDouble(json['variaveis']),
      cartaoCredito: toDouble(json['cartaoCredito']),
    );
  }
}

class TransacaoFeed {
  final String id;
  final String titulo;
  final double valor;
  final String tipo;
  final String categoria;

  TransacaoFeed({
    required this.id,
    required this.titulo,
    required this.valor,
    required this.tipo,
    required this.categoria,
  });

  factory TransacaoFeed.fromJson(Map<String, dynamic> json) {
    return TransacaoFeed(
      id: json['id'] ?? 'uniq',
      titulo: json['titulo'] ?? 'Sem título',
      valor: (json['valor'] is num) ? (json['valor'] as num).toDouble() : 0.0,
      tipo: json['tipo'] ?? 'despesa',
      categoria: json['categoria'] ?? 'Geral',
    );
  }
}

// --- NOVA CLASSE PARA O GRÁFICO ---

class GraficoData {
  final String name;
  final double value;
  final String colorHex;

  GraficoData({
    required this.name,
    required this.value,
    required this.colorHex,
  });

  factory GraficoData.fromJson(Map<String, dynamic> json) {
    // Helper local para garantir robustez no valor
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return GraficoData(
      name: json['name'] ?? '',
      value: toDouble(json['value']),
      colorHex: json['color'] ?? '#FFFFFF', // Fallback para branco se vier nulo
    );
  }
}