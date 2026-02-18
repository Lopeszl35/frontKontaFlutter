import 'package:flutter/material.dart';
import 'package:konta_app/data/models/financing_model.dart';
import 'package:konta_app/data/repositories/financing_repository.dart';

class FinancingController extends ChangeNotifier {
  final FinancingRepository _repository = FinancingRepository();

  bool isLoading = false;
  String? error;

  FinancingSummary? summary;
  List<Financing> financings = [];

  // Método para buscar dados iniciais
  Future<void> fetchAll(String token, int userId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _repository.getActiveFinancings(token, userId);
      summary = result['summary'];
      financings = result['list'];
    } catch (e) {
      error = e.toString().replaceAll("Exception:", "").trim();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Método para Pagar Parcela
  Future<bool> payParcel(String token, int userId, int parcelId) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repository.payParcel(token, userId, parcelId);
      // Recarrega os dados para atualizar a tela
      await fetchAll(token, userId);
      return true;
    } catch (e) {
      error = e.toString().replaceAll("Exception:", "").trim();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para Criar
  Future<bool> create(String token, int userId, Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repository.createFinancing(token, userId, data);
      await fetchAll(token, userId);
      return true;
    } catch (e) {
      error = e.toString().replaceAll("Exception:", "").trim();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Método para Amortizar
  Future<bool> amortize(String token, int userId, int financingId, double amount) async {
    isLoading = true;
    notifyListeners();
    try {
      await _repository.amortize(token, userId, financingId, amount);
      await fetchAll(token, userId);
      return true;
    } catch (e) {
      error = e.toString().replaceAll("Exception:", "").trim();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String token, int userId, int financingId) async {
    isLoading = true;
    notifyListeners();
    
    try {
      await _repository.deleteFinancing(token, userId, financingId);
      await fetchAll(token, userId); // Atualiza a lista após deletar
      return true;
    } catch (e) {
      error = e.toString().replaceAll("Exception:", "").trim();
      isLoading = false; 
      notifyListeners();
      return false;
    }
  }
}