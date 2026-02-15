import 'dart:collection';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CacheService {
  final _mem = LinkedHashMap<String, Uint8List>();
  final int maxItems;

  CacheService({this.maxItems = 60});

  Future<File> _fileForKey(String key) async {
    final dir = await getApplicationSupportDirectory();
    final safe = sha256.convert(key.codeUnits).toString();
    final folder = Directory('${dir.path}/ai_cache');
    if (!await folder.exists()) await folder.create(recursive: true);
    return File('${folder.path}/$safe.png');
  }

  Uint8List? getMem(String key) {
    final v = _mem.remove(key);
    if (v != null) _mem[key] = v; // LRU refresh
    return v;
  }

  void putMem(String key, Uint8List bytes) {
    _mem[key] = bytes;
    if (_mem.length > maxItems) {
      _mem.remove(_mem.keys.first);
    }
  }

  Future<Uint8List?> get(String key) async {
    final mem = getMem(key);
    if (mem != null) return mem;

    final f = await _fileForKey(key);
    if (!await f.exists()) return null;

    final bytes = await f.readAsBytes();
    putMem(key, bytes);
    return bytes;
  }

  Future<void> put(String key, Uint8List bytes) async {
    putMem(key, bytes);
    final f = await _fileForKey(key);
    await f.writeAsBytes(bytes, flush: true);
  }
}
