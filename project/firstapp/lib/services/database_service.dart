import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/utilisateur.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';
import 'api_config.dart';

/// Service de données — toutes les opérations passent par le backend FastAPI.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  static const _base = ApiConfig.baseUrl;

  // ── Utilisateurs ────────────────────────────────────────────────────────────

  Future<bool> emailExiste(String email) async {
    final uri = Uri.parse('$_base/users/existe')
        .replace(queryParameters: {'email': email});
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['existe'] as bool;
    }
    return false;
  }

  Future<int> creerUtilisateur(Utilisateur u) async {
    final res = await http.post(
      Uri.parse('$_base/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(u.toMap()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['id'] as int;
    }
    if (res.statusCode == 400) throw Exception('EMAIL_EXISTE');
    throw Exception('Erreur création utilisateur: ${res.statusCode}');
  }

  Future<Utilisateur?> trouverParEmail(String email) async {
    final uri = Uri.parse('$_base/users/par-email')
        .replace(queryParameters: {'email': email});
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return Utilisateur.fromMap(
          jsonDecode(res.body) as Map<String, dynamic>);
    }
    return null;
  }

  Future<Utilisateur?> getUtilisateurById(int id) async {
    final res = await http.get(Uri.parse('$_base/users/$id'));
    if (res.statusCode == 200) {
      return Utilisateur.fromMap(
          jsonDecode(res.body) as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> mettreAJourSolde(int userId, double nouveauSolde) async {
    await http.patch(
      Uri.parse('$_base/users/$userId/solde'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'solde_actuel': nouveauSolde}),
    );
  }

  Future<void> mettreAJourUtilisateur(int id,
      {String? nom, String? motDePasse}) async {
    final body = <String, dynamic>{};
    if (nom != null) body['nom'] = nom;
    if (motDePasse != null) body['mot_de_passe'] = motDePasse;
    await http.patch(
      Uri.parse('$_base/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  Future<List<Utilisateur>> getTousLesUtilisateurs(int excludeId) async {
    final uri = Uri.parse('$_base/users')
        .replace(queryParameters: {'exclude': excludeId.toString()});
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list
          .map((e) => Utilisateur.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ── Transactions ────────────────────────────────────────────────────────────

  Future<int> enregistrerTransaction(TransactionModel t) async {
    final res = await http.post(
      Uri.parse('$_base/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(t.toMap()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['id'] as int;
    }
    throw Exception('Erreur enregistrement transaction: ${res.statusCode}');
  }

  Future<List<TransactionModel>> getTransactions(int userId) async {
    final uri = Uri.parse('$_base/transactions')
        .replace(queryParameters: {'user_id': userId.toString()});
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list
          .map((e) => TransactionModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<TransactionModel>> getTransactionsRecentes(int userId,
      {int limit = 5}) async {
    final uri = Uri.parse('$_base/transactions').replace(queryParameters: {
      'user_id': userId.toString(),
      'limit': limit.toString(),
    });
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list
          .map((e) => TransactionModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ── Favoris ────────────────────────────────────────────────────────────────

  Future<List<int>> getFavoris(int userId) async {
    final res =
        await http.get(Uri.parse('$_base/users/$userId/favoris'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return List<int>.from(data['favoris'] as List);
    }
    return [];
  }

  Future<void> toggleFavori(int userId, int destinataireId) async {
    await http.post(
        Uri.parse('$_base/users/$userId/favoris/$destinataireId/toggle'));
  }

  Future<bool> estFavori(int userId, int destinataireId) async {
    final res = await http
        .get(Uri.parse('$_base/users/$userId/favoris/$destinataireId'));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['favori'] as bool;
    }
    return false;
  }

  // ── Objectifs d'épargne ────────────────────────────────────────────────────

  Future<int> creerObjectif(GoalModel goal) async {
    final res = await http.post(
      Uri.parse('$_base/objectifs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(goal.toMap()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['id'] as int;
    }
    throw Exception('Erreur création objectif: ${res.statusCode}');
  }

  Future<List<GoalModel>> getObjectifs(int userId) async {
    final uri = Uri.parse('$_base/objectifs')
        .replace(queryParameters: {'user_id': userId.toString()});
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List<dynamic>;
      return list
          .map((e) => GoalModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> mettreAJourObjectif(int goalId, double nouveauMontant) async {
    await http.patch(
      Uri.parse('$_base/objectifs/$goalId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'montant_actuel': nouveauMontant}),
    );
  }

  Future<void> supprimerObjectif(int goalId) async {
    await http.delete(Uri.parse('$_base/objectifs/$goalId'));
  }
}
