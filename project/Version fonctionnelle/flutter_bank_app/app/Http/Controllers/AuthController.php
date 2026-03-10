<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Transaction; // <-- Notre nouvelle table est bien là !
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $user = User::create([
            'name' => $request->name,
            'prenom' => $request->prenom,
            'email' => $request->email,
            'telephone' => $request->telephone,
            'password' => Hash::make($request->password),
            'solde' => 0.00,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Compte créé avec succès !',
            'token' => $token,
            'user' => $user
        ], 201);
    }

    public function login(Request $request)
    {
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json(['message' => 'Identifiants invalides'], 401);
        }

        $user = User::where('email', $request->email)->firstOrFail();
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Bienvenue, ' . $user->prenom,
            'token' => $token,
            'user' => $user
        ]);
    }

    public function topup(Request $request)
    {
        // 1. On vérifie et on récupère les variables (les lignes manquantes !)
        $request->validate(['montant' => 'required|numeric|min:5.00']);
        $user = $request->user();
        $montant = $request->montant;
        
        // 2. On ajoute l'argent
        $user->solde += $montant;
        $user->save();

        // 3. On crée le reçu de rechargement
        Transaction::create([
            'user_id' => $user->id,
            'type' => 'rechargement',
            'montant' => $montant,
            'description' => 'Rechargement par carte bancaire',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Compte rechargé avec succès de ' . $montant . ' €',
            'nouveau_solde' => (float) $user->solde,
        ]);
    }

    public function transfer(Request $request)
    {
        $request->validate([
            'montant' => 'required|numeric|min:0.01',
            'email_destinataire' => 'required|email|exists:users,email',
        ]);

        $expediteur = $request->user();
        $montant = $request->montant;
        $emailDestinataire = $request->email_destinataire;

        if ($expediteur->email === $emailDestinataire) {
            return response()->json([
                'success' => false, 'message' => "Vous ne pouvez pas vous envoyer d'argent à vous-même.",
                'montant_total' => (float) $expediteur->solde, 'montant_transfere' => 0, 'nouveau_solde' => (float) $expediteur->solde,
            ]);
        }

        if ($expediteur->solde < $montant) {
            return response()->json([
                'success' => false, 'message' => 'Solde insuffisant',
                'montant_total' => (float) $expediteur->solde, 'montant_transfere' => 0, 'nouveau_solde' => (float) $expediteur->solde,
            ]);
        }

        $ancienSolde = $expediteur->solde;
        $destinataire = User::where('email', $emailDestinataire)->first();

        // 1. Les vases communicants
        $expediteur->solde -= $montant;
        $expediteur->save();

        $destinataire->solde += $montant;
        $destinataire->save();

        // 2. On crée le reçu pour l'expéditeur (toi)
        Transaction::create([
            'user_id' => $expediteur->id,
            'type' => 'envoi',
            'montant' => $montant,
            'description' => 'Envoyé à ' . $destinataire->prenom . ' (' . $destinataire->email . ')',
        ]);

        // 3. On crée le reçu pour le destinataire (ton ami)
        Transaction::create([
            'user_id' => $destinataire->id,
            'type' => 'reception',
            'montant' => $montant,
            'description' => 'Reçu de ' . $expediteur->prenom . ' (' . $expediteur->email . ')',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Transfert de ' . $montant . ' € envoyé à ' . $destinataire->prenom,
            'montant_total' => (float) $ancienSolde,
            'montant_transfere' => (float) $montant,
            'nouveau_solde' => (float) $expediteur->solde,
        ]);
    }

    // --- LA NOUVELLE FONCTION POUR VOIR L'HISTORIQUE ---
    public function transactions(Request $request)
    {
        $user = $request->user();
        
        // On récupère toutes les transactions, triées de la plus récente à la plus ancienne
        $transactions = Transaction::where('user_id', $user->id)
                                   ->orderBy('created_at', 'desc')
                                   ->get();

        return response()->json([
            'success' => true,
            'transactions' => $transactions,
        ]);
    }
}