import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _kPro = 'pro_mode';
  static const _kRes = 'resolution';
  static const _kBatch = 'batch_count';

  bool proMode = false;
  int resolution = 1024;
  int batchCount = 3;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    proMode = p.getBool(_kPro) ?? false;
    resolution = p.getInt(_kRes) ?? 1024;
    batchCount = p.getInt(_kBatch) ?? 3;

    if (resolution != 512 && resolution != 1024) resolution = 1024;
    if (batchCount < 1) batchCount = 1;
    if (batchCount > 20) batchCount = 20;
  }

  Future<void> setProMode(bool v) async {
    proMode = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kPro, v);
  }

  Future<void> setResolution(int v) async {
    resolution = (v == 512) ? 512 : 1024;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kRes, resolution);
  }

  Future<void> setBatchCount(int v) async {
    batchCount = v.clamp(1, 20);
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kBatch, batchCount);
  }
}
