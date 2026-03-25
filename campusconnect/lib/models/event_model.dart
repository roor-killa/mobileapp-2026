// Utilise la vue events_full (Supabase) qui fournit :
// id, titre, description, lieu, date, created_at,
// organisateur_id, organisateur_nom, nb_participants
class EventModel {
  final String id;
  final String titre;
  final String description;
  final String lieu;
  final DateTime date;
  final String organisateurId;
  final String organisateurNom;
  final int nbParticipants;
  final bool _isParticipant;

  EventModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.lieu,
    required this.date,
    required this.organisateurId,
    required this.organisateurNom,
    this.nbParticipants = 0,
    bool isParticipant = false,
  }) : _isParticipant = isParticipant;

  factory EventModel.fromJson(
    Map<String, dynamic> json, {
    bool isParticipant = false,
  }) {
    return EventModel(
      id: json['id'] as String,
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      lieu: json['lieu'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      organisateurId: json['organisateur_id'] as String? ?? '',
      organisateurNom: json['organisateur_nom'] as String? ?? '',
      nbParticipants: (json['nb_participants'] as num?)?.toInt() ?? 0,
      isParticipant: isParticipant,
    );
  }

  Map<String, dynamic> toMap() => {
        'titre': titre,
        'description': description,
        'lieu': lieu,
        'date': date.toUtc().toIso8601String(),
        'organisateur_id': organisateurId,
      };

  // Compatibilité avec les widgets existants
  bool isParticipant(String userId) => _isParticipant;
  bool get isPast => date.isBefore(DateTime.now());
}
