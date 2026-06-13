import '../providers/remote/appwrite_provider.dart';
import '../providers/local/hive_provider.dart';
import '../models/user_model.dart';
import '../../core/constants/appwrite_constants.dart';

class AuthRepository {
  final AppwriteProvider _appwrite;

  AuthRepository(this._appwrite);

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final session = await _appwrite.createSession(
      email: email,
      password: password,
    );

    _appwrite.setSession(session['jwt']?.toString() ?? '');

    final user = await _fetchUserWithDocument();

    await HiveProvider.saveUser(user.toJson());
    await HiveProvider.saveToken(session['jwt']?.toString() ?? '');

    return user;
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final appwriteUser = await _appwrite.createAccount(
      email: email,
      password: password,
      name: name,
    );

    final session = await _appwrite.createSession(
      email: email,
      password: password,
    );

    final jwt = session['jwt']?.toString() ?? '';
    _appwrite.setSession(jwt);

    try {
      await _appwrite.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: appwriteUser['\$id']?.toString() ?? 'unique()',
        data: {
          'email': email,
          'name': name,
          'isAdmin': false,
          'subscriptionId': null,
          'subscriptionExpiry': null,
        },
      );
    } catch (_) {
      // فشل إنشاء الوثيقة (غالباً صلاحيات) — لا نوقف التسجيل، سنستخدم بيانات Auth فقط
    }

    final user = await _fetchUserWithDocument();

    await HiveProvider.saveUser(user.toJson());
    await HiveProvider.saveToken(jwt);

    return user;
  }

  Future<void> logout() async {
    try {
      await _appwrite.deleteSession();
    } catch (_) {}
    _appwrite.clearSession();
    await HiveProvider.clearUser();
    await HiveProvider.clearToken();
  }

  Future<UserModel?> getCurrentUser() async {
    final cached = HiveProvider.getUser();
    if (cached != null) {
      return UserModel.fromJson(cached);
    }

    try {
      final user = await _fetchUserWithDocument();
      await HiveProvider.saveUser(user.toJson());
      return user;
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> _fetchUserWithDocument() async {
    final appwriteUser = await _appwrite.getCurrentUser();

    try {
      final userDoc = await _appwrite.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: appwriteUser['\$id']?.toString() ?? '',
      );

      return UserModel.fromJson({
        ...userDoc,
        '\$id': userDoc['\$id']?.toString() ?? '',
        'createdAt': userDoc['\$createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      });
    } catch (_) {
      return UserModel.fromJson({
        '\$id': appwriteUser['\$id']?.toString() ?? '',
        'email': appwriteUser['email']?.toString() ?? '',
        'name': appwriteUser['name']?.toString() ?? '',
        'createdAt': appwriteUser['\$createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      });
    }
  }

  bool isLoggedIn() {
    return HiveProvider.getToken() != null;
  }
}
