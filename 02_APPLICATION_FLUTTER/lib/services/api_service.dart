import 'package:dio/dio.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  late Dio _dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.coingecko.com/api/v3',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  Future<Map<String, dynamic>> getCryptoData(String ids) async {
    try {
      final response = await _dio.get(
        '/simple/price',
        queryParameters: {
          'ids': ids,
          'vs_currencies': 'usd,eur',
          'include_market_cap': 'true',
          'include_24hr_vol': 'true',
          'include_24hr_change': 'true',
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch crypto data: $e');
    }
  }

  Future<List<dynamic>> getCryptoMarkets() async {
    try {
      final response = await _dio.get(
        '/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'order': 'market_cap_desc',
          'per_page': '50',
          'page': '1',
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch markets: $e');
    }
  }

  Future<List<dynamic>> getCryptoOHLC(String id, String days) async {
    try {
      final response = await _dio.get(
        '/coins/$id/ohlc',
        queryParameters: {'vs_currency': 'usd', 'days': days},
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch OHLC data: $e');
    }
  }
}
