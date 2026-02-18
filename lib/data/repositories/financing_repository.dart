import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:konta_app/core/config/env.dart'; // Sua classe de config de URL
import 'package:konta_app/core/utils/api_error_handler.dart'; // O utilitário que você passou
import 'package:konta_app/data/models/financing_model.dart';

class FinancingRepository {
  
  // 1. Listar Financiamentos
  Future<Map<String, dynamic>> getActiveFinancings(String token, int userId) async {
    final uri = Uri.parse('${Env.apiUrl}/api/financiamentos/financiamentosAtivos?id_usuario=$userId');

    final response = await http.get(
      uri,
      headers: _authHeader(token),
    );

    ApiErrorHandler.check(response); // Lança exception se erro

    final data = jsonDecode(response.body);
    
    return {
      'summary': data['resumo'] != null ? FinancingSummary.fromJson(data['resumo']) : null,
      'list': (data['financiamentos'] as List? ?? []).map((i) => Financing.fromJson(i)).toList(),
    };
  }

  // 2. Criar Financiamento
  Future<void> createFinancing(String token, int userId, Map<String, dynamic> payload) async {
    final uri = Uri.parse('${Env.apiUrl}/api/financiamentos/criarFinanciamento?id_usuario=$userId');

    final response = await http.post(
      uri,
      headers: _authHeader(token),
      body: jsonEncode(payload),
    );

    ApiErrorHandler.check(response);
  }

  // 3. Pagar Parcela
  Future<void> payParcel(String token, int userId, int parcelId) async {
    final uri = Uri.parse('${Env.apiUrl}/api/financiamentos/parcelas/$parcelId/pagar?id_usuario=$userId');

    final response = await http.post(
      uri,
      headers: _authHeader(token),
    );

    ApiErrorHandler.check(response);
  }

  // 4. Amortizar
  Future<void> amortize(String token, int userId, int financingId, double amount) async {
    final uri = Uri.parse('${Env.apiUrl}/api/financiamentos/$financingId/amortizar?id_usuario=$userId');

    final response = await http.post(
      uri,
      headers: _authHeader(token),
      body: jsonEncode({'valorAmortizacao': amount}),
    );

    ApiErrorHandler.check(response);
  }

  // 5. Simular (Retorna dados da simulação)
  Future<Map<String, dynamic>> simulate(String token, Map<String, dynamic> payload) async {
    final uri = Uri.parse('${Env.apiUrl}/api/financiamentos/simular');

    final response = await http.post(
      uri,
      headers: _authHeader(token),
      body: jsonEncode(payload),
    );

    ApiErrorHandler.check(response);
    return jsonDecode(response.body);
  }

  Future<void> deleteFinancing(String token, int userId, int financingId) async {
    final uri = Uri.parse('${Env.apiUrl}/api/financiamentos/deletarFinanciamento/$financingId?id_usuario=$userId');

    final response = await http.delete(
      uri,
      headers: _authHeader(token),
    );

    ApiErrorHandler.check(response);
  }

  Map<String, String> _authHeader(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}