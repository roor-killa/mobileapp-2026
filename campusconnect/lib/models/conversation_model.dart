// Utilise la vue conversations_with_other (Supabase) qui fournit :
// id, dernier_message, dernier_message_date, dernier_message_expediteur_id,
// my_user_id, other_user_id, other_nom, other_photo_url
class ConversationModel {
  final String id;
  final String? dernierMessage;
  final DateTime? dernierMessageDate;
  final String? dernierMessageExpediteurId;
  final String otherUserId;
  final String otherNom;
  final String? otherPhotoUrl;

  ConversationModel({
    required this.id,
    this.dernierMessage,
    this.dernierMessageDate,
    this.dernierMessageExpediteurId,
    required this.otherUserId,
    required this.otherNom,
    this.otherPhotoUrl,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      dernierMessage: json['dernier_message'] as String?,
      dernierMessageDate: json['dernier_message_date'] != null
          ? DateTime.parse(json['dernier_message_date'] as String)
          : null,
      dernierMessageExpediteurId:
          json['dernier_message_expediteur_id'] as String?,
      otherUserId: json['other_user_id'] as String? ?? '',
      otherNom: json['other_nom'] as String? ?? 'Utilisateur',
      otherPhotoUrl: json['other_photo_url'] as String?,
    );
  }

  // Compatibilité avec les widgets existants
  String autreParticipantNom(String myId) => otherNom;
  String autreParticipantId(String myId) => otherUserId;
  int get nonLuCount => 0;
}
