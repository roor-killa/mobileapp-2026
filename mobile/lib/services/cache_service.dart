import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tx.dart';

class CacheService {
  static const _balanceKey = 'cache_balance_bkn';
  static const _txKey = 'cache_transactions';

  Future<void> saveBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, balance);
  }

  Future<double?> loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_balanceKey);
  }

  Future<void> saveTransactions(List<Tx> txs) async {
    final prefs = await SharedPreferences.getInstance();
    final list = txs.map((t) => {
      'id': t.id,
      'type': t.type,
      'amount_bkn': t.amountBkn,
      'status': t.status,
      'created_at': t.createdAt,
    }).toList();
    await prefs.setString(_txKey, jsonEncode(list));
  }

  Future<List<Tx>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_txKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((m) => Tx.fromJson(m)).toList();
  }
}
