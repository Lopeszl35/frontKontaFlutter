import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:konta_app/data/models/dashboard_model.dart';
import 'package:konta_app/core/config/env.dart';

class DashboardController extends ChangeNotifier {
  DashboardModel? data;
  bool isLoading = false;
  String? error;

  final String _baseUrl = Env.apiUrl;

  Future<void> fetchDashboard(String token, {int mes = 1, int ano = 2026}) async {
    isLoading = true;
    error = null;
    notifyListeners(); // Avisa a tela para mostrar loading

    try {
      final url = Uri.parse('$_baseUrl/api/dashboard/getSummary?mes=$mes&ano=$ano');
      
      print("📡 Buscando Dashboard: $url");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token" // O PULO DO GATO: Enviando o Token
        },
      );

      print("🔙 Status Dash: ${response.statusCode}");
      print("🔙 Body Dash: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        data = DashboardModel.fromJson(json);
      } else {
        error = "Falha ao carregar dashboard (${response.statusCode})";
      }
    } catch (e) {
      print("❌ Erro Dash: $e");
      error = "Erro de conexão: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}