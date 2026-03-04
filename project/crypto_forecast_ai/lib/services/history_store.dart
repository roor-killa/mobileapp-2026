import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_entry.dart';

class HistoryStore {
  static const _key = "prediction_history_v1";

  Future<List<HistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  Future<void> add(HistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await load();
    final newList = [entry, ...current];
    final encoded = json.encode(newList.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
