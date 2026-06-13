import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'subscription_state.dart';
import '../../../data/repositories/payment_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/subscription_model.dart';
import '../../../data/models/payment_model.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final PaymentRepository _paymentRepository;
  final AuthRepository _authRepository;
  Timer? _statusCheckTimer;

  SubscriptionCubit(this._paymentRepository, this._authRepository)
      : super(const SubscriptionState()) {
    loadPlans();
  }

  void loadPlans() {
    emit(state.copyWith(status: SubscriptionStatus.loading));

    final plans = [
      SubscriptionPlan(
        id: 'free',
        name: 'مجاني',
        description: 'استماع محدود مع إعلانات',
        price: 0,
        durationDays: 0,
        tier: SubscriptionTier.free,
        features: [
          'استماع عبر الإنترنت فقط',
          'جودة صوت عادية',
          'إعلانات',
          'تنزيل محدود (3 أغاني)',
        ],
        isActive: true,
        currency: 'YER',
      ),
      SubscriptionPlan(
        id: 'basic',
        name: 'أساسي',
        description: 'تجربة محسنة بدون إعلانات',
        price: 3000,
        durationDays: 30,
        tier: SubscriptionTier.basic,
        features: [
          'استماع بدون إعلانات',
          'تحميل للأوفلاين (غير محدود)',
          'جودة عالية',
          'دعم الفنانين',
        ],
        isActive: true,
        currency: 'YER',
      ),
      SubscriptionPlan(
        id: 'premium',
        name: 'مميز',
        description: 'تجربة كاملة مع فيديو كليب',
        price: 7000,
        durationDays: 30,
        tier: SubscriptionTier.premium,
        features: [
          'كل ميزات الأساسي',
          'فيديو كليب',
          'كاريوكي (قريبًا)',
          'شعار مميز',
          'أولوية الدعم',
        ],
        isActive: true,
        currency: 'YER',
      ),
    ];

    emit(state.copyWith(
      status: SubscriptionStatus.loaded,
      plans: plans,
    ));
  }

  Future<void> purchasePlan(SubscriptionPlan plan) async {
    emit(state.copyWith(
      status: SubscriptionStatus.processing,
      selectedPlan: plan,
    ));

    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: 'يجب تسجيل الدخول أولاً',
      ));
      return;
    }

    try {
      final result = await _paymentRepository.purchaseSubscription(
        userId: user.id,
        planId: plan.id,
        amount: plan.price,
        currency: plan.currency,
      );

      if (result.success && result.transactionId != null) {
        _startPolling(result.transactionId!);
      } else {
        emit(state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: result.errorMessage ?? 'فشل عملية الدفع',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: SubscriptionStatus.error,
        errorMessage: 'حدث خطأ أثناء معالجة الدفع',
      ));
    }
  }

  void _startPolling(String transactionId) {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final status = await _paymentRepository.verifyPayment(transactionId);

      if (status == PaymentStatus.completed) {
        _statusCheckTimer?.cancel();
        emit(state.copyWith(status: SubscriptionStatus.active));
      } else if (status == PaymentStatus.failed) {
        _statusCheckTimer?.cancel();
        emit(state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'فشلت عملية الدفع',
        ));
      }
    });

    Timer(const Duration(minutes: 3), () {
      _statusCheckTimer?.cancel();
      if (state.status == SubscriptionStatus.processing) {
        emit(state.copyWith(
          status: SubscriptionStatus.error,
          errorMessage: 'انتهت مهلة انتظار الدفع',
        ));
      }
    });
  }

  @override
  Future<void> close() {
    _statusCheckTimer?.cancel();
    return super.close();
  }
}
