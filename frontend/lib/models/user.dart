// lib/models/user.dart
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String mobileNumber;

  @HiveField(2)
  String? token;

  @HiveField(3)
  String accountStatus; // active, suspended, deleted

  @HiveField(4)
  DateTime? lastLoginAt;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? deletedAt;

  User({
    this.id,
    required this.mobileNumber,
    this.token,
    this.accountStatus = 'active',
    this.lastLoginAt,
    DateTime? createdAt,
    this.deletedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Factory constructor from JSON (API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      mobileNumber: json['mobile_number'] as String,
      token: json['token'] as String?,
      accountStatus: json['account_status'] as String? ?? 'active',
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobile_number': mobileNumber,
      'token': token,
      'account_status': accountStatus,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // Check if user is active
  bool get isActive => accountStatus == 'active';

  // Check if user is suspended
  bool get isSuspended => accountStatus == 'suspended';

  // Check if user is deleted
  bool get isDeleted => accountStatus == 'deleted';

  // Check if token is valid
  bool get hasValidToken => token != null && token!.isNotEmpty;

  @override
  String toString() {
    return 'User(id: $id, mobileNumber: $mobileNumber, accountStatus: $accountStatus)';
  }
}
