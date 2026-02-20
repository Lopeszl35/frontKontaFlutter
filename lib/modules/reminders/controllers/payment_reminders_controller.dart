import 'package:flutter/material.dart';
// --- MODELO ---
class PaymentReminder {
  final String id;
  String description;
  String vendorName;
  double amount;
  String purchaseDate; 
  String dueDate;      
  String paymentMethod; 
  String status;       
  String? notes;
  String? paidAt;

  PaymentReminder({
    required this.id,
    required this.description,
    required this.vendorName,
    required this.amount,
    required this.purchaseDate,
    required this.dueDate,
    required this.paymentMethod,
    this.status = 'pending',
    this.notes,
    this.paidAt,
  });

  PaymentReminder copyWith({
    String? description, String? vendorName, double? amount,
    String? purchaseDate, String? dueDate, String? paymentMethod,
    String? status, String? notes, String? paidAt,
  }) {
    return PaymentReminder(
      id: id,
      description: description ?? this.description,
      vendorName: vendorName ?? this.vendorName,
      amount: amount ?? this.amount,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      dueDate: dueDate ?? this.dueDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}

// --- CONTROLLER (Mock Edition) ---
class PaymentRemindersController extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  List<PaymentReminder> _reminders = [
    PaymentReminder(id: '1', description: 'Bolo de aniversário', vendorName: 'Maria Doces', amount: 150, purchaseDate: '2024-01-10', dueDate: '2024-01-15', paymentMethod: 'pix'),
    PaymentReminder(id: '2', description: 'Marmitas da semana', vendorName: 'Restaurante da Vó', amount: 200, purchaseDate: '2024-01-08', dueDate: '2024-01-12', paymentMethod: 'dinheiro', status: 'paid', paidAt: '2024-01-12'),
    PaymentReminder(id: '3', description: 'Salgados para festa', vendorName: 'Dona Cida Salgados', amount: 320, purchaseDate: '2024-01-20', dueDate: '2025-02-25', paymentMethod: 'pix', notes: 'Pagar até sexta sem falta'),
  ];

  // Filtros Derivados
  List<PaymentReminder> get pending => _reminders.where((r) => r.status == 'pending').toList();
  List<PaymentReminder> get paid => _reminders.where((r) => r.status == 'paid').toList();
  double get totalPending => pending.fold(0, (s, r) => s + r.amount);

  // MÉTODOS DE AÇÃO (Futuramente, aqui você chama o Repository)
  
  Future<bool> markAsPaid(String id) async {
    isLoading = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400)); // Simulando API
    
    final i = _reminders.indexWhere((r) => r.id == id);
    if (i != -1) {
      _reminders[i].status = 'paid';
      _reminders[i].paidAt = DateTime.now().toIso8601String();
    }
    
    isLoading = false; notifyListeners();
    return true;
  }

  Future<bool> deleteReminder(String id) async {
    isLoading = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400)); // Simulando API
    
    _reminders.removeWhere((r) => r.id == id);
    
    isLoading = false; notifyListeners();
    return true;
  }

  Future<bool> addReminder(PaymentReminder reminder) async {
    isLoading = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600)); // Simulando API
    
    _reminders.add(reminder);
    
    isLoading = false; notifyListeners();
    return true;
  }

  Future<bool> updateReminder(PaymentReminder reminder) async {
    isLoading = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600)); // Simulando API
    
    final i = _reminders.indexWhere((r) => r.id == reminder.id);
    if (i != -1) _reminders[i] = reminder;
    
    isLoading = false; notifyListeners();
    return true;
  }
}