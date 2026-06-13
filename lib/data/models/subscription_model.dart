import 'package:equatable/equatable.dart';

enum SubscriptionTier { free, basic, premium }

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final SubscriptionTier tier;
  final List<String> features;
  final bool isActive;
  final String currency;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.tier,
    required this.features,
    this.isActive = true,
    this.currency = 'YER',
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['\$id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      durationDays: json['durationDays'] ?? 30,
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionTier.basic,
      ),
      features: List<String>.from(json['features'] ?? []),
      isActive: json['isActive'] ?? true,
      currency: json['currency'] ?? 'YER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'durationDays': durationDays,
      'tier': tier.name,
      'features': features,
      'isActive': isActive,
      'currency': currency,
    };
  }

  @override
  List<Object?> get props => [id, name, description, price, durationDays, tier, features, isActive, currency];
}
