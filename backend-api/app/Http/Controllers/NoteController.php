<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Note;
use App\Models\Etudiant;

class NoteController extends Controller
{
    /**
     * Retourne toutes les notes d'un étudiant
     * Route : GET /api/etudiants/{id}/notes
     */
    public function getNotesEtudiant($etudiantId)
    {
        // Récupère toutes les notes de l'étudiant avec le nom de la matière
        $notes = Note::where('etudiant_id', $etudiantId)
                     ->with('matiere') // Inclut les infos de la matière
                     ->get();

        return response()->json($notes, 200);
    }

    /**
     * Ajoute ou met à jour les notes d'un étudiant pour une matière
     * Route : POST /api/notes
     * Reçoit : etudiant_id, matiere_id, note1, note2, note3
     */
    public function store(Request $request)
    {
        // Validation des champs
        $request->validate([
            'etudiant_id' => 'required|exists:etudiants,id',
            'matiere_id'  => 'required|exists:matieres,id',
            'note1'       => 'nullable|numeric|min:0|max:20',
            'note2'       => 'nullable|numeric|min:0|max:20',
            'note3'       => 'nullable|numeric|min:0|max:20',
        ]);

        // updateOrCreate : met à jour si existe, sinon crée
        // Cherche par etudiant_id + matiere_id
        $note = Note::updateOrCreate(
            [
                'etudiant_id' => $request->etudiant_id,
                'matiere_id'  => $request->matiere_id,
            ],
            [
                'note1' => $request->note1,
                'note2' => $request->note2,
                'note3' => $request->note3,
            ]
        );

        return response()->json($note, 200);
    }

    /**
     * Retourne les notes de tous les étudiants pour une matière
     * Route : GET /api/matieres/{id}/notes
     */
    public function getNotesByMatiere($matiereId)
    {
        $notes = Note::where('matiere_id', $matiereId)
                     ->with('etudiant') // Inclut les infos de l'étudiant
                     ->get();

        return response()->json($notes, 200);
    }
}
