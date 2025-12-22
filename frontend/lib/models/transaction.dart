// lib/models/transaction.dart
import 'package:hive/hive.dart';
import 'package:shamsi_date/shamsi_date.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  int amountToman;

  @HiveField(3)
  String transactionType; // income, expense

  @HiveField(4)
  String? categoryId;

  @HiveField(5)
  String? categoryName; // Persian category name (خوراک, حمل‌ونقل, etc)

  @HiveField(6)
  String transactionDate; // Jalali date YYYY/MM/DD

  @HiveField(7)
  double usdRateAtCreation;

  @HiveField(8)
  int goldRateAtCreation;

  @HiveField(9)
  String? notes;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  @HiveField(12)
  bool isSynced; // Whether synced with backend

  Transaction({
    this.id,
    required this.userId,
    required this.amountToman,
    required this.transactionType,
    this.categoryId,
    this.categoryName,
    String? transactionDate,
    required this.usdRateAtCreation,
    required this.goldRateAtCreation,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = false,
  })  : transactionDate = transactionDate ?? _currentJalaliDate(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Get current Jalali date as string YYYY/MM/DD
  static String _currentJalaliDate() {
    final now = DateTime.now();
    final jalali = Jalali.fromDateTime(now);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  // Factory constructor from JSON (API response)
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      amountToman: json['amount_toman'] as int,
      transactionType: json['transaction_type'] as String,
      categoryId: json['category']?['id'] as String?,
      categoryName: json['category']?['persian_name'] as String?,
      transactionDate: json['transaction_date'] as String?,
      usdRateAtCreation: (json['usd_rate_at_creation'] as num).toDouble(),
      goldRateAtCreation: json['gold_rate_at_creation'] as int,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
      updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : DateTime.now(),
      isSynced: true,
    );
  }

  // Convert to JSON for API request
  Map<String, dynamic> toJson({bool forApi = false}) {
    final data = {
      'amount_toman': amountToman,
      'transaction_type': transactionType,
      'transaction_date': transactionDate,
      'category_id': categoryId,
      'notes': notes,
    };

    if (!forApi) {
      data.addAll({
        'id': id,
        'user_id': userId,
        'usd_rate_at_creation': usdRateAtCreation,
        'gold_rate_at_creation': goldRateAtCreation,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'is_synced': isSynced,
      });
    }

    return data;
  }

  // Calculate USD equivalent
  double get amountUsdEquivalent {
    return double.parse((amountToman / usdRateAtCreation).toStringAsFixed(2));
  }

  // Calculate gold gram equivalent
  double get amountGoldGramsEquivalent {
    return double.parse((amountToman / goldRateAtCreation).toStringAsFixed(2));
  }

  // Check if income
  bool get isIncome => transactionType == 'income';

  // Check if expense
  bool get isExpense => transactionType == 'expense';

  // Get transaction type label in Persian
  String get transactionTypeLabel {
    return isIncome ? 'درآمد' : 'هزینه';
  }

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amountToman, type: $transactionType, date: $transactionDate)';
  }
}

extension DoubleRound on double {
  double roundToDouble(int decimals) {
    final factor = 10.0 * decimals;
    return (this * factor).round() / factor;
  }
}
