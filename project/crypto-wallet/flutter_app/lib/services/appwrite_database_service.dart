import 'package:appwrite/appwrite.dart';
import '../config/appwrite_config.dart';
import 'appwrite_service.dart';

/// Service pour interagir avec la table "ondes" dans Appwrite.
class AppwriteDatabaseService {
  late final TablesDB _tablesDB;

  AppwriteDatabaseService() {
    _tablesDB = TablesDB(appwriteClient);
  }

  /// Crée une ligne (onde) dans la table.
  Future<Map<String, dynamic>> createOnde({
    required double waveLength,
    required double amplitude,
    required double frequency,
    double? phaseShift,
    String? waveType,
    String? origin,
  }) async {
    final data = <String, dynamic>{
      'waveLength': waveLength,
      'amplitude': amplitude,
      'frequency': frequency,
      if (phaseShift != null) 'phaseShift': phaseShift,
      if (waveType != null) 'waveType': waveType,
      if (origin != null) 'origin': origin,
    };
    final row = await _tablesDB.createRow(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.ondesTableId,
      rowId: ID.unique(),
      data: data,
    );
    return row.toMap();
  }

  /// Liste les lignes de la table ondes.
  Future<List<Map<String, dynamic>>> listOndes({
    List<String>? queries,
    int limit = 25,
  }) async {
    final q = [
      Query.limit(limit),
      ...?queries,
    ];
    final result = await _tablesDB.listRows(
      databaseId: AppwriteConfig.databaseId,
      tableId: AppwriteConfig.ondesTableId,
      queries: q,
    );
    return result.rows.map((r) => r.toMap()).toList();
  }

  /// Récupère une onde par son ID.
  Future<Map<String, dynamic>?> getOnde(String rowId) async {
    try {
      final row = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: AppwriteConfig.ondesTableId,
        rowId: rowId,
      );
      return row.toMap();
    } catch (_) {
      return null;
    }
  }
}
