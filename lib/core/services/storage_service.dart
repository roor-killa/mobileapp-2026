import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
