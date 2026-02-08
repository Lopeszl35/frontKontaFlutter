import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:konta_app/core/config/env.dart'; 
import 'package:konta_app/data/models/credit_card_model.dart';

class CreditCardRepository {
  // Pega a URL dinâmica do Env
  final String _baseUrl = Env.apiUrl; 

  // Headers Padrão
  Map<String, String> _headers(String token) => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };

  // 1. GET: Listar todos os cartões
  Future<List<CreditCardModel>> getAllCards(String token, int userId) async {
    final uri = Uri.parse('$_baseUrl/api/cartoes/$userId');
    
    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => CreditCardModel.fromJson(json)).toList();
    } else {
      throw Exception('Erro ${response.statusCode}: ${response.body}');
    }
  }

  // 2. GET: Visão Geral (Detalhes do Cartão)
  Future<CardOverviewModel> getCardOverview(String token, int userId, String cardUuid, int month, int year) async {
    final uri = Uri.parse(
      '$_baseUrl/api/getCartoesVisaoGeral/$userId?ano=$year&mes=$month&cartao_uuid=$cardUuid'
    );

    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CardOverviewModel.fromJson(data);
    } else {
      throw Exception('Erro ao carregar detalhes: ${response.statusCode}');
    }
  }

  // 3. POST: Criar Cartão
  Future<bool> createCard(String token, int userId, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl/api/criarCartao/$userId');

    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(body),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // 4. POST: Pagar Fatura
  Future<bool> payInvoice(String token, int userId, int cardId, double value, int month, int year) async {
    final uri = Uri.parse('$_baseUrl/api/cartoes/$userId/$cardId/pagarFatura');

    final body = {
      "valorPagamento": value, // CORRIGIDO: Backend espera 'valorPagamento', não 'valorPagemto'
      "ano": year,
      "mes": month
    };

    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }

  // 5. PUT: Editar Cartão
  Future<bool> editCard(String token, int userId, String cardUuid, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl/editarCartoes/$userId/$cardUuid');

    final response = await http.put(
      uri,
      headers: _headers(token),
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }

  // 6. DELETE: Excluir Cartão
  Future<bool> deleteCard(String token, int userId, String cardUuid) async {
    final uri = Uri.parse('$_baseUrl/cartoes/$userId/$cardUuid');

    final response = await http.delete(uri, headers: _headers(token));

    return response.statusCode == 200;
  }

  // 7. PATCH: Ativar/Desativar Cartão
  Future<bool> toggleActive(String token, int userId, String cardUuid, bool ativar) async {
    // A rota usa query param ?ativar=true/false
    final uri = Uri.parse('$_baseUrl/cartoes/$userId/$cardUuid/ativar?ativar=$ativar');

    final response = await http.patch(uri, headers: _headers(token));

    return response.statusCode == 200;
  }

  // 8. POST: Adicionar Gasto Manual no Cartão
  Future<bool> addCardExpense(String token, int userId, String cardUuid, Map<String, dynamic> dadosLancamento) async {
    final uri = Uri.parse('$_baseUrl/cartoes/$userId/$cardUuid/lancamentos');

    final response = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(dadosLancamento),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}