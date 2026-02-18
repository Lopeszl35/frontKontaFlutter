class UserModel {
  final int id;
  final String nome;
  final String email;
  final String perfilFinanceiro;
  final double salarioMensal;
  final double saldoAtual;
  final double saldoInicial;
  final String? token;
  final String planType; 

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfilFinanceiro,
    required this.salarioMensal,
    required this.saldoAtual,
    required this.saldoInicial,
    this.token,
    this.planType = 'free', 
  });

 
  bool get isPremium => planType == 'premium' || planType == 'founder';
  bool get isFree => planType == 'free';

  factory UserModel.fromJson(Map<String, dynamic> json, String tokenRecebido) {
    final userMap = json['user'];

    return UserModel(
      id: userMap['id_usuario'] ?? 0,
      nome: userMap['nome'] ?? '',
      email: userMap['email'] ?? '',
      perfilFinanceiro: userMap['perfil_financeiro'] ?? 'moderado',
      salarioMensal: (userMap['salario_mensal'] ?? 0).toDouble(),
      saldoAtual: (userMap['saldo_atual'] ?? 0).toDouble(),
      saldoInicial: (userMap['saldo_inicial'] ?? 0).toDouble(),
      token: tokenRecebido,
      planType: userMap['plan_type'] ?? 'free', 
    );
  }
}