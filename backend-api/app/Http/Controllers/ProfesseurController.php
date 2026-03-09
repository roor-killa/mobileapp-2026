<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Professeur;
use Illuminate\Support\Facades\Hash;

class ProfesseurController extends Controller
{
    /**
     * Connexion d'un professeur
     * Route : POST /api/login
     * Reçoit : email + password
     * Retourne : les infos du professeur ou une erreur
     */
    public function login(Request $request)
    {
        // Validation des champs obligatoires
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        // On cherche le professeur par son email
        $professeur = Professeur::where('email', $request->email)->first();

        // Si introuvable ou mot de passe incorrect
        if (!$professeur || !Hash::check($request->password, $professeur->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Email ou mot de passe incorrect',
            ], 401);
        }

        // Connexion réussie
        return response()->json([
            'success'    => true,
            'message'    => 'Connexion réussie',
            'professeur' => $professeur,
        ], 200);
    }

    /**
     * Inscription d'un nouveau professeur
     * Route : POST /api/register
     * Reçoit : nom, prenom, email, password
     * Retourne : les infos du professeur créé
     */
    public function register(Request $request)
    {
        // Validation des champs obligatoires
        $request->validate([
            'nom'      => 'required|string',
            'prenom'   => 'required|string',
            'email'    => 'required|email|unique:professeurs', // Email unique
            'password' => 'required|string|min:6',            // Minimum 6 caractères
        ]);

        // Création du professeur avec le mot de passe hashé
        // Hash::make() transforme le mot de passe en version sécurisée
        $professeur = Professeur::create([
            'nom'      => $request->nom,
            'prenom'   => $request->prenom,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
        ]);

        // Retourne le professeur créé avec le code 201 (créé)
        return response()->json([
            'success'    => true,
            'message'    => 'Compte créé avec succès',
            'professeur' => $professeur,
        ], 201);
    }
}