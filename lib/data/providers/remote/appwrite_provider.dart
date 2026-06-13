import 'package:dio/dio.dart';
import '../../../core/constants/appwrite_constants.dart';

class AppwriteProvider {
  final Dio _dio;

  AppwriteProvider()
      : _dio = Dio(BaseOptions(
          baseUrl: AppwriteConstants.endpoint,
          connectTimeout: const Duration(milliseconds: 15000),
          receiveTimeout: const Duration(milliseconds: 30000),
        )) {
    _dio.options.headers['X-Appwrite-Project'] = AppwriteConstants.projectId;
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  void setSession(String jwt) {
    _dio.options.headers['X-Appwrite-JWT'] = jwt;
  }

  void clearSession() {
    _dio.options.headers.remove('X-Appwrite-JWT');
  }

  Future<Map<String, dynamic>> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    final res = await _dio.post('/account', data: {
      'userId': 'unique()',
      'email': email,
      'password': password,
      'name': name,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createSession({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/account/sessions/email', data: {
      'email': email,
      'password': password,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<void> deleteSession() async {
    await _dio.delete('/account/sessions/current');
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final res = await _dio.get('/account');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listDocuments({
    required String databaseId,
    required String collectionId,
    List<String>? queries,
  }) async {
    final queryParams = <String, dynamic>{};
    if (queries != null && queries.isNotEmpty) {
      queryParams['queries'] = queries;
    }
    final res = await _dio.get(
      '/databases/$databaseId/collections/$collectionId/documents',
      queryParameters: queryParams,
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    final res = await _dio.get(
      '/databases/$databaseId/collections/$collectionId/documents/$documentId',
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createDocument({
    required String databaseId,
    required String collectionId,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    final res = await _dio.post(
      '/databases/$databaseId/collections/$collectionId/documents',
      data: {
        'documentId': documentId ?? 'unique()',
        'data': data,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final res = await _dio.patch(
      '/databases/$databaseId/collections/$collectionId/documents/$documentId',
      data: {'data': data},
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> uploadFile({
    required String bucketId,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'fileId': 'unique()',
      'file': await MultipartFile.fromFile(filePath),
    });
    final res = await _dio.post(
      '/storage/buckets/$bucketId/files',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
    return res.data as Map<String, dynamic>;
  }

  String getFilePreview({
    required String bucketId,
    required String fileId,
    int width = 300,
    int height = 300,
  }) {
    return '${AppwriteConstants.endpoint}/storage/buckets/$bucketId/files/$fileId/preview?project=${AppwriteConstants.projectId}&width=$width&height=$height';
  }

  String getFileView({
    required String bucketId,
    required String fileId,
  }) {
    return '${AppwriteConstants.endpoint}/storage/buckets/$bucketId/files/$fileId/view?project=${AppwriteConstants.projectId}';
  }

  Future<Map<String, dynamic>> callFunction({
    required String functionId,
    String? payload,
  }) async {
    final res = await _dio.post(
      '/functions/$functionId/executions',
      data: {'body': payload ?? ''},
    );
    return res.data as Map<String, dynamic>;
  }
}
