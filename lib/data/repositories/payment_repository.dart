import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/payment_model.dart';

abstract class PaymentService {
  Future<PaymentResult> initiatePayment({
    required String userId,
    required String planId,
    required double amount,
    required String currency,
  });

  Future<PaymentStatus> checkPaymentStatus(String transactionId);
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? paymentUrl;
  final String? errorMessage;

  const PaymentResult({
    required this.success,
    this.transactionId,
    this.paymentUrl,
    this.errorMessage,
  });
}

class KuraimiPaymentService implements PaymentService {
  final Dio _dio;

  KuraimiPaymentService()
      : _dio = Dio(BaseOptions(
          baseUrl: dotenv.env['KURAIMI_BASE_URL'] ?? 'https://api.kuraimi.com/v1',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Authorization': 'Bearer ${dotenv.env['KURAIMI_API_KEY'] ?? ''}',
            'Content-Type': 'application/json',
          },
        ));

  @override
  Future<PaymentResult> initiatePayment({
    required String userId,
    required String planId,
    required double amount,
    required String currency,
  }) async {
    try {
      final response = await _dio.post('/payments/initiate', data: {
        'merchant_id': dotenv.env['KURAIMI_MERCHANT_ID'] ?? '',
        'user_id': userId,
        'plan_id': planId,
        'amount': amount,
        'currency': currency,
        'callback_url': 'yemeni_songs_app://payment/callback',
      });

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return PaymentResult(
          success: true,
          transactionId: data['transaction_id'],
          paymentUrl: data['payment_url'],
        );
      }

      return PaymentResult(
        success: false,
        errorMessage: 'فشلت عملية الدفع',
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'خطأ في الاتصال ببوابة الدفع',
      );
    }
  }

  @override
  Future<PaymentStatus> checkPaymentStatus(String transactionId) async {
    try {
      final response = await _dio.get('/payments/status/$transactionId');

      if (response.statusCode == 200) {
        final status = response.data['status'] as String;
        switch (status) {
          case 'completed':
            return PaymentStatus.completed;
          case 'failed':
            return PaymentStatus.failed;
          case 'processing':
            return PaymentStatus.processing;
          default:
            return PaymentStatus.pending;
        }
      }

      return PaymentStatus.failed;
    } catch (_) {
      return PaymentStatus.pending;
    }
  }
}

class PaymentRepository {
  final PaymentService _paymentService;

  PaymentRepository(this._paymentService);

  Future<PaymentResult> purchaseSubscription({
    required String userId,
    required String planId,
    required double amount,
    required String currency,
  }) async {
    return await _paymentService.initiatePayment(
      userId: userId,
      planId: planId,
      amount: amount,
      currency: currency,
    );
  }

  Future<PaymentStatus> verifyPayment(String transactionId) async {
    return await _paymentService.checkPaymentStatus(transactionId);
  }
}
