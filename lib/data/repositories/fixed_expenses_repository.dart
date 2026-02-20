import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:konta_app/core/config/env.dart';
import 'package:konta_app/core/utils/api_error_handler.dart';
import 'package:konta_app/data/models/fixed_expense_model.dart';

class FixedExpensesRepository {
  
  // 1. Obter Dados da Tela
  Future<FixedExpensesScreenData> getScreenData(String token, int userId) async {
    // Rota: /getTelaGastosFixos/46
    final uri = Uri.parse('${Env.apiUrl}/getTelaGastosFixos/$userId');

    final response = await http.get(uri, headers: _headers(token));
    ApiErrorHandler.check(response);

    return FixedExpensesScreenData.fromJson(jsonDecode(response.body));
  }

  // 2. Adicionar Gasto Fixo
  Future<void> addExpense(String token, int userId, Map<String, dynamic> gastoFixoData) async {
    // Rota: /addGastoFixo?id_usuario=46
    final uri = Uri.parse('${Env.apiUrl}/addGastoFixo?id_usuario=$userId');

    // O backend exige o wrapper "gastoFixo"
    final body = jsonEncode({"gastoFixo": gastoFixoData});

    final response = await http.post(uri, headers: _headers(token), body: body);
    ApiErrorHandler.check(response);
  }

  // 3. Ativar/Desativar
  Future<void> toggleActive(String token, int userId, int expenseId, bool isActive) async {
    // Rota: /gastosFixos/8/ativo?id_usuario=15
    final uri = Uri.parse('${Env.apiUrl}/gastosFixos/$expenseId/ativo?id_usuario=$userId');

    final body = jsonEncode({"ativo": isActive});

    final response = await http.put(uri, headers: _headers(token), body: body); // ou PATCH dependendo do seu Node.js
    ApiErrorHandler.check(response);
  }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}