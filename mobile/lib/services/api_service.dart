import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/etudiant.dart';
import '../models/matiere.dart';
import '../models/note.dart';
import '../models/professeur.dart';
import '../models/admin.dart';
import 'session_service.dart';

class ApiService {
  // Adresse de l'API Laravel (10.0.2.2 = localhost depuis l'émulateur Android)
  static const String baseUrl = 'http://10.0.2.2/backend-api/public/api';

  // ─────────────────────────────────────────
  // AUTHENTIFICATION PROFESSEUR
  // ─────────────────────────────────────────

  /// Connexion d'un professeur
  /// Sauvegarde le professeur en session si succès
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final professeur = Professeur.fromJson(data['professeur']);
        SessionService().connecter(professeur);
        return true;
      }
    }
    return false;
  }

  // ─────────────────────────────────────────
  // AUTHENTIFICATION ADMIN
  // ─────────────────────────────────────────

  /// Connexion de l'admin
  /// Sauvegarde l'admin en session si succès
  Future<bool> loginAdmin(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final admin = Admin.fromJson(data['admin']);
        SessionService().connecterAdmin(admin);
        return true;
      }
    }
    return false;
  }

  // ─────────────────────────────────────────
  // GESTION PROFESSEURS (admin seulement)
  // ─────────────────────────────────────────

  /// Récupère la liste de tous les professeurs avec leurs matières
  Future<List<Professeur>> getProfesseurs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/professeurs'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Professeur.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement professeurs');
  }

  /// Crée un nouveau professeur (avec ses matières)
  Future<bool> creerProfesseur(
    String nom,
    String prenom,
    String email,
    String password,
    List<int> matiereIds,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/professeurs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'password': password,
        'matieres': matiereIds,
      }),
    );
    return response.statusCode == 201;
  }

  /// Modifie les matières d'un professeur (par l'admin)
  Future<bool> modifierMatieresProfesseur(
      int professeurId, List<int> matiereIds) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/professeurs/$professeurId/matieres'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'matieres': matiereIds}),
    );
    return response.statusCode == 200;
  }

  /// Supprime un professeur
  Future<bool> supprimerProfesseur(int professeurId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/professeurs/$professeurId'),
    );
    return response.statusCode == 200;
  }

  // ─────────────────────────────────────────
  // ÉTUDIANTS
  // ─────────────────────────────────────────

  /// Récupère la liste de tous les étudiants
  Future<List<Etudiant>> getEtudiants() async {
    final response = await http.get(Uri.parse('$baseUrl/etudiants'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Etudiant.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement étudiants');
  }

  /// Ajoute un nouvel étudiant
  Future<Etudiant> addEtudiant(Etudiant etudiant) async {
    final response = await http.post(
      Uri.parse('$baseUrl/etudiants'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(etudiant.toJson()),
    );
    if (response.statusCode == 201) {
      return Etudiant.fromJson(json.decode(response.body));
    }
    throw Exception('Erreur ajout étudiant');
  }

  /// Modifie un étudiant existant
  Future<Etudiant> updateEtudiant(Etudiant etudiant) async {
    final response = await http.put(
      Uri.parse('$baseUrl/etudiants/${etudiant.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(etudiant.toJson()),
    );
    if (response.statusCode == 200) {
      return Etudiant.fromJson(json.decode(response.body));
    }
    throw Exception('Erreur modification étudiant');
  }

  /// Supprime un étudiant par son id
  Future<void> deleteEtudiant(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/etudiants/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erreur suppression étudiant');
    }
  }

  // ─────────────────────────────────────────
  // MATIÈRES
  // ─────────────────────────────────────────

  /// Récupère la liste de toutes les matières disponibles
  Future<List<Matiere>> getMatieres() async {
    final response = await http.get(Uri.parse('$baseUrl/matieres'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Matiere.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement matières');
  }

  /// Récupère les matières d'un professeur
  Future<List<Matiere>> getMatieresProf(int professeurId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/professeurs/$professeurId/matieres'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Matiere.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement matières du professeur');
  }

  /// Assigne des matières à un professeur (max 2) - utilisé par le prof lui-même
  Future<bool> assignerMatieres(int professeurId, List<int> matiereIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/professeurs/$professeurId/matieres'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'matieres': matiereIds}),
    );
    return response.statusCode == 200;
  }

  // ─────────────────────────────────────────
  // NOTES
  // ─────────────────────────────────────────

  /// Récupère toutes les notes d'un étudiant
  Future<List<Note>> getNotesEtudiant(int etudiantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/etudiants/$etudiantId/notes'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Note.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement notes');
  }

  /// Ajoute ou met à jour les notes d'un étudiant pour une matière
  Future<bool> sauvegarderNotes(Note note) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(note.toJson()),
    );
    return response.statusCode == 200;
  }
}