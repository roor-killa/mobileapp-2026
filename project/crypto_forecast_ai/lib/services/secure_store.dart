import 'package:shared_preferences/shared_preferences.dart';

class SecureStore {
  static const _kBio = "biometric_enabled";

  static Future<bool> getBiometricEnabled() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kBio) ?? false;
    }

  static Future<void> setBiometricEnabled(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kBio, v);
  }
}