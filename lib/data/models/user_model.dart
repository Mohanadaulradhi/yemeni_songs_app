import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? subscriptionId;
  final DateTime? subscriptionExpiry;
  final bool isAdmin;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.subscriptionId,
    this.subscriptionExpiry,
    this.isAdmin = false,
    required this.createdAt,
  });

  bool get hasActiveSubscription =>
      subscriptionExpiry != null && subscriptionExpiry!.isAfter(DateTime.now());

  bool get isPremium => hasActiveSubscription;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    return UserModel(
      id: json['\$id'] ?? json['id'] ?? data['\$id'] ?? data['id'] ?? '',
      email: data['email'] ?? json['email'] ?? '',
      name: data['name'] ?? json['name'] ?? '',
      phone: data['phone'] ?? json['phone'],
      subscriptionId: data['subscriptionId'] ?? json['subscriptionId'],
      subscriptionExpiry: data['subscriptionExpiry'] ?? json['subscriptionExpiry'] != null
          ? DateTime.parse(data['subscriptionExpiry'] ?? json['subscriptionExpiry'])
          : null,
      isAdmin: data['isAdmin'] ?? json['isAdmin'] ?? false,
      createdAt: DateTime.parse(
        data['createdAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'subscriptionId': subscriptionId,
      'subscriptionExpiry': subscriptionExpiry?.toIso8601String(),
      'isAdmin': isAdmin,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? subscriptionId,
    DateTime? subscriptionExpiry,
    bool? isAdmin,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, phone, subscriptionId, subscriptionExpiry, isAdmin];
}
