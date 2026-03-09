// Modèle représentant les notes d'un étudiant pour une matière
class Note {
  final int? id;
  final int etudiantId;
  final int matiereId;
  final String matiereNom;  // Nom de la matière (récupéré via la relation)
  final double? note1;      // Première note (peut être nulle)
  final double? note2;      // Deuxième note (peut être nulle)
  final double? note3;      // Troisième note (peut être nulle)

  Note({
    this.id,
    required this.etudiantId,
    required this.matiereId,
    this.matiereNom = '',
    this.note1,
    this.note2,
    this.note3,
  });

  // Crée un objet Note depuis le JSON reçu de l'API
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      etudiantId: json['etudiant_id'],
      matiereId: json['matiere_id'],
      // Récupère le nom de la matière depuis la relation (si disponible)
      matiereNom: json['matiere'] != null ? json['matiere']['nom'] : '',
      note1: json['note1'] != null ? double.parse(json['note1'].toString()) : null,
      note2: json['note2'] != null ? double.parse(json['note2'].toString()) : null,
      note3: json['note3'] != null ? double.parse(json['note3'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'etudiant_id': etudiantId,
      'matiere_id': matiereId,
      'note1': note1,
      'note2': note2,
      'note3': note3,
    };
  }

  // Calcule la moyenne des notes disponibles
  double? get moyenne {
    List<double> notesDisponibles = [];
    if (note1 != null) notesDisponibles.add(note1!);
    if (note2 != null) notesDisponibles.add(note2!);
    if (note3 != null) notesDisponibles.add(note3!);
    if (notesDisponibles.isEmpty) return null;
    return notesDisponibles.reduce((a, b) => a + b) / notesDisponibles.length;
  }
}