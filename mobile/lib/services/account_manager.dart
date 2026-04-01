import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Stores multiple Supabase accounts (sessions) securely on-device and lets you
/// switch instantly between them.
///
/// Uses refresh tokens and flutter_secure_storage (encrypted).
class AccountManager {
  static const _storage = FlutterSecureStorage();
  static const _key = 'uapay_accounts_v1';

  SupabaseClient get _db => Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listAccounts() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    return (decoded as List).cast<Map<String, dynamic>>();
  }

  Future<void> _saveAccounts(List<Map<String, dynamic>> accounts) async {
    await _storage.write(key: _key, value: jsonEncode(accounts));
  }

  /// Save the CURRENT logged-in session into the local accounts list.
  /// Safe to call often (upsert by uid).
  Future<void> saveCurrentSession({String? label}) async {
    final session = _db.auth.currentSession;
    final user = _db.auth.currentUser;
    if (session == null || user == null) return;

    final refreshToken = session.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return;

    final email = (user.email ?? 'unknown').toLowerCase();
    final uid = user.id;

    final accounts = await listAccounts();
    final idx = accounts.indexWhere((a) => a['uid'] == uid);

    final item = <String, dynamic>{
      'uid': uid,
      'email': email,
      'label': label ?? email,
      'refreshToken': refreshToken,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (idx >= 0) {
      accounts[idx] = item;
    } else {
      accounts.add(item);
    }

    await _saveAccounts(accounts);
  }

  Future<void> removeAccount(String uid) async {
    final accounts = await listAccounts();
    accounts.removeWhere((a) => a['uid'] == uid);
    await _saveAccounts(accounts);
  }

  /// Switch instantly to another account using its refresh token.
  Future<void> switchToRefreshToken(String refreshToken) async {
    await _db.auth.setSession(refreshToken);
  }

  /// Add an account by signing in, then storing its refresh token.
  /// NOTE: This will switch the app to that account immediately (because signIn does).
  Future<void> addAccount({
    required String email,
    required String password,
  }) async {
    final res = await _db.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    if (res.session == null || res.user == null) {
      throw Exception('Connexion échouée');
    }

    await saveCurrentSession(label: email.trim());
  }
}
