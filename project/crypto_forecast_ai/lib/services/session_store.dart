import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _kToken = "auth_token";
  static const _kEmail = "auth_email";

  static Future<String?> loadToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kToken);
  }

  static Future<String?> loadEmail() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kEmail);
  }

  static Future<void> saveSession({required String token, required String email}) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kToken, token);
    await sp.setString(_kEmail, email);
  }

  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kToken);
    await sp.remove(_kEmail);
  }
}