import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:konta_app/core/config/env.dart';
import 'package:konta_app/data/models/category_model.dart';
import 'package:konta_app/data/models/card_model.dart';
import 'package:konta_app/core/utils/konta_snack.dart';

class VariableExpensesController extends ChangeNotifier {
  bool isLoading = false;
  
  // --- ESTADO DA TELA ---
  double limiteMensal = 0.0;
  double gastoTotalMes = 0.0;
  
  List<CategoryModel> categoriasAtivas = [];
  List<CategoryModel> categoriasInativas = [];
  List<CardModel> userCards = []; // Cache de cartões para o modal

  final String _baseUrl = Env.apiUrl;

  Map<String, String> _headers(String token) {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  // ===========================================================================
  // 1. CARREGAMENTO DE DADOS (DASHBOARD DA TELA)
  // ===========================================================================

  Future<void> fetchAllData(String token, int userId, {int mes = 1, int ano = 2026}) async {
    isLoading = true;
    notifyListeners();

    try {
      // Paralelismo: Busca Limite, Categorias e Cartões ao mesmo tempo para ser rápido
      await Future.wait([
        _fetchLimite(token, userId, mes, ano),
        _fetchCategoriasAtivas(token, userId),
        fetchCards(token, userId), // Já deixa os cartões prontos para o uso
      ]);
    } catch (e) {
      print("Erro ao carregar dados: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchLimite(String token, int userId, int mes, int ano) async {
    final url = Uri.parse('$_baseUrl/getLimiteGastoMes?id_usuario=$userId&ano=$ano&mes=$mes');
    try {
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode == 200) {
        final List<dynamic> lista = jsonDecode(response.body);
        if (lista.isNotEmpty) {
          final dados = lista[0];
          limiteMensal = double.tryParse(dados['limiteGastoMes'].toString()) ?? 0.0;
        }
      }
    } catch (e) {
      print("Erro limite: $e");
    }
  }

  Future<void> _fetchCategoriasAtivas(String token, int userId) async {
    final url = Uri.parse('$_baseUrl/getCategoriasAtivas/$userId');
    try {
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode == 200) {
        final List<dynamic> lista = jsonDecode(response.body);
        categoriasAtivas = lista.map((e) => CategoryModel.fromJson(e)).toList();
        
        // Calcula o total gasto no mês somando as categorias
        gastoTotalMes = categoriasAtivas.fold(0.0, (soma, categoria) {
          return soma + categoria.totalGasto;
        });
      }
    } catch (e) {
      print("Erro categorias: $e");
    }
  }

  // Busca Cartões (para o Modal de Adicionar Gasto)
  Future<void> fetchCards(String token, int userId) async {
    final url = Uri.parse('$_baseUrl/api/cartoes/$userId');
    try {
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode == 200) {
        final List<dynamic> lista = jsonDecode(response.body);
        userCards = lista.map((e) => CardModel.fromJson(e)).toList();
        notifyListeners(); // Atualiza dropdown se estiver aberto
      }
    } catch (e) {
      print("Erro cartões: $e");
    }
  }

  // ===========================================================================
  // 2. GESTÃO DE CATEGORIAS (CRUD)
  // ===========================================================================

  // CRIAR
  Future<bool> createCategory(BuildContext context, String token, int userId, String nome, double limite) async {
    final url = Uri.parse('$_baseUrl/criarCategoria/$userId');
    try {
      final body = jsonEncode({
        "categoria": {
          "nome": nome,
          "limite": limite.toString()
        }
      });
      final response = await http.post(url, headers: _headers(token), body: body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        KontaSnack.show(context, title: "Sucesso", message: "Categoria criada!");
        await _fetchCategoriasAtivas(token, userId);
        return true;
      }
      throw Exception("Status ${response.statusCode}");
    } catch (e) {
      KontaSnack.show(context, type: KontaSnackType.error, title: "Erro", message: "Falha ao criar categoria");
      return false;
    }
  }

  // EDITAR (NOVO!)
  Future<bool> updateCategory(BuildContext context, String token, int userId, int catId, String nome, double limite) async {
    // Rota: localhost:8080/updateCategoria?id_categoria=7
    final url = Uri.parse('$_baseUrl/updateCategoria?id_categoria=$catId');
    
    try {
      final body = jsonEncode({
        "categoria": {
          "nome": nome,
          "limite": limite.toString()
        }
      });

      // Assumindo POST conforme padrão do seu backend (embora PUT seja o padrão REST)
      final response = await http.post(url, headers: _headers(token), body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        KontaSnack.show(context, title: "Sucesso", message: "Categoria atualizada!");
        await _fetchCategoriasAtivas(token, userId);
        return true;
      } else {
        throw Exception("Status ${response.statusCode}");
      }
    } catch (e) {
      KontaSnack.show(context, type: KontaSnackType.error, title: "Erro", message: "Falha ao editar categoria");
      return false;
    }
  }

