import 'package:flutter/material.dart';
import '../models/etudiant.dart';
import '../models/matiere.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

// Écran pour gérer les notes d'un étudiant
// Toutes les matières sont visibles
// Mais le bouton modifier n'apparaît que pour les matières du professeur connecté
class NotesScreen extends StatefulWidget {
  final Etudiant etudiant;

  const NotesScreen({super.key, required this.etudiant});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final ApiService _apiService = ApiService();
  final SessionService _session = SessionService();

  // Toutes les matières disponibles
  List<Matiere> toutesLesMatieres = [];

  // Matières du professeur connecté (pour savoir lesquelles il peut modifier)
  List<Matiere> matieresProf = [];

  // Notes de l'étudiant
  List<Note> notes = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  /// Charge toutes les matières, les matières du prof et les notes
  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);
    try {
      final professeurId = _session.professeurConnecte!.id;

      // Charge tout en parallèle
      final results = await Future.wait([
        _apiService.getMatieres(),              // Toutes les matières
        _apiService.getMatieresProf(professeurId), // Matières du prof connecté
        _apiService.getNotesEtudiant(widget.etudiant.id!), // Notes de l'étudiant
      ]);

      setState(() {
        toutesLesMatieres = results[0] as List<Matiere>;
        matieresProf = results[1] as List<Matiere>;
        notes = results[2] as List<Note>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// Vérifie si le professeur connecté peut modifier cette matière
  bool _peutModifier(int matiereId) {
    return matieresProf.any((m) => m.id == matiereId);
  }

  /// Cherche la note d'une matière spécifique
  Note? _getNoteForMatiere(int matiereId) {
    try {
      return notes.firstWhere((n) => n.matiereId == matiereId);
    } catch (e) {
      return null;
    }
  }

  /// Ouvre une boîte de dialogue pour modifier les notes d'une matière
  void _ouvrirDialogNotes(Matiere matiere) {
    final note = _getNoteForMatiere(matiere.id);

    final note1Controller =
        TextEditingController(text: note?.note1?.toString() ?? '');
    final note2Controller =
        TextEditingController(text: note?.note2?.toString() ?? '');
    final note3Controller =
        TextEditingController(text: note?.note3?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Notes - ${matiere.nom}',
          style: const TextStyle(
            color: Color(0xFF6C63FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNoteField(controller: note1Controller, label: 'Note 1'),
            const SizedBox(height: 12),
            _buildNoteField(controller: note2Controller, label: 'Note 2'),
            const SizedBox(height: 12),
            _buildNoteField(controller: note3Controller, label: 'Note 3'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nouvelleNote = Note(
                etudiantId: widget.etudiant.id!,
                matiereId: matiere.id,
                note1: note1Controller.text.isNotEmpty
                    ? double.tryParse(note1Controller.text)
                    : null,
                note2: note2Controller.text.isNotEmpty
                    ? double.tryParse(note2Controller.text)
                    : null,
                note3: note3Controller.text.isNotEmpty
                    ? double.tryParse(note3Controller.text)
                    : null,
              );

              await _apiService.sauvegarderNotes(nouvelleNote);
              Navigator.pop(context);
              _chargerDonnees();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            child: const Text(
              'Sauvegarder',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: '0 - 20',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: Text(
          'Notes de ${widget.etudiant.prenom} ${widget.etudiant.nom}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            )
          : toutesLesMatieres.isEmpty
              ? Center(
                  child: Text(
                    'Aucune matière disponible',
                    style: TextStyle(
                        fontSize: 18, color: Colors.grey.shade400),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: toutesLesMatieres.length,
                  itemBuilder: (context, index) {
                    final matiere = toutesLesMatieres[index];
                    final note = _getNoteForMatiere(matiere.id);
                    final moyenne = note?.moyenne;
                    // Vérifie si ce prof peut modifier cette matière
                    final peutModifier = _peutModifier(matiere.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Icône matière
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                // Couleur différente si le prof peut modifier
                                color: peutModifier
                                    ? const Color(0xFF6C63FF).withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.book,
                                // Icône violette si modifiable, grise sinon
                                color: peutModifier
                                    ? const Color(0xFF6C63FF)
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Nom de la matière
                                      Text(
                                        matiere.nom,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      // Badge "Ma matière" si le prof peut modifier
                                      if (peutModifier)
                                        Container(
                                          margin:
                                              const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6C63FF),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'Ma matière',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Notes existantes
                                  if (note != null)
                                    Text(
                                      'Notes : ${note.note1 ?? '-'} | ${note.note2 ?? '-'} | ${note.note3 ?? '-'}',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 13,
                                      ),
                                    )
                                  else
                                    Text(
                                      'Aucune note',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 13,
                                      ),
                                    ),
                                  // Moyenne colorée
                                  if (moyenne != null)
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: moyenne >= 10
                                            ? const Color(0xFF43E97B)
                                                .withOpacity(0.15)
                                            : const Color(0xFFFF6B6B)
                                                .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Moyenne : ${moyenne.toStringAsFixed(2)}/20',
                                        style: TextStyle(
                                          color: moyenne >= 10
                                              ? const Color(0xFF2ECC71)
                                              : const Color(0xFFE74C3C),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Bouton modifier SEULEMENT si c'est la matière du prof
                            if (peutModifier)
                              GestureDetector(
                                onTap: () => _ouvrirDialogNotes(matiere),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Color(0xFFFF9800),
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}