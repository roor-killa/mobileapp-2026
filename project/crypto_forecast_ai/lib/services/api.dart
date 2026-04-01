import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Api {
  late final String baseUrl;
  String? _token;
  String? _refreshToken;

  /// Callback optionnel (ex: persist tokens).
  Future<void> Function(String? access, String? refresh)? onTokenUpdate;

  Api({String? baseUrlOverride}) {
    baseUrl = baseUrlOverride ?? _defaultBaseUrl();
  }

  static String _defaultBaseUrl() {
    if (kIsWeb) return "http://127.0.0.1:8000";
    if (defaultTargetPlatform == TargetPlatform.android) return "http://10.0.2.2:8000";
    return "http://127.0.0.1:8000";
  }

  void setToken(String? token) => _token = token;
  void setRefreshToken(String? token) => _refreshToken = token;

  Map<String, String> _headers({bool auth = false, bool json = true}) {
    final h = <String, String>{
      "Accept": "application/json",
      if (json) "Content-Type": "application/json; charset=utf-8",
    };
    if (auth && _token != null && _token!.isNotEmpty) {
      h["Authorization"] = "Bearer $_token";
    }
    return h;
  }

  Exception _httpError(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body["detail"] != null) {
        return Exception(body["detail"].toString());
      }
    } catch (_) {}
    return Exception("HTTP ${res.statusCode}: ${res.body}");
  }

  Uri _u(String path, {Map<String, String>? q}) {
    final base = Uri.parse(baseUrl);
    final uri = base.replace(
      path: (base.path.endsWith("/") ? base.path.substring(0, base.path.length - 1) : base.path) + path,
      queryParameters: q,
    );
    return uri;
  }

  // -------------------------
  
  Future<bool> _tryRefresh() async {
    final rt = _refreshToken;
    if (rt == null || rt.isEmpty) return false;

    final uri = Uri.parse("$baseUrl/auth/refresh");
    final res = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode({"refresh_token": rt}),
    );

    if (res.statusCode != 200) return false;

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final at = (data["access_token"] ?? "").toString();
    final newRt = (data["refresh_token"] ?? "").toString();

    if (at.isEmpty) return false;

    _token = at;
    if (newRt.isNotEmpty) _refreshToken = newRt;

    if (onTokenUpdate != null) {
      await onTokenUpdate!(_token, _refreshToken);
    }
    return true;
  }

  Future<http.Response> _authedRequest(Future<http.Response> Function(Map<String, String> h) fn) async {
    var res = await fn(_headers(auth: true));
    if (res.statusCode == 401) {
      final ok = await _tryRefresh();
      if (ok) {
        res = await fn(_headers(auth: true));
      }
    }
    return res;
  }

