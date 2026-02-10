import 'package:flutter/material.dart';

class CreditCardModel {
  final int id;
  final int userId;
  final String uuid;
  final String nome;
  final String ultimos4;
  final String bandeira;
  final double limite;
  final int diaFechamento;
  final int diaVencimento;
  final Color color;
  final String? corHex;
  final bool ativo;

  CreditCardModel({
    required this.id,
    required this.userId,
    required this.uuid,
    required this.nome,
    required this.ultimos4,
    required this.bandeira,
    required this.limite,
    required this.diaFechamento,
    required this.diaVencimento,
    required this.color,
    this.corHex,
    required this.ativo,
  });

  double get usedLimit => 0.0; 
  double get usagePercent => 0.0; 
  double get availableLimit => limite; 

  factory CreditCardModel.fromJson(Map<String, dynamic> json) {
    return CreditCardModel(
      id: json['idCartao'] ?? 0,
      userId: json['idUsuario'] ?? 0,
      uuid: json['uuid_cartao'] ?? '',
      nome: json['nome'] ?? 'Cartão',
      ultimos4: json['ultimos4'] ?? '0000',
      bandeira: json['bandeira'] ?? 'Outros',
      limite: double.tryParse(json['limite'].toString()) ?? 0.0,
      diaFechamento: json['diaFechamento'] ?? 1,
      diaVencimento: json['diaVencimento'] ?? 10,
      color: _parseColor(json['corHex']),
      corHex: json['corHex'] ?? '',
      ativo: json['ativo'] == 1 || json['ativo'] == true,
    );
  }

  static Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.black;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.black;
    }
  }
}

// ESTA CLASSE PRECISA TER O CAMPO 'gastosPorCategoria' PARA O ERRO SUMIR
class CardOverviewModel {
  final double limiteTotal;
  final double limiteUsado;
  final double limiteDisponivel;
  final Map<String, double> gastosPorCategoria; // <--- O CAMPO QUE FALTAVA
  final List<CardInstallment> parcelasAtivas;
  final List<CardTransaction> transacoesMes;

  CardOverviewModel({
    required this.limiteTotal,
    required this.limiteUsado,
    required this.limiteDisponivel,
    required this.gastosPorCategoria,
    required this.parcelasAtivas,
    required this.transacoesMes,
  });

  factory CardOverviewModel.fromJson(Map<String, dynamic> json) {
    final detalhes = json['detalhes'] ?? {};
    final resumo = detalhes['resumoCartao'] ?? {};

    // Mapeia categorias
    final Map<String, double> categories = {};
    if (detalhes['porCategoria'] != null) {
      for (var item in detalhes['porCategoria']) {
        categories[item['categoria'] ?? 'Outros'] = double.tryParse(item['valor'].toString()) ?? 0.0;
      }
    }

    final parcelas = <CardInstallment>[];
    if (detalhes['parcelasAtivas'] != null) {
      for (var item in detalhes['parcelasAtivas']) {
        parcelas.add(CardInstallment.fromJson(item));
      }
    }

    final transacoes = <CardTransaction>[];
    if (detalhes['gastosDoMes'] != null && detalhes['gastosDoMes']['itens'] != null) {
      for (var item in detalhes['gastosDoMes']['itens']) {
        transacoes.add(CardTransaction.fromJson(item));
      }
    }

    return CardOverviewModel(
      limiteTotal: double.tryParse(resumo['limiteTotal'].toString()) ?? 0.0,
      limiteUsado: double.tryParse(resumo['limiteUsado'].toString()) ?? 0.0,
      limiteDisponivel: double.tryParse(resumo['limiteDisponivel'].toString()) ?? 0.0,
      gastosPorCategoria: categories, // <--- Aqui preenchemos ele
      parcelasAtivas: parcelas,
      transacoesMes: transacoes,
    );
  }
}

class CardInstallment {
  final String descricao;
  final double valor;
  final int parcelaAtual;
  final int totalParcelas;

  CardInstallment({required this.descricao, required this.valor, required this.parcelaAtual, required this.totalParcelas});

  factory CardInstallment.fromJson(Map<String, dynamic> json) {
    return CardInstallment(
      descricao: json['descricao'] ?? 'Parcela',
      valor: double.tryParse(json['valor'].toString()) ?? 0.0,
      parcelaAtual: json['parcelaAtual'] ?? 1,
      totalParcelas: json['totalParcelas'] ?? 1,
    );
  }
}

class CardTransaction {
  final String id;
  final String descricao;
  final double valor;
  final String data;
  final String categoria;
  final bool isParcelado;
  final int? parcelaAtual;
  final int? totalParcelas;

  CardTransaction({
    required this.id, required this.descricao, required this.valor, 
    required this.data, required this.categoria, required this.isParcelado,
    this.parcelaAtual, this.totalParcelas
  });

  factory CardTransaction.fromJson(Map<String, dynamic> json) {
    return CardTransaction(
      id: json['id']?.toString() ?? '',
      descricao: json['titulo'] ?? 'Compra',
      valor: double.tryParse(json['valor'].toString()) ?? 0.0,
      data: json['data'] ?? DateTime.now().toIso8601String(),
      categoria: json['categoria'] ?? 'outros',
      isParcelado: json['parcelaAtual'] != null,
      parcelaAtual: json['parcelaAtual'],
      totalParcelas: json['totalParcelas'],
    );
  }
}