import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:konta_app/core/config/env.dart'; 
import 'package:konta_app/data/models/credit_card_model.dart';
// Importe o novo utilitário
import 'package:konta_app/core/utils/api_error_handler.dart';

class CreditCardRepository {
  final String _baseUrl = Env.apiUrl; 

  Map<String, String> _headers(String token) => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };

  // 1. GET: Listar todos os cartões
  Future<List<CreditCardModel>> getAllCards(String token, int userId) async {
    final uri = Uri.parse('$_baseUrl/api/cartoes/$userId');
    final response = await http.get(uri, headers: _headers(token));

    ApiErrorHandler.check(response); // <-- USO CENTRALIZADO

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => CreditCardModel.fromJson(json)).toList();
  }

  // 2. GET: Visão Geral
  Future<CardOverviewModel> getCardOverview(String token, int userId, String cardUuid, int month, int year) async {
    final uri = Uri.parse('$_baseUrl/api/getCartoesVisaoGeral/$userId?ano=$year&mes=$month&cartao_uuid=$cardUuid');
    final response = await http.get(uri, headers: _headers(token));

    ApiErrorHandler.check(response);

    return CardOverviewModel.fromJson(jsonDecode(response.body));
  }

  // 3. POST: Criar Cartão
  Future<bool> createCard(String token, int userId, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl/api/criarCartao/$userId');
    final response = await http.post(uri, headers: _headers(token), body: jsonEncode(body));

    ApiErrorHandler.check(response);
    return true;
  }

  // 4. POST: Pagar Fatura
  Future<bool> payInvoice(String token, int userId, int cardId, double valor, int month, int year) async {
    final uri = Uri.parse('$_baseUrl/api/cartoes/$userId/$cardId/pagarFatura');
    final body = {
      "valorPagamento": valor,
      "ano": year,
      "mes": month
    };
    final response = await http.post(uri, headers: _headers(token), body: jsonEncode(body));

    ApiErrorHandler.check(response);
    return true;
  }

  // 5. PUT: Editar Cartão
  Future<bool> editCard(String token, int userId, String cardUuid, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl/api/editarCartoes/$userId/$cardUuid'); 
    final response = await http.put(uri, headers: _headers(token), body: jsonEncode(body));

    ApiErrorHandler.check(response);
    return true;
  }

  // 6. DELETE: Excluir Cartão
  Future<bool> deleteCard(String token, int userId, String cardUuid) async {
    final uri = Uri.parse('$_baseUrl/api/cartoes/$userId/$cardUuid');
    final response = await http.delete(uri, headers: _headers(token));

    ApiErrorHandler.check(response);
    return true;
  }

  // 7. PATCH: Ativar/Desativar
  Future<bool> toggleActive(String token, int userId, String cardUuid, bool ativar) async {
    final uri = Uri.parse('$_baseUrl/api/cartoes/$userId/$cardUuid/ativar?ativar=$ativar');
    final response = await http.patch(uri, headers: _headers(token));

    ApiErrorHandler.check(response);
    return true;
  }

  // 8. POST: Gasto Manual
  Future<bool> addCardExpense(String token, int userId, String cardUuid, Map<String, dynamic> dadosLancamento) async {
    final uri = Uri.parse('$_baseUrl/api/cartoes/$userId/$cardUuid/lancamentos');
    final response = await http.post(uri, headers: _headers(token), body: jsonEncode(dadosLancamento));

    ApiErrorHandler.check(response);
    return true;
  }
}