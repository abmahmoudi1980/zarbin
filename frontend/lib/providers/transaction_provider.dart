import 'package:flutter/foundation.dart';
import 'package:zarbin/models/transaction.dart';
import 'package:zarbin/services/api_client.dart';
import 'package:zarbin/services/database_service.dart';
import 'package:zarbin/services/analytics_service.dart';

/// TransactionProvider - Manages transaction state for the application
/// Handles CRUD operations, caching, and synchronization with backend
class TransactionProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final DatabaseService _databaseService;
  final AnalyticsService _analytics = AnalyticsService();

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  TransactionProvider({
    required ApiClient apiClient,
    required DatabaseService databaseService,
  })  : _apiClient = apiClient,
        _databaseService = databaseService;

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetches all transactions for the current user from backend
  Future<void> fetchTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get('/transactions');

      if (response['success'] == true) {
        final transactionsData = response['data'] as List;
        _transactions = transactionsData
            .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
            .toList();

        // Cache locally
        for (final transaction in _transactions) {
          await _databaseService.saveTransaction(transaction);
        }

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      // Try to load from local cache
      await _loadLocalTransactions();
      notifyListeners();
    }
  }

  /// Loads transactions from local cache (SQLite)
  Future<void> _loadLocalTransactions() async {
    try {
      _transactions = await _databaseService.getAllTransactions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load transactions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new transaction
  Future<bool> addTransaction({
    required int amount,
    required String type,
    required int categoryId,
    required String date,
    required String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '/transactions',
        data: {
          'transaction': {
            'amount_toman': amount,
            'transaction_type': type,
            'category_id': categoryId,
            'transaction_date': date,
            'notes': notes,
          }
        },
      );

      if (response['success'] == true) {
        final newTransaction = Transaction.fromJson(
          response['data'] as Map<String, dynamic>,
        );

        await _analytics.logEvent(
          name: 'transaction_added',
          parameters: {
            'type': type,
            'category_id': categoryId,
            'amount': amount,
          },
        );

        _transactions.insert(0, newTransaction); // Add to top (newest first)

        // Cache locally
        await _databaseService.saveTransaction(newTransaction);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error'] ?? 'Failed to create transaction';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, stack) {
      _error = e.toString();
      await _analytics.logError(e, stack, reason: 'add_transaction_failed');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing transaction
  Future<bool> updateTransaction({
    required int id,
    required int amount,
    required String type,
    required int categoryId,
    required String date,
    required String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.patch(
        '/transactions/$id',
        data: {
          'transaction': {
            'amount_toman': amount,
            'transaction_type': type,
            'category_id': categoryId,
            'transaction_date': date,
            'notes': notes,
          }
        },
      );

      if (response['success'] == true) {
        final updatedTransaction = Transaction.fromJson(
          response['data'] as Map<String, dynamic>,
        );

        // Update in list
        final index = _transactions.indexWhere((t) => t.id == id.toString());
        if (index >= 0) {
          _transactions[index] = updatedTransaction;
        }

        // Update cache
        await _databaseService.updateTransaction(updatedTransaction);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error'] ?? 'Failed to update transaction';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Deletes a transaction
  Future<bool> deleteTransaction(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiClient.delete('/transactions/$id');

      // Remove from list
      _transactions.removeWhere((t) => t.id == id);

      // Delete from cache
      await _databaseService.deleteTransaction(id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Gets a transaction by ID
  Transaction? getTransactionById(int id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filters transactions by type (income/expense)
  List<Transaction> getTransactionsByType(String type) {
    return _transactions.where((t) => t.transactionType == type).toList();
  }

  /// Filters transactions by category
  List<Transaction> getTransactionsByCategory(int categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  /// Gets total income
  int getTotalIncome() {
    return getTransactionsByType('income')
        .fold(0, (sum, t) => sum + t.amountToman);
  }

  /// Gets total expenses
  int getTotalExpense() {
    return getTransactionsByType('expense')
        .fold(0, (sum, t) => sum + t.amountToman);
  }

  /// Gets net balance (income - expenses)
  int getNetBalance() {
    return getTotalIncome() - getTotalExpense();
  }

  /// Clears error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
