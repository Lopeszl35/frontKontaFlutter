import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:konta_app/data/models/user_model.dart';
import 'package:konta_app/core/config/env.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuth => _user != null;

  final String _baseUrl = Env.apiUrl;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('$_baseUrl/loginUser');      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "senha": password // Seu backend espera "senha", não "password"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = UserModel.fromJson(data, data['token']);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Tratamento de erro simples
        throw Exception("Credenciais inválidas");
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

 
 Future<void> register({
    required String nome,
    required String email,
    required String password,
    required String confirmPassword,
    required double salario,
    required double saldoAtual,
    required String perfil,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (password != confirmPassword) {
        throw Exception("As senhas não conferem.");
      }

      final url = Uri.parse('$_baseUrl/createUser');
      
      final Map<String, dynamic> payload = {
        "user": {
          "nome": nome,
          "senha_hash": password,
          "email": email,
          "perfil_financeiro": perfil,
          "salario_mensal": salario.toString(),
          "saldo_inicial": saldoAtual.toString(),
          "saldo_atual": saldoAtual.toString()
        }
      };

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload),
      );

      final body = jsonDecode(response.body);

      // SUCESSO (200 ou 201)
      if (response.statusCode == 201 || response.statusCode == 200) {
        final userData = body['data'];
        final String tokenReal = userData['token']; 

        // Montamos o objeto para o UserModel
        final jsonParaModel = {
          "user": {
             "id_usuario": userData['id_usuario'],
             "nome": userData['nome'],
             "email": userData['email'],
             "perfil_financeiro": userData['perfil_financeiro'],
             "salario_mensal": double.tryParse(userData['salario_mensal'].toString()) ?? 0.0,
             "saldo_atual": double.tryParse(userData['saldo_atual'].toString()) ?? 0.0,
             "saldo_inicial": double.tryParse(userData['saldo_inicial'].toString()) ?? 0.0,
          }
        };
        _user = UserModel.fromJson(jsonParaModel, tokenReal);
        
        _isLoading = false;
        notifyListeners();
      } 
      
      // ERRO DE VALIDAÇÃO (400)
      else if (response.statusCode == 400) {
        final List? listaErros = body['details'] ?? body['erros'];
        if (listaErros != null && listaErros.isNotEmpty) {
          throw Exception(listaErros[0]['msg']);
        } else {
          throw Exception(body['message'] ?? "Dados inválidos.");
        }
      }
      
      // OUTROS ERROS
      else {
        throw Exception(body['message'] ?? 'Erro no servidor (${response.statusCode})');
      }

    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}