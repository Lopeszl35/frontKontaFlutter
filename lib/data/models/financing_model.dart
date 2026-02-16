class Financing {
  final String id;
  final String name;
  final String type; 
  final double totalAmount;
  final double remainingAmount;
  final double monthlyPayment;
  final double interestRate;
  final int totalInstallments;
  final int paidInstallments;
  final String startDate;
  final String bank;

  const Financing({
    required this.id,
    required this.name,
    required this.type,
    required this.totalAmount,
    required this.remainingAmount,
    required this.monthlyPayment,
    required this.interestRate,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.startDate,
    required this.bank,
  });

  int get remainingInstallments => totalInstallments - paidInstallments;
  double get progress => totalInstallments > 0 ? (paidInstallments / totalInstallments) : 0.0;
}

// Mock Data
final List<Financing> mockFinancings = [
  const Financing(id: '1', name: 'Honda Civic 2023', type: 'vehicle', totalAmount: 120000, remainingAmount: 78000, monthlyPayment: 2850, interestRate: 1.29, totalInstallments: 48, paidInstallments: 15, startDate: '2024-10-01', bank: 'Banco Honda'),
  const Financing(id: '2', name: 'Apartamento Centro', type: 'property', totalAmount: 450000, remainingAmount: 380000, monthlyPayment: 3200, interestRate: 0.85, totalInstallments: 360, paidInstallments: 24, startDate: '2024-01-15', bank: 'Caixa Econômica'),
  const Financing(id: '3', name: 'Empréstimo Reforma', type: 'personal', totalAmount: 50000, remainingAmount: 35000, monthlyPayment: 1800, interestRate: 1.99, totalInstallments: 36, paidInstallments: 10, startDate: '2025-03-01', bank: 'Nubank'),
];