class UserModel {
  final int id;
  final String nome;
  final String email;
  final String perfilFinanceiro;
  final double salarioMensal;
  final double saldoAtual;
  final double saldoInicial;
  final String? token; // O token pode vir separado ou junto, vamos guardar aqui

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfilFinanceiro,
    required this.salarioMensal,
    required this.saldoAtual,
    required this.saldoInicial,
    this.token,
  });

  // Factory: O "tradutor" que pega o JSON (Map) e transforma em Objeto Dart
  factory UserModel.fromJson(Map<String, dynamic> json, String tokenRecebido) {
    // A estrutura do JSON de login tem um objeto "user" dentro.
    // Vamos acessar json['user'] para pegar os dados.
    final userMap = json['user'];

    return UserModel(
      id: userMap['id_usuario'] ?? 0, // Se vier null, assume 0 (segurança)
      nome: userMap['nome'] ?? '',
      email: userMap['email'] ?? '',
      perfilFinanceiro: userMap['perfil_financeiro'] ?? 'moderado',
      salarioMensal: (userMap['salario_mensal'] ?? 0).toDouble(),
      saldoAtual: (userMap['saldo_atual'] ?? 0).toDouble(),
      saldoInicial: (userMap['saldo_inicial'] ?? 0).toDouble(),
      token: tokenRecebido,
    );
  }
}