class CardModel {
  final String uuid;
  final String nome;
  final String ultimosDigitos;

  CardModel({
    required this.uuid,
    required this.nome,
    required this.ultimosDigitos,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      // Ajuste as chaves conforme o retorno exato da sua API de cartões
      uuid: json['uuid'] ?? json['uuidCartao'] ?? '',
      nome: json['nome'] ?? 'Cartão',
      ultimosDigitos: json['final'] ?? '****', 
    );
  }
}