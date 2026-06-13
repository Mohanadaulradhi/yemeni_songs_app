import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      if (_authRepository.isLoggedIn()) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(state.copyWith(status: AuthStatus.authenticated, user: user));
          return;
        }
      }
    } catch (_) {}
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _friendlyError(e),
      ));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await _authRepository.register(
        email: email,
        password: password,
        name: name,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: _friendlyError(e),
      ));
    }
  }

  String _friendlyError(Object e) {
    final message = e is DioException ? _dioError(e) : e.toString();
    // إزالة التفاصيل التقنية الزائدة
    if (message.contains('Exception:') || message.contains('DioError:')) {
      return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
    }
    return message;
  }

  String _dioError(DioException e) {
    // أخطاء الاتصال (بدون استجابة من السيرفر)
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'تعذر الاتصال بالخادم: انتهت مهلة الاتصال. تأكد من اتصالك بالإنترنت.';
      case DioExceptionType.sendTimeout:
        return 'تعذر إرسال البيانات: انتهت المهلة. حاول مرة أخرى.';
      case DioExceptionType.receiveTimeout:
        return 'تعذر استقبال البيانات: انتهت المهلة. اتصالك بطيء.';
      case DioExceptionType.connectionError:
        return 'تعذر الاتصال بالخادم. تأكد من اتصالك بالإنترنت وأن الخادم يعمل.';
      case DioExceptionType.badCertificate:
        return 'خطأ في شهادة الأمان. قد يكون الخادم غير آمن.';
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب.';
      case DioExceptionType.badResponse:
      // أكمل لفحص رمز الحالة
      case DioExceptionType.unknown:
        return 'خطأ غير متوقع في الشبكة. تأكد من اتصالك وحاول مرة أخرى.';
    }

    final code = e.response?.statusCode;
    final data = e.response?.data;
    String? serverMsg;
    if (data is Map && data['message'] != null) {
      serverMsg = data['message'].toString();
    }

    switch (code) {
      case 400:
        if (serverMsg != null && serverMsg.contains('password')) {
          return 'كلمة المرور ضعيفة. يجب أن تحتوي على 8 أحرف على الأقل مع أرقام ورموز.';
        }
        if (serverMsg != null && serverMsg.contains('email')) {
          return 'البريد الإلكتروني غير صالح. تأكد من صيغته (مثال: name@domain.com).';
        }
        return 'البيانات غير صالحة. تحقق من صحة الإيميل وقوة كلمة المرور.';
      case 401:
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      case 403:
        return 'ليس لديك صلاحية للقيام بهذه العملية.';
      case 404:
        return 'المورد المطلوب غير موجود (تأكد من إعدادات قاعدة البيانات في Appwrite).';
      case 409:
        return 'هذا البريد الإلكتروني مسجل مسبقاً. يمكنك تسجيل الدخول مباشرة.';
      case 429:
        return 'طلبات كثيرة جداً. انتظر دقيقة وحاول مجدداً.';
      default:
        final errorMsg = serverMsg ?? 'خطأ في الخادم (رمز: ${code ?? 'غير معروف'}).';
        return '$errorMsg حاول مرة أخرى.';
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    ));
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
