<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    // --- INSCRIPTION (Pour ton écran "Inscription" sur le storyboard) ---
    public function register(Request $request)
    {
        // 1. On crée l'utilisateur dans PostgreSQL
        $user = User::create([
            'name' => $request->name,
            'prenom' => $request->prenom,
            'email' => $request->email,
            'telephone' => $request->telephone,
            'password' => Hash::make($request->password), // On crypte le mot de passe
            'solde' => 0.00, // On initialise le wallet à 0 BKN
        ]);

        // 2. On crée un "Token" (le badge d'accès) pour que l'app soit déjà connectée
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Compte créé avec succès !',
            'access_token' => $token,
            'user' => $user
        ], 201);
    }

    // --- CONNEXION (Pour ton écran "Login" sur le storyboard) ---
    public function login(Request $request)
    {
        // 1. On vérifie si l'email et le mot de passe correspondent
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'message' => 'Identifiants invalides'
            ], 401);
        }

        // 2. Si c'est bon, on récupère l'utilisateur
        $user = User::where('email', $request->email)->firstOrFail();

        // 3. On lui donne un nouveau badge d'accès (Token)
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Bienvenue, ' . $user->prenom,
            'access_token' => $token,
            'user' => $user
        ]);
    }
}