import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/etudiant.dart';

class ApiService {
  // Adresse de l'API Laravel (10.0.2.2 = localhost depuis l'émulateur Android)
  static const String baseUrl = 'http://10.0.2.2/backend-api/public/api';

  // ─────────────────────────────────────────
  // AUTHENTIFICATION
  // ─────────────────────────────────────────

  /// Connexion d'un professeur
  /// Envoie email + password à l'API et retourne true si succès
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true; // true si connexion réussie
    }
    return false; // false si email/password incorrect
  }

  /// Inscription d'un nouveau professeur
  /// Envoie nom, prenom, email, password à l'API
  /// Retourne true si l'inscription a réussi
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
      return data['success'] == true; // true si inscription réussie
    }
    return false; // false si email déjà utilisé ou erreur
  }

  // ─────────────────────────────────────────
  // ÉTUDIANTS
  // ─────────────────────────────────────────

  /// Récupère la liste de tous les étudiants depuis l'API
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
}