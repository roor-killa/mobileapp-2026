import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  final String baseUrl;
  String? _token;

  Api({this.baseUrl = "http://127.0.0.1:8000"});

  void setToken(String? token) => _token = token;

  Map<String, String> _headers({bool auth = false}) {
    final h = <String, String>{
      "Content-Type": "application/json",
    };
    if (auth && _token != null) {
      h["Authorization"] = "Bearer $_token";
    }
    return h;
  }

  Exception _err(http.Response res) {
    // Essaye d'extraire un message JSON {detail: "..."} sinon renvoie brut
    try {
      final data = jsonDecode(res.body);
      if (data is Map && data["detail"] != null) {
        return Exception(data["detail"].toString());
      }
    } catch (_) {}
    return Exception(res.body.isNotEmpty ? res.body : "HTTP ${res.statusCode}");
  }

  // ---------- AUTH ----------
  Future<Map<String, dynamic>> register(String email, String password) async {
    final uri = Uri.parse("$baseUrl/auth/register");
    final res = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode({"email": email, "password": password}),
    );
    if (res.statusCode != 200) throw _err(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<String> login(String email, String password) async {
    final uri = Uri.parse("$baseUrl/auth/login");
    final res = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode({"email": email, "password": password}),
    );
    if (res.statusCode != 200) throw _err(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final token = data["access_token"] as String;
    _token = token;
    return token;
  }

  Future<Map<String, dynamic>> me() async {
    final uri = Uri.parse("$baseUrl/me");
    final res = await http.get(uri, headers: _headers(auth: true));
    if (res.statusCode != 200) throw _err(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ---------- BANK (USD) ----------
  Future<Map<String, dynamic>> bankBalance() async {
    final uri = Uri.parse("$baseUrl/bank/balance");
    final res = await http.get(uri, headers: _headers(auth: true));
    if (res.statusCode != 200) throw _err(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> bankTransfer({
    required String toEmail,
    required double usdAmount,
    String note = "",
  }) async {
    final uri = Uri.parse("$baseUrl/bank/transfer");
    final res = await http.post(
      uri,
      headers: _headers(auth: true),
      body: jsonEncode({
        "to_email": toEmail,
        "usd_amount": usdAmount,
        "note": note,
      }),
    );
    if (res.statusCode != 200) throw _err(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> bankTransactions({int limit = 30}) async {
    final uri = Uri.parse("$baseUrl/bank/transactions?limit=$limit");
    final res = await http.get(uri, headers: _headers(auth: true));
    if (res.statusCode != 200) throw _err(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  // ---------- WALLET (CRYPTO) ----------
  Future<Map<String, dynamic>> wallet() async {
    final uri = Uri.parse("$baseUrl/wallet");
    final res = await http.get(uri, headers: _headers(auth: true));
    if (res.statusCode != 200) throw _err(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> buy(String coinId, double usdAmount) async {
    final uri = Uri.parse("$baseUrl/trade/buy");
    final res = await http.post(
      uri,
      headers: _headers(auth: true),
      body: jsonEncode({"coin_id": coinId, "usd_amount": usdAmount}),
    );
    if (res.statusCode != 200) throw _err(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sell(String coinId, double coinAmount) async {
    final uri = Uri.parse("$baseUrl/trade/sell");
    final res = await http.post(
      uri,
      headers: _headers(auth: true),
      body: jsonEncode({"coin_id": coinId, "coin_amount": coinAmount}),
    );
    if (res.statusCode != 200) throw _err(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> transactions() async {
    final uri = Uri.parse("$baseUrl/transactions");
    final res = await http.get(uri, headers: _headers(auth: true));
    if (res.statusCode != 200) throw _err(res);
    return jsonDecode(res.body) as List<dynamic>;
  }

  // ---------- MARKET ----------
  Future<List<Map<String, dynamic>>> searchCoins(String query) async {
    final uri = Uri.parse("$baseUrl/search?query=$query");
    final res = await http.get(uri);
    if (res.statusCode != 200) throw _err(res);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final coins = (data["coins"] as List<dynamic>? ?? []);
    return coins.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> history(String coinId, {int days = 90}) async {
    final uri = Uri.parse("$baseUrl/history/$coinId?days=$days");
    final res = await http.get(uri);
    if (res.statusCode != 200) throw _err(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> predict(String coinId, {int horizon = 7}) async {
    final uri = Uri.parse("$baseUrl/predict/$coinId?horizon=$horizon");
    final res = await http.get(uri);
    if (res.statusCode != 200) throw _err(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> priceOne(String coinId) async {
    final uri = Uri.parse("$baseUrl/price/$coinId");
    final res = await http.get(uri);
    if (res.statusCode != 200) throw _err(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> pricesMany(List<String> coinIds) async {
    final ids = coinIds.join(",");
    final uri = Uri.parse("$baseUrl/prices?ids=$ids");
    final res = await http.get(uri);
    if (res.statusCode != 200) throw _err(res);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

// Singleton pratique (optionnel)
final api = Api(baseUrl: "http://127.0.0.1:8000");