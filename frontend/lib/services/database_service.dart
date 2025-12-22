// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import '../models/transaction.dart';

class DatabaseService {
  static const String databaseName = 'zarbin.db';
  static const int databaseVersion = 1;
  static const String transactionsTable = 'transactions';

  static sqflite.Database? _database;

  static Future<sqflite.Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<sqflite.Database> _initDatabase() async {
    final databasePath = await sqflite.getDatabasesPath();
    final path = join(databasePath, databaseName);

    return sqflite.openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE $transactionsTable (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        amount_toman INTEGER NOT NULL,
        transaction_type TEXT NOT NULL,
        category_id TEXT,
        category_name TEXT,
        transaction_date TEXT NOT NULL,
        notes TEXT,
        usd_rate_at_creation REAL,
        gold_rate_at_creation INTEGER,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

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
  Future<String> saveTransaction(Transaction transaction) async {
    final db = await database;
    final id =
        transaction.id ?? DateTime.now().millisecondsSinceEpoch.toString();

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
        'notes': transaction.notes,
        'usd_rate_at_creation': transaction.usdRateAtCreation,
        'gold_rate_at_creation': transaction.goldRateAtCreation,
        'is_synced': transaction.isSynced ? 1 : 0,
        'created_at': transaction.createdAt.toIso8601String(),
        'updated_at': transaction.updatedAt.toIso8601String(),
      },
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );

    return id;
  }

  // Get all transactions for user
  Future<List<Transaction>> getAllTransactions([String? userId]) async {
    final db = await database;

    List<Map<String, dynamic>> maps;
    if (userId != null) {
      maps = await db.query(
        transactionsTable,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'transaction_date DESC',
      );
    } else {
      maps = await db.query(
        transactionsTable,
        orderBy: 'transaction_date DESC',
      );
    }

    return List.generate(maps.length, (i) => _mapToTransaction(maps[i]));
  }

  // Get unsynced transactions
  Future<List<Transaction>> getUnsyncedTransactions(String userId) async {
    final db = await database;
    final maps = await db.query(
      transactionsTable,
      where: 'user_id = ? AND is_synced = ?',
      whereArgs: [userId, 0],
    );

    return List.generate(maps.length, (i) => _mapToTransaction(maps[i]));
  }

  // Get transactions for specific Jalali month
  Future<List<Transaction>> getTransactionsForMonth(
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
  Future<void> updateTransaction(Transaction transaction) async {
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
        'usd_rate_at_creation': transaction.usdRateAtCreation,
        'gold_rate_at_creation': transaction.goldRateAtCreation,
        'updated_at': transaction.updatedAt.toIso8601String(),
        'is_synced': transaction.isSynced ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark transaction as synced
  Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      transactionsTable,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get transaction count for user
  Future<int> getTransactionCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $transactionsTable WHERE user_id = ?',
      [userId],
    );
    return sqflite.Sqflite.firstIntValue(result) ?? 0;
  }

  // Calculate total for user
  Future<int> calculateTotalForUser(String userId) async {
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
    return sqflite.Sqflite.firstIntValue(result) ?? 0;
  }

  // Clear all transactions for user (for account deletion)
  Future<void> clearUserTransactions(String userId) async {
    final db = await database;
    await db.delete(
      transactionsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Close database
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // Helper: Convert map to Transaction
  Transaction _mapToTransaction(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String?,
      userId: map['user_id'] as String,
      amountToman: map['amount_toman'] as int,
      transactionType: map['transaction_type'] as String,
      categoryId: map['category_id'] as String?,
      categoryName: map['category_name'] as String?,
      transactionDate: map['transaction_date'] as String?,
      usdRateAtCreation:
          (map['usd_rate_at_creation'] as num?)?.toDouble() ?? 0.0,
      goldRateAtCreation: (map['gold_rate_at_creation'] as num?)?.toInt() ?? 0,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isSynced: (map['is_synced'] as int?) == 1,
    );
  }
}
