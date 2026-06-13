import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, processing, completed, failed, cancelled }

enum PaymentGateway { jib, jawali, hasab, kuraimi }

class PaymentModel extends Equatable {
  final String id;
  final String userId;
  final String subscriptionPlanId;
  final double amount;
  final String currency;
  final PaymentGateway gateway;
  final PaymentStatus status;
  final String? transactionId;
  final String? gatewayReference;
  final DateTime? paidAt;
  final DateTime createdAt;

  const PaymentModel({
    required this.id,
    required this.userId,
    required this.subscriptionPlanId,
    required this.amount,
    this.currency = 'YER',
    required this.gateway,
    this.status = PaymentStatus.pending,
    this.transactionId,
    this.gatewayReference,
    this.paidAt,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['\$id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      subscriptionPlanId: json['subscriptionPlanId'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'YER',
      gateway: PaymentGateway.values.firstWhere(
        (g) => g.name == json['gateway'],
        orElse: () => PaymentGateway.kuraimi,
      ),
      status: PaymentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: json['transactionId'],
      gatewayReference: json['gatewayReference'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'subscriptionPlanId': subscriptionPlanId,
      'amount': amount,
      'currency': currency,
      'gateway': gateway.name,
      'status': status.name,
      'transactionId': transactionId,
      'gatewayReference': gatewayReference,
      'paidAt': paidAt?.toIso8601String(),
    };
  }

  bool get isSuccess => status == PaymentStatus.completed;

  @override
  List<Object?> get props => [
    id, userId, subscriptionPlanId, amount, currency, gateway,
    status, transactionId, gatewayReference, paidAt,
  ];
}
