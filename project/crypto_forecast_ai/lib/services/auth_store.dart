import 'package:shared_preferences/shared_preferences.dart';

class AuthStore {
  static const _kToken = "access_token";

  static Future<void> saveToken(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, token);
  }

  static Future<String?> loadToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kToken);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
  }
}
