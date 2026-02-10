import 'package:flutter/material.dart';
import 'package:konta_app/data/models/credit_card_model.dart';
import 'package:konta_app/data/repositories/credit_card_repository.dart';

class CreditCardController extends ChangeNotifier {
  final _repository = CreditCardRepository();
  
  bool isLoading = false;
  String? error;
  
  // Lista de cartões
  List<CreditCardModel> cards = [];
  
  // Detalhes
  CreditCardModel? selectedCard;
  CardOverviewModel? cardOverview;
  
  // NOVA VARIÁVEL DE ESTADO: DATA DA FATURA ATUAL
  DateTime currentDate = DateTime.now(); 

  // --- LEITURA ---

  Future<void> fetchCards(String token, int userId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      cards = await _repository.getAllCards(token, userId);
    } catch (e) {
      debugPrint("❌ Erro fetchCards: $e");
      error = "Não foi possível carregar seus cartões.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCard(String token, int userId, CreditCardModel card) async {
    selectedCard = card;
    cardOverview = null;
    currentDate = DateTime.now(); // Reseta para o mês atual ao abrir
    
    await _fetchInvoiceData(token, userId);
  }

  // NOVO MÉTODO: Navegar entre meses
  Future<void> changeInvoiceMonth(String token, int userId, int monthsToAdd) async {
    // Ajusta a data (ex: Jan -> Fev)
    currentDate = DateTime(currentDate.year, currentDate.month + monthsToAdd, 1);
    await _fetchInvoiceData(token, userId);
  }

  // Método privado para buscar dados com base na data atual do controller
  Future<void> _fetchInvoiceData(String token, int userId) async {
    if (selectedCard == null) return;

    isLoading = true;
    notifyListeners();

    try {
      cardOverview = await _repository.getCardOverview(
        token, 
        userId, 
        selectedCard!.uuid, 
        currentDate.month, 
        currentDate.year
      );
    } catch (e) {
      debugPrint("❌ Erro overview: $e");
      error = "Erro ao carregar fatura.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearSelection() {
    selectedCard = null;
    cardOverview = null;
    notifyListeners();
  }

  // --- MÉTODOS DE ESCRITA (Mantidos iguais, com small fix no refresh) ---
  
  Future<bool> addCard(BuildContext context, String token, int userId, Map<String, dynamic> cardData) async {
    return _performAction(() => _repository.createCard(token, userId, cardData), token, userId);
  }

  Future<bool> editCard(String token, int userId, String uuid, Map<String, dynamic> cardData) async {
    return _performAction(() => _repository.editCard(token, userId, uuid, cardData), token, userId);
  }

  Future<bool> deleteCard(String token, int userId, String uuid) async {
    final success = await _performAction(() => _repository.deleteCard(token, userId, uuid), token, userId);
    if (success) clearSelection();
    return success;
  }

  Future<bool> toggleActive(String token, int userId, String uuid, bool novoEstado) async {
    return _performAction(() => _repository.toggleActive(token, userId, uuid, novoEstado), token, userId);
  }

  Future<bool> payInvoice(String token, int userId, int cardId, double valor, int mes, int ano) async {
    isLoading = true;
    error = null; // Limpa erro anterior
    notifyListeners();
    
    try {
      final success = await _repository.payInvoice(token, userId, cardId, valor, mes, ano);
      
      if (success && selectedCard != null) {
        // Recarrega a fatura ATUAL da tela (currentDate)
        await selectCard(token, userId, selectedCard!);
        return true;
      }
      return false;
    } catch (e) {
      // Captura a mensagem exata que veio do Repository (ex: "Valor excede o restante...")
      // Remove o prefixo "Exception: " que o Dart adiciona automaticamente ao converter pra string
      error = e.toString().replaceAll("Exception: ", "");
      debugPrint("❌ Erro pagar fatura: $error");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(String token, int userId, String uuid, Map<String, dynamic> data) async {
    final success = await _repository.addCardExpense(token, userId, uuid, data);
    if (success) await _fetchInvoiceData(token, userId);
    return success;
  }

  Future<bool> _performAction(Future<bool> Function() action, String token, int userId) async {
    isLoading = true;
    notifyListeners();
    try {
      final success = await action();
      if (success) await fetchCards(token, userId);
      return success;
    } catch (e) {
      error = "Operação falhou.";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}