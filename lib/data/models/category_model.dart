class CategoryModel {
  final int id;
  final String nome;
  final double limite;
  final double totalGasto;
  final double percentual;
  final bool ativa;

  CategoryModel({
    required this.id,
    required this.nome,
    required this.limite,
    this.totalGasto = 0.0,
    this.percentual = 0.0,
    this.ativa = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // 1. TRATAMENTO DE ID (O backend usa chaves diferentes para ativa/inativa)
    // Ativa usa 'id_categoria', Inativa usa 'idCategoria'
    final int idTratado = json['id_categoria'] ?? json['idCategoria'] ?? json['id'] ?? 0;

    // 2. TRATAMENTO DE ATIVO (Backend pode mandar 1/0 ou true/false)
    final bool statusAtivo = (json['ativo'] == 1 || json['ativo'] == true);

    // 3. HELPER PARA NÚMEROS (O backend manda Strings como "588.00")
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString().replaceAll(',', '.')) ?? 0.0;
    }

    return CategoryModel(
      id: idTratado,
      nome: json['nome'] ?? 'Sem nome',
      limite: toDouble(json['limite'] ?? json['limite_mensal']),
      // Tenta pegar o gasto calculado pelo backend, senão assume 0
      totalGasto: toDouble(json['totalGastoCategoriaMes'] ?? json['total_gasto']), 
      percentual: toDouble(json['percentualGastoCategoriaMes']),
      ativa: statusAtivo,
    );
  }
}