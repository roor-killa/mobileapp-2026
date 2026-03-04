import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/utilisateur.dart';
import '../models/transaction_model.dart';

/// Stockage local via SharedPreferences (fonctionne sur Web, Android, Windows...)
/// Les données sont sérialisées en JSON.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  static const _keyUsers = 'users';
  static const _keyTransactions = 'transactions';
  static const _keyNextUserId = 'next_user_id';
  static const _keyNextTransactionId = 'next_transaction_id';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // --- Utilisateurs ---

  Future<List<Map<String, dynamic>>> _getUsers() async {
    final prefs = await _prefs;
    final json = prefs.getString(_keyUsers);
    if (json == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(json));
  }

  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUsers, jsonEncode(users));
  }

  Future<int> creerUtilisateur(Utilisateur u) async {
    final prefs = await _prefs;
    final users = await _getUsers();
    final id = prefs.getInt(_keyNextUserId) ?? 1;
    final map = u.toMap();
    map['id'] = id;
    users.add(map);
    await _saveUsers(users);
    await prefs.setInt(_keyNextUserId, id + 1);
    return id;
  }

  Future<Utilisateur?> trouverParEmail(String email) async {
    final users = await _getUsers();
    final match = users.where((u) => u['email'] == email).toList();
    if (match.isEmpty) return null;
    return Utilisateur.fromMap(match.first);
  }

  Future<void> mettreAJourSolde(int userId, double nouveauSolde) async {
    final users = await _getUsers();
    for (final u in users) {
      if (u['id'] == userId) {
        u['solde_actuel'] = nouveauSolde;
        break;
      }
    }
    await _saveUsers(users);
  }

  // --- Transactions ---

  Future<List<Map<String, dynamic>>> _getTransactions() async {
    final prefs = await _prefs;
    final json = prefs.getString(_keyTransactions);
    if (json == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(json));
  }

  Future<void> _saveTransactions(List<Map<String, dynamic>> transactions) async {
    final prefs = await _prefs;
    await prefs.setString(_keyTransactions, jsonEncode(transactions));
  }

  Future<int> enregistrerTransaction(TransactionModel t) async {
    final prefs = await _prefs;
    final transactions = await _getTransactions();
    final id = prefs.getInt(_keyNextTransactionId) ?? 1;
    final map = t.toMap();
    map['id'] = id;
    transactions.add(map);
    await _saveTransactions(transactions);
    await prefs.setInt(_keyNextTransactionId, id + 1);
    return id;
  }

  Future<List<TransactionModel>> getTransactions(int userId) async {
    final all = await _getTransactions();
    final liste = all
        .where((t) => t['utilisateur_id'] == userId)
        .map(TransactionModel.fromMap)
        .toList();
    liste.sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
    return liste;
  }
}
