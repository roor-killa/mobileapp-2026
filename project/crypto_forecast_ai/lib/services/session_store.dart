import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _kToken = "auth_token";
  static const _kRefresh = "refresh_token"; // ✅ ajouté

  static Future<String?> loadToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kToken);
  }

  static Future<void> saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
  }

  // ✅ Refresh token helpers
  static Future<void> saveRefreshToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kRefresh, token);
  }

  static Future<String?> loadRefreshToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kRefresh);
  }

  static Future<void> clearSession() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kRefresh);
  }
}
