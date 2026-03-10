<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Etudiant;
use Illuminate\Support\Facades\Hash;

class EtudiantController extends Controller
{
    // ==========================================================
    // LOGIN ÉTUDIANT
    // Route : POST /api/etudiant/login
    // ==========================================================

    public function login(Request $request)
    {
        $email    = $request->input('email');
        $password = $request->input('password');

        // Cherche l'étudiant par son email
        $etudiant = Etudiant::where('email', $email)->first();

        // Si l'étudiant n'existe pas ou le password est incorrect
        if (!$etudiant || !Hash::check($password, $etudiant->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email ou mot de passe incorrect',
            ], 401);
        }

        // Connexion réussie
        return response()->json([
            'success'  => true,
            'etudiant' => [
                'id'     => $etudiant->id,
                'nom'    => $etudiant->nom,
                'prenom' => $etudiant->prenom,
                'email'  => $etudiant->email,
            ],
        ], 200);
    }

    // ==========================================================
    // LISTE DES ÉTUDIANTS
    // Route : GET /api/etudiants
    // ==========================================================

    public function index()
    {
        // Retourne tous les étudiants sans le password
        $etudiants = Etudiant::select('id', 'nom', 'prenom', 'email')->get();
        return response()->json($etudiants, 200);
    }

    // ==========================================================
    // AJOUTER UN ÉTUDIANT
    // Route : POST /api/etudiants
    // ==========================================================

    public function store(Request $request)
    {
        // Vérifie que les champs obligatoires sont présents
        if (!$request->input('nom') || !$request->input('prenom') || !$request->input('email')) {
            return response()->json([
                'message' => 'Champs manquants'
            ], 422);
        }

        $etudiant = Etudiant::create([
            'nom'      => $request->input('nom'),
            'prenom'   => $request->input('prenom'),
            'email'    => $request->input('email'),
            // Mot de passe par défaut : prénom en minuscule + 123
            // Exemple : Jean → jean123
            'password' => Hash::make(strtolower($request->input('prenom')) . '123'),
        ]);

        // On retourne seulement les champs nécessaires, sans le password
        return response()->json([
            'id'     => $etudiant->id,
            'nom'    => $etudiant->nom,
            'prenom' => $etudiant->prenom,
            'email'  => $etudiant->email,
        ], 201);
    }

    // ==========================================================
    // MODIFIER UN ÉTUDIANT
    // Route : PUT /api/etudiants/{id}
    // ==========================================================

    public function update(Request $request, $id)
    {
        $etudiant = Etudiant::findOrFail($id);
        $etudiant->update([
            'nom'    => $request->input('nom'),
            'prenom' => $request->input('prenom'),
            'email'  => $request->input('email'),
        ]);

        // On retourne seulement les champs nécessaires, sans le password
        return response()->json([
            'id'     => $etudiant->id,
            'nom'    => $etudiant->nom,
            'prenom' => $etudiant->prenom,
            'email'  => $etudiant->email,
        ], 200);
    }

    // ==========================================================
    // SUPPRIMER UN ÉTUDIANT
    // Route : DELETE /api/etudiants/{id}
    // ==========================================================

    public function destroy($id)
    {
        $etudiant = Etudiant::findOrFail($id);
        $etudiant->delete();

        return response()->json(['message' => 'Étudiant supprimé'], 200);
    }
}