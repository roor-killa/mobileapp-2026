import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/dashboard_data.dart';

/// Charge les données servies par json-server Docker (`GET /dashboard`).
/// Retourne `null` si le serveur est injoignable (Docker arrêté, mauvaise URL, etc.).
class DashboardApi {
  DashboardApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 8);

  Future<DashboardPayload?> fetchDashboard() async {
    try {
      final response = await _client
          .get(
            ApiConfig.dashboardUri,
            headers: {'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return DashboardPayload.fromJson(decoded);
    } on Object {
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
