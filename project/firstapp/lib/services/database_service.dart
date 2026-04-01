import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/utilisateur.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';

/// Stockage local via SharedPreferences (fonctionne sur Web, Android, Windows...)
/// Les données sont sérialisées en JSON.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  static const _keyUsers = 'users';
  static const _keyTransactions = 'transactions';
  static const _keyNextUserId = 'next_user_id';
  static const _keyNextTransactionId = 'next_transaction_id';
  static const _keyFavorites = 'favorites';
  static const _keyGoals = 'goals';
  static const _keyNextGoalId = 'next_goal_id';

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

  Future<bool> emailExiste(String email) async {
    final users = await _getUsers();
    return users.any((u) => u['email'] == email);
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

  Future<Utilisateur?> getUtilisateurById(int id) async {
    final users = await _getUsers();
    final matches = users.where((u) => u['id'] == id).toList();
    if (matches.isEmpty) return null;
    return Utilisateur.fromMap(matches.first);
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

  Future<void> mettreAJourUtilisateur(int id, {String? nom, String? motDePasse}) async {
    final users = await _getUsers();
    for (final u in users) {
      if (u['id'] == id) {
        if (nom != null) u['nom'] = nom;
        if (motDePasse != null) u['mot_de_passe'] = motDePasse;
        break;
      }
    }
    await _saveUsers(users);
  }

  Future<List<Utilisateur>> getTousLesUtilisateurs(int excludeId) async {
    final users = await _getUsers();
    return users
        .where((u) => u['id'] != excludeId)
        .map(Utilisateur.fromMap)
        .toList();
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

  Future<List<TransactionModel>> getTransactionsRecentes(int userId, {int limit = 5}) async {
    final all = await getTransactions(userId);
    return all.take(limit).toList();
  }

  // --- Favoris (destinataires fréquents) ---

  /// Retourne la liste des IDs utilisateurs favoris pour [userId].
  Future<List<int>> getFavoris(int userId) async {
    final prefs = await _prefs;
    final json = prefs.getString('${_keyFavorites}_$userId');
    if (json == null) return [];
    return List<int>.from(jsonDecode(json));
  }

  Future<void> toggleFavori(int userId, int destinataireId) async {
    final prefs = await _prefs;
    final favoris = await getFavoris(userId);
    if (favoris.contains(destinataireId)) {
      favoris.remove(destinataireId);
    } else {
      favoris.add(destinataireId);
    }
    await prefs.setString('${_keyFavorites}_$userId', jsonEncode(favoris));
  }

  Future<bool> estFavori(int userId, int destinataireId) async {
    final favoris = await getFavoris(userId);
    return favoris.contains(destinataireId);
  }

  // --- Objectifs d'épargne ---

  Future<List<Map<String, dynamic>>> _getGoalsRaw() async {
    final prefs = await _prefs;
    final json = prefs.getString(_keyGoals);
    if (json == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(json));
  }

  Future<void> _saveGoals(List<Map<String, dynamic>> goals) async {
    final prefs = await _prefs;
    await prefs.setString(_keyGoals, jsonEncode(goals));
  }

  Future<int> creerObjectif(GoalModel goal) async {
    final prefs = await _prefs;
    final goals = await _getGoalsRaw();
    final id = prefs.getInt(_keyNextGoalId) ?? 1;
    final map = goal.toMap();
    map['id'] = id;
    goals.add(map);
    await _saveGoals(goals);
    await prefs.setInt(_keyNextGoalId, id + 1);
    return id;
  }

  Future<List<GoalModel>> getObjectifs(int userId) async {
    final all = await _getGoalsRaw();
    return all
        .where((g) => g['utilisateur_id'] == userId)
        .map(GoalModel.fromMap)
        .toList();
  }

  Future<void> mettreAJourObjectif(int goalId, double nouveauMontant) async {
    final goals = await _getGoalsRaw();
    for (final g in goals) {
      if (g['id'] == goalId) {
        g['montant_actuel'] = nouveauMontant;
        break;
      }
    }
    await _saveGoals(goals);
  }

  Future<void> supprimerObjectif(int goalId) async {
    final goals = await _getGoalsRaw();
    goals.removeWhere((g) => g['id'] == goalId);
    await _saveGoals(goals);
  }
}
