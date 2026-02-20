class FinancingSummary {
  final double totalDebt;
  final double totalMonthly;
  final double avgRate;

  FinancingSummary({
    required this.totalDebt,
    required this.totalMonthly,
    required this.avgRate,
  });

  factory FinancingSummary.fromJson(Map<String, dynamic> json) {
    return FinancingSummary(
      totalDebt: _parseDouble(json['dividaTotal']),
      totalMonthly: _parseDouble(json['parcelaTotal']),
      avgRate: _parseDouble(json['taxaMedia']),
    );
  }
}

class FinancingParcel {
  final int id;
  final int number;
  final DateTime? dueDate;
  final double value;
  final double amortization;
  final double interest;
  final String status; // 'aberta', 'paga'

  FinancingParcel({
    required this.id,
    required this.number,
    this.dueDate,
    required this.value,
    required this.amortization,
    required this.interest,
    required this.status,
  });

  factory FinancingParcel.fromJson(Map<String, dynamic> json) {
    return FinancingParcel(
      id: json['idParcela'] ?? 0,
      number: json['numeroParcela'] ?? 0,
      dueDate: json['dataVencimento'] != null ? DateTime.tryParse(json['dataVencimento']) : null,
      value: _parseDouble(json['valor']),
      amortization: _parseDouble(json['valorAmortizacao']),
      interest: _parseDouble(json['valorJuros']),
      status: json['status'] ?? 'aberta',
    );
  }
}

class Financing {
  final int id;
  final String title;
  final String institution;
  final double totalAmount;
  final double remainingAmount;
  final int totalInstallments;
  final int paidInstallments;
  final double interestRate;
  final String system; // PRICE, SAC
  final DateTime? startDate;
  final double currentInstallmentValue;
  final DateTime? nextDueDate;
  final List<FinancingParcel> parcels;

  Financing({
    required this.id,
    required this.title,
    required this.institution,
    required this.totalAmount,
    required this.remainingAmount,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.interestRate,
    required this.system,
    this.startDate,
    required this.currentInstallmentValue,
    this.nextDueDate,
    this.parcels = const [],
  });

  // Getters para UI
  double get progress => totalAmount > 0 ? (totalAmount - remainingAmount) / totalAmount : 0.0;
  int get remainingInstallments => totalInstallments - paidInstallments;

  factory Financing.fromJson(Map<String, dynamic> json) {
    var list = json['parcelas'] as List? ?? [];
    List<FinancingParcel> parcelList = list.map((i) => FinancingParcel.fromJson(i)).toList();

    return Financing(
      id: json['idFinanciamento'] ?? 0,
      title: json['titulo'] ?? 'Financiamento',
      institution: json['instituicao'] ?? '',
      totalAmount: _parseDouble(json['valorTotal']),
      remainingAmount: _parseDouble(json['valorRestante']),
      totalInstallments: json['numeroParcelas'] ?? 0,
      paidInstallments: json['parcelasPagas'] ?? 0,
      interestRate: _parseDouble(json['taxaJurosMensal']),
      system: json['sistemaAmortizacao'] ?? 'PRICE',
      startDate: json['dataInicio'] != null ? DateTime.tryParse(json['dataInicio']) : null,
      currentInstallmentValue: _parseDouble(json['valorParcelaAtual']),
      nextDueDate: json['proximoVencimento'] != null ? DateTime.tryParse(json['proximoVencimento']) : null,
      parcels: parcelList,
    );
  }
}

// Helper seguro para converter String/Num para Double
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}