import 'package:shared_preferences/shared_preferences.dart';

class WatchlistStore {
  static const _k = "watchlist_ids";

  static Future<List<String>> load() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_k) ?? <String>[];
  }

  static Future<void> save(List<String> ids) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_k, ids);
  }

  static Future<List<String>> toggle(String id) async {
    final key = id.trim().toLowerCase();
    if (key.isEmpty) return await load();

    final ids = (await load()).map((e) => e.toLowerCase()).toSet();
    if (ids.contains(key)) {
      ids.remove(key);
    } else {
      ids.add(key);
    }
    final out = ids.toList()..sort();
    await save(out);
    return out;
  }

  // ----------------------------
  // ✅ Compat pour le code UI
  // ----------------------------
  static Future<List<String>> loadIds() => load();

  static Future<void> addId(String id) async {
    final key = id.trim().toLowerCase();
    if (key.isEmpty) return;

    final ids = (await load()).map((e) => e.toLowerCase()).toSet();
    ids.add(key);
    final out = ids.toList()..sort();
    await save(out);
  }

  static Future<void> removeId(String id) async {
    final key = id.trim().toLowerCase();
    if (key.isEmpty) return;

    final ids = (await load()).map((e) => e.toLowerCase()).toSet();
    ids.remove(key);
    final out = ids.toList()..sort();
    await save(out);
  }
}
