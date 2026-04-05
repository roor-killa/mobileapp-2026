// Utilise la vue announcements_full (Supabase) qui fournit :
// id, titre, description, categorie, date_publication, user_id,
// user_nom, user_photo_url, nb_favoris
class AnnouncementModel {
  final String id;
  final String titre;
  final String description;
  final String categorie;
  final String userId;
  final String userNom;
  final String? userPhotoUrl;
  final DateTime datePublication;
  final int nbFavoris;
  final bool isFavori;

  AnnouncementModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.categorie,
    required this.userId,
    required this.userNom,
    this.userPhotoUrl,
    required this.datePublication,
    this.nbFavoris = 0,
    this.isFavori = false,
  });

  factory AnnouncementModel.fromJson(
    Map<String, dynamic> json, {
    bool isFavori = false,
  }) {
    return AnnouncementModel(
      id: json['id'] as String,
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categorie: json['categorie'] as String? ?? 'autre',
      userId: json['user_id'] as String? ?? '',
      userNom: json['user_nom'] as String? ?? '',
      userPhotoUrl: json['user_photo_url'] as String?,
      datePublication: json['date_publication'] != null
          ? DateTime.parse(json['date_publication'] as String)
          : DateTime.now(),
      nbFavoris: (json['nb_favoris'] as num?)?.toInt() ?? 0,
      isFavori: isFavori,
    );
  }

  Map<String, dynamic> toMap() => {
        'titre': titre,
        'description': description,
        'categorie': categorie,
        'user_id': userId,
        'date_publication': datePublication.toUtc().toIso8601String(),
      };

  // Compatibilité avec les widgets existants
  bool isFavoriOf(String userId) => isFavori;
}