// HEALTH
  // -------------------------
  Future<bool> health() async {
    final res = await http.get(_u("/health"), headers: _headers(json: false));
    return res.statusCode == 200;
  }

  // -------------------------
  // AUTH
  // -------------------------
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final res = await http.post(
      _u("/auth/register"),
      headers: _headers(),
      body: jsonEncode({
        "email": email,
        "password": password,
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
      }),
    );
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse("$baseUrl/auth/login");
    final res = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode({"email": email, "password": password}),
    );
    if (res.statusCode != 200) throw _httpError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    final token = (data["access_token"] ?? "").toString();
    final refresh = (data["refresh_token"] ?? "").toString();

    if (token.isEmpty) throw Exception("Token manquant");
    _token = token;
    if (refresh.isNotEmpty) _refreshToken = refresh;

    if (onTokenUpdate != null) {
      await onTokenUpdate!(_token, _refreshToken);
    }

    return data;
  }

  Future<Map<String, dynamic>> me() async {
    final res = await http.get(_u("/me"), headers: _headers(auth: true, json: false));
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    final uri = Uri.parse("$baseUrl/auth/change-password");
    final res = await _authedRequest((h) => http.post(
          uri,
          headers: h,
          body: jsonEncode({"old_password": oldPassword, "new_password": newPassword}),
        ));
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // -------------------------
  // USERS (autocomplete comptes)
  // GET /users/search?q=...
  // -------------------------
  Future<List<Map<String, dynamic>>> searchUsers(String q, {int limit = 10}) async {
    final query = q.trim();
    if (query.length < 2) return [];

    final res = await http.get(
      _u("/users/search", q: {"q": query, "limit": "$limit"}),
      headers: _headers(auth: true, json: false),
    );
    if (res.statusCode != 200) throw _httpError(res);

    final data = jsonDecode(res.body);
    final list = (data as List<dynamic>? ?? []);
    return list.cast<Map<String, dynamic>>();
  }

  // -------------------------
  // BANK
  // -------------------------
  Future<Map<String, dynamic>> bankBalance() async {
    final res = await http.get(_u("/bank/balance"), headers: _headers(auth: true, json: false));
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> bankTransactions({
    int limit = 30,
    String direction = "all",
    DateTime? fromDate,
    DateTime? toDate,
    String? counterparty,
  }) async {
    final qp = <String, String>{
      "limit": "$limit",
      "direction": direction,
    };
    if (fromDate != null) {
      qp["from_date"] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      qp["to_date"] = toDate.toIso8601String();
    }
    if (counterparty != null && counterparty.trim().isNotEmpty) {
      qp["counterparty"] = counterparty.trim();
    }

    final uri = Uri.parse("$baseUrl/bank/transactions").replace(queryParameters: qp);
    final res = await _authedRequest((h) => http.get(uri, headers: h));
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> bankTransfer({
    required String toEmail,
    required double usdAmount,
    String note = "",
  }) async {
    final uri = Uri.parse("$baseUrl/bank/transfer");
    final res = await _authedRequest((h) => http.post(
          uri,
          headers: h,
          body: jsonEncode({"to_email": toEmail, "usd_amount": usdAmount, "note": note}),
        ));
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // -------------------------
  // BENEFICIARIES
  // -------------------------
  Future<List<Map<String, dynamic>>> bankBeneficiaries() async {
    final res = await http.get(_u("/bank/beneficiaries"), headers: _headers(auth: true, json: false));
    if (res.statusCode != 200) throw _httpError(res);
    final data = jsonDecode(res.body);
    final list = (data as List<dynamic>? ?? []);
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> bankAddBeneficiary({
    required String email,
    String alias = "",
  }) async {
    final res = await http.post(
      _u("/bank/beneficiaries"),
      headers: _headers(auth: true),
      body: jsonEncode({"alias": alias, "email": email}),
    );
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> bankDeleteBeneficiary(int id) async {
    final uri = Uri.parse("$baseUrl/bank/beneficiaries/$id");
    final res = await _authedRequest((h) => http.delete(uri, headers: h));
    if (res.statusCode != 200) throw _httpError(res);
  }

  
  // -------------------------
  // WALLET / TRADE
  // -------------------------
  Future<Map<String, dynamic>> wallet() async {
    final res = await http.get(
      _u("/wallet"),
      headers: _headers(auth: true, json: false),
    );
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> buy(String coinId, double usdAmount) async {
    final cid = coinId.trim().toLowerCase();
    final res = await http.post(
      _u("/trade/buy"),
      headers: _headers(auth: true),
      body: jsonEncode({"coin_id": cid, "usd_amount": usdAmount}),
    );
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sell(String coinId, double coinAmount) async {
    final cid = coinId.trim().toLowerCase();
    final res = await http.post(
      _u("/trade/sell"),
      headers: _headers(auth: true),
      body: jsonEncode({"coin_id": cid, "coin_amount": coinAmount}),
    );
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }


// -------------------------
  
  // USERS (pour saisie intelligente bénéficiaires)
  Future<List<Map<String, dynamic>>> usersSearch(String q) async {
    final uri = Uri.parse("$baseUrl/users/search?q=$q");
    final res = await _authedRequest((h) => http.get(uri, headers: h));
    if (res.statusCode != 200) throw _httpError(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final users = (data["users"] as List<dynamic>? ?? []);
    return users.cast<Map<String, dynamic>>();
  }


  // ORDERS
  Future<List<dynamic>> listOrders({String status = "open"}) async {
    final uri = Uri.parse("$baseUrl/orders?status=$status");
    final res = await _authedRequest((h) => http.get(uri, headers: h));
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createOrder({
    required String coinId,
    required String side, // BUY/SELL
    required String orderType, // LIMIT/STOP_LOSS/TAKE_PROFIT
    required double qty,
    double? limitPrice,
    double? triggerPrice,
  }) async {
    final uri = Uri.parse("$baseUrl/orders");
    final body = {
      "coin_id": coinId,
      "side": side,
      "order_type": orderType,
      "qty": qty,
      "limit_price": limitPrice,
      "trigger_price": triggerPrice,
    };
    final res = await _authedRequest((h) => http.post(uri, headers: h, body: jsonEncode(body)));
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> cancelOrder(int id) async {
    final uri = Uri.parse("$baseUrl/orders/$id/cancel");
    final res = await _authedRequest((h) => http.post(uri, headers: h));
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

// MARKET
  // -------------------------
  Future<List<Map<String, dynamic>>> searchCoins(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];

    final res = await http.get(
      _u("/search", q: {"query": q}),
      headers: _headers(json: false),
    );
    if (res.statusCode != 200) throw _httpError(res);

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final coins = (data["coins"] as List<dynamic>? ?? []);
    return coins.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> history(String coinId, {int days = 90}) async {
    final safeId = Uri.encodeComponent(coinId);
    final res = await http.get(
      _u("/history/$safeId", q: {"days": "$days"}),
      headers: _headers(json: false),
    );
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> predict(String coinId, {int horizon = 7}) async {
    final safeId = Uri.encodeComponent(coinId);
    final res = await http.get(
      _u("/predict/$safeId", q: {"horizon": "$horizon"}),
      headers: _headers(json: false),
    );
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  
  Future<Map<String, dynamic>> pricesMarketMany(List<String> ids) async {
    final uri = Uri.parse("$baseUrl/prices/market?ids=${ids.join(',')}");
    final res = await http.get(uri);
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

Future<Map<String, dynamic>> pricesMany(List<String> ids) async {
    if (ids.isEmpty) return {"prices": {}};

    final res = await http.get(
      _u("/prices", q: {"ids": ids.join(",")}),
      headers: _headers(json: false),
    );
    if (res.statusCode != 200) throw _httpError(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

final api = Api();