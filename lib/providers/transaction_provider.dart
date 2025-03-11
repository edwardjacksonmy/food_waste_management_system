// transaction_provider.dart
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService;

  List<Transaction> _transactions = [];
  Transaction? _selectedTransaction;
  bool _isLoading = false;
  String? _error;

  TransactionProvider(this._transactionService);

  List<Transaction> get transactions => _transactions;
  List<Transaction> get pendingTransactions =>
      _transactions
          .where(
            (t) =>
                t.status == TransactionStatus.requested ||
                t.status == TransactionStatus.confirmed,
          )
          .toList();

  List<Transaction> get completedTransactions =>
      _transactions
          .where((t) => t.status == TransactionStatus.completed)
          .toList();

  Transaction? get selectedTransaction => _selectedTransaction;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTransactions(String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _transactionService.getMyTransactions(status);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Transaction?> requestPickup(
    int donationId,
    DateTime scheduledPickupTime,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final transaction = await _transactionService.requestPickup(
        donationId,
        scheduledPickupTime,
      );
      _transactions.add(transaction);
      _isLoading = false;
      notifyListeners();
      return transaction;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> confirmPickup(int transactionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final transaction = await _transactionService.confirmPickup(
        transactionId,
      );
      _updateTransaction(transaction);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectPickup(int transactionId, String feedback) async {
    _isLoading = true;
    notifyListeners();

    try {
      final transaction = await _transactionService.rejectPickup(
        transactionId,
        feedback,
      );
      _updateTransaction(transaction);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> completePickup(int transactionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final transaction = await _transactionService.completePickup(
        transactionId,
      );
      _updateTransaction(transaction);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> leaveFeedback(
    int transactionId,
    int rating,
    String feedback,
    bool isDonor,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final transaction = await _transactionService.leaveFeedback(
        transactionId,
        rating,
        feedback,
        isDonor,
      );
      _updateTransaction(transaction);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _updateTransaction(Transaction transaction) {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index >= 0) {
      _transactions[index] = transaction;
    } else {
      _transactions.add(transaction);
    }

    if (_selectedTransaction?.id == transaction.id) {
      _selectedTransaction = transaction;
    }
  }

  Future<void> getTransaction(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedTransaction = await _transactionService.getTransaction(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void selectTransaction(Transaction transaction) {
    _selectedTransaction = transaction;
    notifyListeners();
  }

  void clearSelectedTransaction() {
    _selectedTransaction = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
