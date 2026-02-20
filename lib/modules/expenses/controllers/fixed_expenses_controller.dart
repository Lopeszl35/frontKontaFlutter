import 'package:flutter/material.dart';
import 'package:konta_app/data/models/fixed_expense_model.dart';
import 'package:konta_app/data/repositories/fixed_expenses_repository.dart';

class FixedExpensesController extends ChangeNotifier {
  final FixedExpensesRepository _repository = FixedExpensesRepository();

  bool isLoading = false;
  String? error;
  
  FixedExpensesScreenData? screenData;
  String activeFilter = 'all';

  // --- MÉTODOS DE API ---

  Future<void> fetchScreenData(String token, int userId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      screenData = await _repository.getScreenData(token, userId);
    } catch (e) {
      error = e.toString().replaceAll("Exception:", "").trim();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExpense(String token, int userId, Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();

    try {
      await _repository.addExpense(token, userId, data);
      await fetchScreenData(token, userId); // Recarrega os totais do backend
      return true;
    } catch (e) {
      error = e.toString().replaceAll("Exception:", "").trim();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleExpense(String token, int userId, int expenseId, bool currentStatus) async {
    // Optimistic UI update (Muda a UI antes da API responder para parecer instantâneo)
    final index = screenData?.lista.indexWhere((e) => e.id == expenseId) ?? -1;
    if (index != -1) {
      // Aviso: Estamos mutando um objeto que idealmente seria imutável, mas para o toggle rápido funciona.
      // O ideal seria criar um .copyWith, mas o fetchScreenData vai sobrescrever tudo em breve.
      notifyListeners(); 
    }

    try {
      await _repository.toggleActive(token, userId, expenseId, !currentStatus);
      await fetchScreenData(token, userId); // Recalcula totais
      return true;
    } catch (e) {
      error = e.toString().replaceAll("Exception:", "").trim();
      await fetchScreenData(token, userId); // Reverte se falhou
      return false;
    }
  }

  // --- MÉTODOS LOCAIS (UI) ---

  void setFilter(String filter) {
    activeFilter = filter;
    notifyListeners();
  }

  List<FixedExpense> get filteredList {
    if (screenData == null) return [];
    if (activeFilter == 'all') return screenData!.lista;
    return screenData!.lista.where((e) => e.categoriaExibicao == activeFilter).toList();
  }
}