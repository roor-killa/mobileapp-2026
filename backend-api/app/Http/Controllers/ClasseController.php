<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Classe;
use App\Models\Note;

class ClasseController extends Controller
{
    // ==========================================================
    // LISTE DES CLASSES
    // Route : GET /api/classes
    // ==========================================================

    public function index()
    {
        $classes = Classe::withCount('etudiants')->get();
        return response()->json($classes, 200);
    }

    // ==========================================================
    // ÉTUDIANTS D'UNE CLASSE
    // Route : GET /api/classes/{id}/etudiants
    // ==========================================================

    public function etudiants($id)
    {
        $classe = Classe::with('etudiants')->findOrFail($id);
        return response()->json($classe->etudiants, 200);
    }

    // ==========================================================
    // MOYENNE DE LA CLASSE PAR MATIÈRE
    // Route : GET /api/classes/{id}/moyennes
    // ==========================================================

    public function moyennes($id)
    {
        $classe = Classe::with('etudiants')->findOrFail($id);
        $etudiantIds = $classe->etudiants->pluck('id');

        // Récupère toutes les notes des étudiants de la classe
        $notes = Note::whereIn('etudiant_id', $etudiantIds)
                     ->with('matiere')
                     ->get();

        // Groupe les notes par matière
        $moyennesParMatiere = $notes->groupBy('matiere_id')->map(function ($notesMatiere) {
            $moyennes = $notesMatiere->map(function ($note) {
                $vals = array_filter([
                    $note->note1,
                    $note->note2,
                    $note->note3
                ], fn($v) => $v !== null);
                return count($vals) > 0 ? array_sum($vals) / count($vals) : null;
            })->filter()->values();

            return [
                'matiere'          => $notesMatiere->first()->matiere->nom,
                'moyenne_classe'   => $moyennes->count() > 0
                    ? round($moyennes->avg(), 2)
                    : null,
                'nombre_etudiants' => $moyennes->count(),
            ];
        })->values();

        return response()->json([
            'classe'   => $classe->nom,
            'moyennes' => $moyennesParMatiere,
        ], 200);
    }
}