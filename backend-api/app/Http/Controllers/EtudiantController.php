<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Etudiant;

class EtudiantController extends Controller
{
    /**
     * Retourne la liste de tous les étudiants
     * Route : GET /api/etudiants
     */
    public function index()
    {
        // Récupère tous les étudiants triés par nom
        $etudiants = Etudiant::orderBy('nom')->get();

        return response()->json($etudiants, 200);
    }

    /**
     * Ajoute un nouvel étudiant
     * Route : POST /api/etudiants
     * Reçoit : nom, prenom, email, note
     */
    public function store(Request $request)
    {
        // Validation des champs obligatoires
        $request->validate([
            'nom'    => 'required|string',
            'prenom' => 'required|string',
            'email'  => 'required|email|unique:etudiants', // Email unique dans la table
            'note'   => 'required|numeric|min:0|max:20',   // Note entre 0 et 20
        ]);

        // Crée l'étudiant dans la base de données
        $etudiant = Etudiant::create($request->all());

        // Retourne l'étudiant créé avec le code 201 (créé)
        return response()->json($etudiant, 201);
    }

    /**
     * Modifie un étudiant existant
     * Route : PUT /api/etudiants/{id}
     * Reçoit : nom, prenom, email, note
     */
    public function update(Request $request, $id)
    {
        // Cherche l'étudiant par son id, retourne 404 si introuvable
        $etudiant = Etudiant::findOrFail($id);

        // Validation des champs
        $request->validate([
            'nom'    => 'required|string',
            'prenom' => 'required|string',
            'email'  => 'required|email',
            'note'   => 'required|numeric|min:0|max:20',
        ]);

        // Met à jour l'étudiant avec les nouvelles valeurs
        $etudiant->update($request->all());

        return response()->json($etudiant, 200);
    }

    /**
     * Supprime un étudiant
     * Route : DELETE /api/etudiants/{id}
     */
    public function destroy($id)
    {
        // Cherche l'étudiant par son id, retourne 404 si introuvable
        $etudiant = Etudiant::findOrFail($id);

        // Supprime l'étudiant de la base de données
        $etudiant->delete();

        return response()->json(['message' => 'Étudiant supprimé'], 200);
    }
}