import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/history_entry.dart';

class HistoryStore {
  static const _metaFile = 'history.json';
  static const _folder = 'ai_history';

  Future<Directory> _dir() async {
    final base = await getApplicationSupportDirectory();
    final d = Directory('${base.path}/$_folder');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  Future<File> _meta() async {
    final d = await _dir();
    return File('${d.path}/$_metaFile');
  }

  Future<List<HistoryEntry>> load() async {
    final f = await _meta();
    if (!await f.exists()) return [];
    final txt = await f.readAsString();
    final arr = (jsonDecode(txt) as List).cast<Map<String, dynamic>>();
    final list = arr.map(HistoryEntry.fromJson).toList();
    list.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    return list;
  }

  Future<void> _save(List<HistoryEntry> list) async {
    final f = await _meta();
    final arr = list.map((e) => e.toJson()).toList();
    await f.writeAsString(jsonEncode(arr), flush: true);
  }

  Future<HistoryEntry> add({
    required String style,
    required Uint8List pngBytes,
    required int resolution,
    required String extra,
  }) async {
    final d = await _dir();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final path = '${d.path}/$id-$style.png';
    await File(path).writeAsBytes(pngBytes, flush: true);

    final entry = HistoryEntry(
      id: id,
      style: style,
      imagePath: path,
      resolution: resolution,
      extra: extra,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      favorite: false,
    );

    final list = await load();
    list.insert(0, entry);
    await _save(list);
    return entry;
  }

  Future<void> toggleFavorite(String id) async {
    final list = await load();
    for (final e in list) {
      if (e.id == id) {
        e.favorite = !e.favorite;
        break;
      }
    }
    await _save(list);
  }

  Future<void> delete(String id) async {
    final list = await load();
    final target = list.where((e) => e.id == id).toList();
    for (final e in target) {
      final f = File(e.imagePath);
      if (await f.exists()) await f.delete();
    }
    list.removeWhere((e) => e.id == id);
    await _save(list);
  }

  Future<void> clearAll() async {
    final d = await _dir();
    if (await d.exists()) {
      await d.delete(recursive: true);
    }
  }
}
