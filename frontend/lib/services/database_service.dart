// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';

class DatabaseService {
  static const String databaseName = 'zarbin.db';
  static const int databaseVersion = 1;
  static const String transactionsTable = 'transactions';

  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $transactionsTable (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        amount_toman INTEGER NOT NULL,
        transaction_type TEXT NOT NULL,
        category_id TEXT,
        category_name TEXT,
        transaction_date TEXT NOT NULL,
        usd_rate_at_creation REAL NOT NULL,
        gold_rate_at_creation INTEGER NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes for faster queries
    await db.execute('''
      CREATE INDEX idx_user_id ON $transactionsTable(user_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_transaction_date ON $transactionsTable(transaction_date)
    ''');
    await db.execute('''
      CREATE INDEX idx_is_synced ON $transactionsTable(is_synced)
    ''');
  }

  // Insert transaction
  static Future<String> insertTransaction(Transaction transaction) async {
    final db = await database;
    final id = transaction.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    await db.insert(
      transactionsTable,
      {
        'id': id,
        'user_id': transaction.userId,
        'amount_toman': transaction.amountToman,
        'transaction_type': transaction.transactionType,
        'category_id': transaction.categoryId,
        'category_name': transaction.categoryName,
        'transaction_date': transaction.transactionDate,
        'usd_rate_at_creation': transaction.usdRateAtCreation,
        'gold_rate_at_creation': transaction.goldRateAtCreation,
        'notes': transaction.notes,
        'created_at': transaction.createdAt.toIso8601String(),
        'updated_at': transaction.updatedAt.toIso8601String(),
        'is_synced': transaction.isSynced ? 1 : 0,
      },
    );

    return id;
  }

  // Get all transactions for user
  static Future<List<Transaction>> getTransactions(String userId) async {
    final db = await database;
    final maps = await db.query(
      transactionsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'transaction_date DESC',
    );

    return List.generate(maps.length, (i) => _mapToTransaction(maps[i]));
  }

  // Get unsynced transactions
  static Future<List<Transaction>> getUnsyncedTransactions(String userId) async {
    final db = await database;
    final maps = await db.query(
      transactionsTable,
      where: 'user_id = ? AND is_synced = ?',
      whereArgs: [userId, 0],
    );

    return List.generate(maps.length, (i) => _mapToTransaction(maps[i]));
  }

  // Get transactions for specific Jalali month
  static Future<List<Transaction>> getTransactionsForMonth(
    String userId,
    int year,
    int month,
  ) async {
    final db = await database;
    final monthStr = month.toString().padLeft(2, '0');
    final pattern = '$year/$monthStr/%';

    final maps = await db.query(
      transactionsTable,
      where: 'user_id = ? AND transaction_date LIKE ?',
      whereArgs: [userId, pattern],
      orderBy: 'transaction_date DESC',
    );

    return List.generate(maps.length, (i) => _mapToTransaction(maps[i]));
  }

  // Update transaction
  static Future<void> updateTransaction(Transaction transaction) async {
    final db = await database;
    await db.update(
      transactionsTable,
      {
        'amount_toman': transaction.amountToman,
        'transaction_type': transaction.transactionType,
        'category_id': transaction.categoryId,
        'category_name': transaction.categoryName,
        'transaction_date': transaction.transactionDate,
        'notes': transaction.notes,
        'updated_at': transaction.updatedAt.toIso8601String(),
        'is_synced': transaction.isSynced ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Delete transaction
  static Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark transaction as synced
  static Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      transactionsTable,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get transaction count for user
  static Future<int> getTransactionCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $transactionsTable WHERE user_id = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Calculate total for user
  static Future<int> calculateTotalForUser(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''SELECT SUM(
        CASE 
          WHEN transaction_type = 'income' THEN amount_toman
          WHEN transaction_type = 'expense' THEN -amount_toman
          ELSE 0
        END
      ) as total FROM $transactionsTable WHERE user_id = ?''',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Clear all transactions for user (for account deletion)
  static Future<void> clearUserTransactions(String userId) async {
    final db = await database;
    await db.delete(
      transactionsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Close database
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Helper: Convert map to Transaction
  static Transaction _mapToTransaction(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      amountToman: map['amount_toman'] as int,
      transactionType: map['transaction_type'] as String,
      categoryId: map['category_id'] as String?,
      categoryName: map['category_name'] as String?,
      transactionDate: map['transaction_date'] as String?,
      usdRateAtCreation: map['usd_rate_at_creation'] as double,
      goldRateAtCreation: map['gold_rate_at_creation'] as int,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isSynced: (map['is_synced'] as int?) == 1,
    );
  }
}
