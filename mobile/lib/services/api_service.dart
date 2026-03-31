import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/etudiant.dart';
import '../models/matiere.dart';
import '../models/note.dart';
import '../models/professeur.dart';
import '../models/admin.dart';
import 'session_service.dart';

class ApiService {

  static const String baseUrl = 'http://10.0.2.2/backend-api/public/api';

  // ==========================================================
  // AUTHENTIFICATION PROFESSEUR
  // ==========================================================

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

  Future<Map<String, dynamic>> resetPasswordProfesseur(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/professeur/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
    return json.decode(response.body);
  }

  Future<bool> register(
      String nom, String prenom, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final professeur = Professeur.fromJson(data['professeur']);
        SessionService().connecter(professeur);
        return true;
      }
    }
    return false;
  }

  // ==========================================================
  // AUTHENTIFICATION ÉTUDIANT
  // ==========================================================

  Future<bool> loginEtudiant(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/etudiant/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final etudiant = Etudiant.fromJson(data['etudiant']);
        SessionService().connecterEtudiant(etudiant);
        return true;
      }
    }
    return false;
  }

  // ==========================================================
  // AUTHENTIFICATION ADMIN
  // ==========================================================

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

  // ==========================================================
  // GESTION PROFESSEURS (admin seulement)
  // ==========================================================

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

  Future<bool> creerProfesseur(String nom, String prenom, String email,
      String password, List<int> matiereIds) async {
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

  Future<bool> modifierMatieresProfesseur(
      int professeurId, List<int> matiereIds) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/professeurs/$professeurId/matieres'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'matieres': matiereIds}),
    );
    return response.statusCode == 200;
  }

  Future<bool> supprimerProfesseur(int professeurId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/professeurs/$professeurId'),
    );
    return response.statusCode == 200;
  }

  // ==========================================================
  // ÉTUDIANTS
  // ==========================================================

  Future<List<Etudiant>> getEtudiants() async {
    final response = await http.get(Uri.parse('$baseUrl/etudiants'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Etudiant.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement étudiants');
  }

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

  Future<void> deleteEtudiant(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/etudiants/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erreur suppression étudiant');
    }
  }

  // ==========================================================
  // CLASSES
  // ==========================================================

  Future<List<Map<String, dynamic>>> getClasses() async {
    final response = await http.get(Uri.parse('$baseUrl/classes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    throw Exception('Erreur chargement classes');
  }

  Future<List<Map<String, dynamic>>> getMoyennesClasse(int classeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/classes/$classeId/moyennes'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['moyennes']);
    }
    throw Exception('Erreur chargement moyennes classe');
  }

  // ==========================================================
  // MATIÈRES
  // ==========================================================

  Future<List<Matiere>> getMatieres() async {
    final response = await http.get(Uri.parse('$baseUrl/matieres'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Matiere.fromJson(e)).toList();
    }
    throw Exception('Erreur chargement matières');
  }

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

  Future<bool> assignerMatieres(
      int professeurId, List<int> matiereIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/professeurs/$professeurId/matieres'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'matieres': matiereIds}),
    );
    return response.statusCode == 200;
  }

  // ==========================================================
  // NOTES
  // ==========================================================

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

  Future<bool> sauvegarderNotes(Note note) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(note.toJson()),
    );
    return response.statusCode == 200;
  }
}