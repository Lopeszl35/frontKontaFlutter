import 'package:flutter/material.dart';
import 'package:konta_app/data/models/credit_card_model.dart';
import 'package:konta_app/data/repositories/credit_card_repository.dart'; // Atenção ao caminho correto

class CreditCardController extends ChangeNotifier {
  final _repository = CreditCardRepository();
  
  bool isLoading = false;
  String? error;
  
  // Lista de cartões (Tela Principal)
  List<CreditCardModel> cards = [];
  
  // Detalhes (Tela de Detalhe)
  CreditCardModel? selectedCard;
  CardOverviewModel? cardOverview; 

  // --- LEITURA (READ) ---

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
    cardOverview = null; // Limpa view anterior para não mostrar dados errados
    isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      cardOverview = await _repository.getCardOverview(
        token, userId, card.uuid, now.month, now.year
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

  // --- ESCRITA (WRITE - NOVAS FUNÇÕES) ---

  // 1. Criar
  Future<bool> addCard(BuildContext context, String token, int userId, Map<String, dynamic> cardData) async {
    return _performAction(() => _repository.createCard(token, userId, cardData), token, userId);
  }

  // 2. Editar
  Future<bool> editCard(String token, int userId, String uuid, Map<String, dynamic> cardData) async {
    return _performAction(() => _repository.editCard(token, userId, uuid, cardData), token, userId);
  }

  // 3. Excluir
  Future<bool> deleteCard(String token, int userId, String uuid) async {
    final success = await _performAction(() => _repository.deleteCard(token, userId, uuid), token, userId);
    if (success) clearSelection(); // Se deletou, volta pra lista
    return success;
  }

  // 4. Ativar/Desativar (Bloquear)
  Future<bool> toggleActive(String token, int userId, String uuid, bool novoEstado) async {
    // Apenas executa, o fetchCards no final do _performAction atualiza a UI
    return _performAction(
      () => _repository.toggleActive(token, userId, uuid, novoEstado), 
      token, userId
    );
  }

  // 5. Pagar Fatura
  Future<bool> payInvoice(String token, int userId, int cardId, double valor) async {
    isLoading = true;
    notifyListeners();
    try {
      final now = DateTime.now();
      final success = await _repository.payInvoice(token, userId, cardId, valor, now.month, now.year);
      
      if (success && selectedCard != null) {
        // Se pagou, recarrega os detalhes da fatura para atualizar os valores na tela
        await selectCard(token, userId, selectedCard!);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Erro pagar fatura: $e");
      error = "Falha no pagamento.";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 6. Adicionar Gasto Manual
  Future<bool> addTransaction(String token, int userId, String uuid, Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();
    try {
      final success = await _repository.addCardExpense(token, userId, uuid, data);
      
      if (success && selectedCard != null) {
        // Recarrega a fatura para mostrar o novo gasto
        await selectCard(token, userId, selectedCard!);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Erro add gasto cartão: $e");
      error = "Falha ao adicionar gasto.";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- HELPER PRIVADO (DRY - Don't Repeat Yourself) ---
  // Executa uma ação no repositório e, se der certo, recarrega a lista de cartões
  Future<bool> _performAction(Future<bool> Function() action, String token, int userId) async {
    isLoading = true;
    notifyListeners();
    
    try {
      final success = await action();
      if (success) {
        await fetchCards(token, userId); // Atualiza a lista para refletir mudanças
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Erro na operação: $e");
      error = "Operação falhou.";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}