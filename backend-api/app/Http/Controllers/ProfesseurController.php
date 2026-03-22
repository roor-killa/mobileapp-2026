<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Professeur;
use Illuminate\Support\Facades\Hash;

class ProfesseurController extends Controller
{
    // Route : POST /api/login
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        $professeur = Professeur::where('email', $request->email)->first();

        if (!$professeur || !Hash::check($request->password, $professeur->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email ou mot de passe incorrect',
            ], 401);
        }

        return response()->json([
            'success'    => true,
            'message'    => 'Connexion réussie',
            'professeur' => $professeur,
        ], 200);
    }

    // Route : POST /api/register
    public function register(Request $request)
    {
        $request->validate([
            'nom'      => 'required|string',
            'prenom'   => 'required|string',
            'email'    => 'required|email|unique:professeurs',
            'password' => 'required|string|min:6',
        ]);

        $professeur = Professeur::create([
            'nom'      => $request->nom,
            'prenom'   => $request->prenom,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
        ]);

        return response()->json([
            'success'    => true,
            'message'    => 'Compte créé avec succès',
            'professeur' => $professeur,
        ], 201);
    }

    // ==========================================================
    // MOT DE PASSE OUBLIÉ
    // Route : POST /api/professeur/reset-password
    // Reçoit : email
    // Retourne : nouveau mot de passe temporaire
    // ==========================================================
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        // Cherche le professeur par son email
        $professeur = Professeur::where('email', $request->email)->first();

        // Si l'email n'existe pas
        if (!$professeur) {
            return response()->json([
                'success' => false,
                'message' => 'Aucun compte trouvé avec cet email',
            ], 404);
        }

        // Génère un mot de passe temporaire : 3 lettres + 4 chiffres
        // Exemple : abc1234
        $nouveauMotDePasse = substr(str_shuffle('abcdefghijklmnopqrstuvwxyz'), 0, 3)
                           . rand(1000, 9999);

        // Met à jour le mot de passe en base
        $professeur->update([
            'password' => Hash::make($nouveauMotDePasse),
        ]);

        return response()->json([
            'success'          => true,
            'message'          => 'Mot de passe réinitialisé avec succès',
            'nouveau_password' => $nouveauMotDePasse,
        ], 200);
    }
}