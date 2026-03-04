<?php
namespace App\Http\Controllers;

use App\Models\Etudiant;
use Illuminate\Http\Request;

class EtudiantController extends Controller {

    // Retourne la liste de tous les étudiants
    // Appelé par Flutter : GET /api/etudiants
    public function index() {
        return response()->json(Etudiant::all());
    }

    // Crée un nouvel étudiant dans la base de données
    // Appelé par Flutter : POST /api/etudiants
    public function store(Request $request) {
        $etudiant = Etudiant::create($request->all());
        return response()->json($etudiant, 201);
    }

    // Modifie un étudiant existant par son id
    // Appelé par Flutter : PUT /api/etudiants/{id}
    public function update(Request $request, $id) {
        $etudiant = Etudiant::findOrFail($id);
        $etudiant->update($request->all());
        return response()->json($etudiant);
    }

    // Supprime un étudiant par son id
    // Appelé par Flutter : DELETE /api/etudiants/{id}
    public function destroy($id) {
        Etudiant::findOrFail($id)->delete();
        return response()->json(['message' => 'Étudiant supprimé']);
    }
}