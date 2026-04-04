import 'package:dio/dio.dart';
import 'storage_service.dart';
import '../constants/api_constants.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.instance.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) => handler.next(error),
      ),
    );

  // ─── GET ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final res = await _dio.get(endpoint);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── POST ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final res = await _dio.post(endpoint, data: data);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── PUT ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final res = await _dio.put(endpoint, data: data);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Gestion d'erreurs ────────────────────────────────────────────────────
  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        if (data['message'] != null) return data['message'].toString();
        if (data['errors'] != null) {
          final errors = data['errors'] as Map;
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
      }
      return 'Erreur ${e.response!.statusCode}';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Délai dépassé. Vérifiez votre connexion.';
    }
    return 'Erreur de connexion. Vérifiez votre réseau.';
  }
}
