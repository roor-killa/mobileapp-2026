<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Admin;
use App\Models\Professeur;
use Illuminate\Support\Facades\Hash;

class AdminController extends Controller
{
    /**
     * Connexion de l'admin
     * Route : POST /api/admin/login
     */
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        // Cherche l'admin par email
        $admin = Admin::where('email', $request->email)->first();

        // Vérifie le mot de passe
        if (!$admin || !Hash::check($request->password, $admin->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email ou mot de passe incorrect',
            ], 401);
        }

        return response()->json([
            'success' => true,
            'admin'   => $admin,
        ], 200);
    }

    /**
     * Crée un nouveau professeur (réservé à l'admin)
     * Route : POST /api/admin/professeurs
     */
    public function creerProfesseur(Request $request)
    {
        $request->validate([
            'nom'        => 'required|string',
            'prenom'     => 'required|string',
            'email'      => 'required|email|unique:professeurs,email',
            'password'   => 'required|min:6',
            'matieres'   => 'nullable|array|max:2',
            'matieres.*' => 'exists:matieres,id',
        ]);

        // Crée le professeur
        $professeur = Professeur::create([
            'nom'      => $request->nom,
            'prenom'   => $request->prenom,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
        ]);

        // Assigne les matières si fournies
        if ($request->matieres) {
            $professeur->matieres()->sync($request->matieres);
        }

        return response()->json([
            'success'    => true,
            'message'    => 'Professeur créé avec succès',
            'professeur' => $professeur->load('matieres'),
        ], 201);
    }

    /**
     * Retourne la liste de tous les professeurs
     * Route : GET /api/admin/professeurs
     */
    public function listeProfesseurs()
    {
        // Inclut les matières de chaque professeur
        $professeurs = Professeur::with('matieres')->get();

        return response()->json($professeurs, 200);
    }

    /**
     * Modifie les matières d'un professeur
     * Route : PUT /api/admin/professeurs/{id}/matieres
     */
    public function modifierMatieres(Request $request, $id)
    {
        $request->validate([
            'matieres'   => 'required|array|max:2',
            'matieres.*' => 'exists:matieres,id',
        ]);

        $professeur = Professeur::findOrFail($id);
        $professeur->matieres()->sync($request->matieres);

        return response()->json([
            'success'    => true,
            'message'    => 'Matières mises à jour',
            'professeur' => $professeur->load('matieres'),
        ], 200);
    }

    /**
     * Supprime un professeur
     * Route : DELETE /api/admin/professeurs/{id}
     */
    public function supprimerProfesseur($id)
    {
        $professeur = Professeur::findOrFail($id);
        $professeur->matieres()->detach(); // Supprime les matières liées
        $professeur->delete();

        return response()->json([
            'success' => true,
            'message' => 'Professeur supprimé',
        ], 200);
    }
}