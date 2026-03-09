<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Matiere;
use App\Models\Professeur;

class MatiereController extends Controller
{
    /**
     * Retourne la liste de toutes les matières
     * Route : GET /api/matieres
     */
    public function index()
    {
        // Récupère toutes les matières triées par nom
        $matieres = Matiere::orderBy('nom')->get();
        return response()->json($matieres, 200);
    }

    /**
     * Assigne des matières à un professeur (max 2)
     * Route : POST /api/professeurs/{id}/matieres
     * Reçoit : tableau d'ids de matières
     */
    public function assignerMatieres(Request $request, $professeurId)
    {
        // Validation : tableau de max 2 matières
        $request->validate([
            'matieres'   => 'required|array|max:2',
            'matieres.*' => 'exists:matieres,id', // Chaque matière doit exister
        ]);

        // Cherche le professeur
        $professeur = Professeur::findOrFail($professeurId);

        // sync() remplace les anciennes matières par les nouvelles
        $professeur->matieres()->sync($request->matieres);

        return response()->json([
            'success' => true,
            'message' => 'Matières assignées avec succès',
            'matieres' => $professeur->matieres,
        ], 200);
    }

    /**
     * Retourne les matières d'un professeur
     * Route : GET /api/professeurs/{id}/matieres
     */
    public function matieresProf($professeurId)
    {
        $professeur = Professeur::findOrFail($professeurId);
        return response()->json($professeur->matieres, 200);
    }
}