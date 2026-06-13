import 'package:equatable/equatable.dart';
import '../../../data/models/subscription_model.dart';
import '../../../data/models/payment_model.dart';

enum SubscriptionStatus { initial, loading, loaded, processing, active, error }

class SubscriptionState extends Equatable {
  final SubscriptionStatus status;
  final List<SubscriptionPlan> plans;
  final SubscriptionPlan? selectedPlan;
  final PaymentModel? currentPayment;
  final String? errorMessage;

  const SubscriptionState({
    this.status = SubscriptionStatus.initial,
    this.plans = const [],
    this.selectedPlan,
    this.currentPayment,
    this.errorMessage,
  });

  SubscriptionState copyWith({
    SubscriptionStatus? status,
    List<SubscriptionPlan>? plans,
    SubscriptionPlan? selectedPlan,
    PaymentModel? currentPayment,
    String? errorMessage,
  }) {
    return SubscriptionState(
      status: status ?? this.status,
      plans: plans ?? this.plans,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      currentPayment: currentPayment ?? this.currentPayment,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, plans, selectedPlan, currentPayment, errorMessage];
}
