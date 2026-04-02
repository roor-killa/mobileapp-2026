import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late Box<dynamic> _box;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('negs_app');
  }

  Future<void> saveUser(String key, dynamic value) async {
    await _box.put(key, value);
  }

  dynamic getUser(String key) {
    return _box.get(key);
  }

  Future<void> deleteUser(String key) async {
    await _box.delete(key);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  bool isLoggedIn() {
    return _box.containsKey('isLoggedIn') && _box.get('isLoggedIn') == true;
  }

  Future<void> setLoggedIn(bool value) async {
    await _box.put('isLoggedIn', value);
  }

  String? getToken() {
    return _box.get('token') as String?;
  }

  Future<void> setToken(String token) async {
    await _box.put('token', token);
  }

  String? getUserId() {
    return _box.get('userId') as String?;
  }

  Future<void> setUserId(String userId) async {
    await _box.put('userId', userId);
  }
}
