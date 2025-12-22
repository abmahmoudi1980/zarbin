import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zarbin/providers/transaction_provider.dart';
import 'package:zarbin/models/transaction.dart';
import 'package:zarbin/screens/add_transaction_screen.dart';
import 'package:zarbin/widgets/transaction_list_item.dart';

/// TransactionListScreen - Displays all user transactions
/// Features:
/// - List of transactions sorted by date (newest first)
/// - Transaction details: amount, category, date, notes
/// - Dual-currency display (Toman + USD)
/// - Category icons
/// - Income/expense distinction
/// - Pull-to-refresh support
/// - Add transaction button
class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  @override
  void initState() {
    super.initState();
    // Load transactions on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  /// Handles pull-to-refresh
  Future<void> _onRefresh() async {
    return context.read<TransactionProvider>().fetchTransactions();
  }

  /// Navigates to AddTransactionScreen
  void _navigateToAddTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddTransaction,
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          // Show loading state
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error state with retry button
          if (provider.error != null && provider.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error ?? 'An error occurred'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.fetchTransactions,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show empty state
          if (provider.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No transactions yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start adding transactions to track your finances',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _navigateToAddTransaction,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Transaction'),
                  ),
                ],
              ),
            );
          }

          // Show transactions list with pull-to-refresh
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                final transaction = provider.transactions[index];
                return TransactionListItem(
                  transaction: transaction,
                  onTap: () => _showTransactionDetails(transaction),
                  onDelete: () => _deleteTransaction(transaction.id),
                  onEdit: () => _editTransaction(transaction),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Shows transaction details in a modal
  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),

            // Transaction details
            _buildDetailRow('Category', transaction.categoryName),
            _buildDetailRow('Date', transaction.transactionDate),
            _buildDetailRow(
              'Amount',
              '${_formatAmount(transaction.amountToman)} تومان',
            ),
            _buildDetailRow(
              'USD Equivalent',
              '${transaction.amountUsdEquivalent.toStringAsFixed(2)} USD',
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              _buildDetailRow('Notes', transaction.notes!),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editTransaction(transaction);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteTransaction(transaction.id);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a detail row for transaction details view
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Formats amount to Persian numerals with separators
  String _formatAmount(int amount) {
    final formatted = amount.toString();
    // Replace English numerals with Persian
    return formatted
        .replaceAll('0', '۰')
        .replaceAll('1', '۱')
        .replaceAll('2', '۲')
        .replaceAll('3', '۳')
        .replaceAll('4', '۴')
        .replaceAll('5', '۵')
        .replaceAll('6', '۶')
        .replaceAll('7', '۷')
        .replaceAll('8', '۸')
        .replaceAll('9', '۹');
  }

  /// Edits a transaction
  void _editTransaction(Transaction transaction) {
    // TODO: Implement edit transaction screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
    );
  }

  /// Deletes a transaction with confirmation
  void _deleteTransaction(String? transactionId) {
    if (transactionId == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<TransactionProvider>()
                  .deleteTransaction(transactionId);

              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction deleted successfully'),
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