  // DELETAR (Arquivar)
  Future<void> deleteCategory(BuildContext context, String token, int userId, int catId) async {
    final url = Uri.parse('$_baseUrl/deleteCategorias?id_categoria=$catId');
    try {
      final response = await http.delete(url, headers: _headers(token));
      
      if (response.statusCode == 200) {
        KontaSnack.show(context, title: "Categoria arquivada");
        await _fetchCategoriasAtivas(token, userId);
      }
    } catch (e) {
      KontaSnack.show(context, type: KontaSnackType.error, title: "Erro ao arquivar");
    }
  }

  // ===========================================================================
  // 3. GESTÃO DE INATIVAS E LIMITE GLOBAL
  // ===========================================================================

  Future<void> fetchInativas(String token, int userId) async {
    final url = Uri.parse('$_baseUrl/getCategoriasInativas/$userId');
    try {
      final response = await http.get(url, headers: _headers(token));
      if (response.statusCode == 200) {
        final List<dynamic> lista = jsonDecode(response.body);
        categoriasInativas = lista.map((e) => CategoryModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Erro inativas: $e");
    }
  }

  Future<void> reactivateCategory(BuildContext context, String token, int userId, int catId) async {
    final url = Uri.parse('$_baseUrl/categorias/$catId/reativar?id_usuario=$userId');
    try {
      final response = await http.patch(url, headers: _headers(token));
      if (response.statusCode == 200) {
        KontaSnack.show(context, title: "Categoria restaurada!");
        await fetchInativas(token, userId);
        await _fetchCategoriasAtivas(token, userId);
      }
    } catch (e) {
      KontaSnack.show(context, type: KontaSnackType.error, title: "Erro ao restaurar");
    }
  }

  Future<void> updateMonthlyLimit(BuildContext context, String token, int userId, double novoLimite) async {
    final url = Uri.parse('$_baseUrl/configGastoLimiteMes/$userId');
    try {
      final body = jsonEncode({
        "dadosMes": {
          "limiteGastoMes": novoLimite.toString(),
          "ano": "2026",
          "mes": "1"
        }
      });
      final response = await http.post(url, headers: _headers(token), body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        limiteMensal = novoLimite;
        KontaSnack.show(context, title: "Meta atualizada!");
        notifyListeners();
      }
    } catch (e) {
      KontaSnack.show(context, type: KontaSnackType.error, title: "Erro ao atualizar meta");
    }
  }

  // ===========================================================================
  // 4. ADICIONAR GASTO (TRANSAÇÃO)
  // ===========================================================================

  Future<bool> addExpense({
    required BuildContext context,
    required String token,
    required int userId,
    required int categoriaId,
    required double valor,
    required String descricao,
    required DateTime data,
    required String formaPagamento, // "DINHEIRO", "PIX", "CREDITO", "DEBITO"
    String? uuidCartao,
  }) async {
    
    // Validação de negócio: Crédito exige cartão
    if (formaPagamento == 'CREDITO' && (uuidCartao == null || uuidCartao.isEmpty)) {
      KontaSnack.show(context, type: KontaSnackType.warning, title: "Atenção", message: "Selecione o cartão de crédito.");
      return false;
    }

    final url = Uri.parse('$_baseUrl/addGasto?id_usuario=$userId');
    final String dataFormatada = DateFormat('yyyy/MM/dd').format(data);

    try {
      // Monta o payload exato que o backend espera
      final Map<String, dynamic> dadosGasto = {
        "valor": valor.toString(),
        "data_gasto": dataFormatada,
        "descricao": descricao,
        "id_categoria": categoriaId.toString(),
        "forma_pagamento": formaPagamento,
      };

      if (formaPagamento == 'CREDITO') {
        dadosGasto["uuidCartao"] = uuidCartao;
      }

      final body = jsonEncode({ "gastos": dadosGasto });

      final response = await http.post(url, headers: _headers(token), body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        KontaSnack.show(context, title: "Sucesso", message: "Gasto registrado!");
        await _fetchCategoriasAtivas(token, userId); // Atualiza os saldos na tela
        return true;
      } else {
        throw Exception("Status ${response.statusCode}");
      }
    } catch (e) {
      KontaSnack.show(context, type: KontaSnackType.error, title: "Erro", message: "Não foi possível registrar o gasto.");
      return false;
    }
  }
}