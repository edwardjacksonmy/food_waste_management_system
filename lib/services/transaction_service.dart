// transaction_service.dart
import '../models/transaction.dart';

class TransactionService {
  final ApiService _apiService;

  TransactionService(this._apiService);

  // Request a donation pickup
  Future<Transaction> requestPickup(
    int donationId,
    DateTime scheduledPickupTime,
  ) async {
    final data = {
      'donation_id': donationId,
      'scheduled_pickup_time': scheduledPickupTime.toIso8601String(),
    };

    final response = await _apiService.post('transactions/request', data);
    return Transaction.fromJson(response);
  }

  // Confirm a pickup request (donor)
  Future<Transaction> confirmPickup(int transactionId) async {
    final response = await _apiService.put(
      'transactions/$transactionId/confirm',
      {},
    );

    return Transaction.fromJson(response);
  }

  // Reject a pickup request (donor)
  Future<Transaction> rejectPickup(int transactionId, String feedback) async {
    final data = {'donor_feedback': feedback};

    final response = await _apiService.put(
      'transactions/$transactionId/reject',
      data,
    );

    return Transaction.fromJson(response);
  }

  // Complete a pickup (recipient)
  Future<Transaction> completePickup(int transactionId) async {
    final response = await _apiService.put(
      'transactions/$transactionId/complete',
      {},
    );

    return Transaction.fromJson(response);
  }

  // Leave feedback (both donor and recipient)
  Future<Transaction> leaveFeedback(
    int transactionId,
    int rating,
    String feedback,
    bool isDonor,
  ) async {
    final data = {
      isDonor ? 'recipient_rating' : 'donor_rating': rating,
      isDonor ? 'donor_feedback' : 'recipient_feedback': feedback,
    };

    final response = await _apiService.put(
      'transactions/$transactionId/feedback',
      data,
    );

    return Transaction.fromJson(response);
  }

  // Get transaction details
  Future<Transaction> getTransaction(int transactionId) async {
    final response = await _apiService.get('transactions/$transactionId');
    return Transaction.fromJson(response);
  }

  // Get all transactions for the current user
  Future<List<Transaction>> getMyTransactions(String status) async {
    final response = await _apiService.get(
      'transactions/my-transactions?status=$status',
    );

    return (response as List)
        .map((item) => Transaction.fromJson(item))
        .toList();
  }
}
