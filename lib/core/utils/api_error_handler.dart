import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiErrorHandler {
  /// Verifica a resposta HTTP. Se o status for de erro (>= 300),
  /// processa o JSON do backend e lança uma Exception com a mensagem formatada.
  static void check(http.Response response) {
    // 200-299: Sucesso (Não faz nada, deixa o fluxo seguir)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String errorMessage = "Erro desconhecido (${response.statusCode})";

    try {
      // Tenta decodificar o corpo da resposta
      final Map<String, dynamic> errorJson = jsonDecode(response.body);

      // 1. Prioridade: Mensagem principal ("message")
      if (errorJson['message'] != null && errorJson['message'].toString().isNotEmpty) {
        errorMessage = errorJson['message'];
      }

      // 2. Detalhes extras ("details": ["Campo x inválido"])
      if (errorJson['details'] != null && (errorJson['details'] as List).isNotEmpty) {
        final details = (errorJson['details'] as List).join(', ');
        errorMessage += ": $details";
      }

      // 3. Tratamento para erros aninhados (ex: INTERNAL_SERVER_ERROR que devolve o body original)
      if (errorJson['error'] != null && errorJson['error'] is Map) {
        final nestedError = errorJson['error'];
        // Às vezes o backend aninha a mensagem real dentro de 'body' ou 'message' do objeto error
        if (nestedError['message'] != null) {
           errorMessage += " - ${nestedError['message']}";
        }
      }

    } catch (e) {
      // Se o JSON estiver quebrado ou for HTML (erro 500 do Nginx/Proxy), mantém o erro genérico
      print("Erro ao parsear erro do backend: $e");
    }

    // Lança a exceção para ser capturada pelo Controller ou Service
    throw Exception(errorMessage);
  }
}