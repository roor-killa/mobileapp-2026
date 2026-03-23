<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Transfer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use App\Mail\LoginNotification;
use Illuminate\Support\Facades\Mail;

class AuthController extends Controller
{
    /**
     * Connexion de l'utilisateur et génération du Token
     */
    /**
     * Connexion de l'utilisateur et génération du Token
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Identifiants incorrects'], 401);
        }

        // --- AJOUT DE L'ENVOI DE MAIL ---
        try {
            // On envoie le mail à ton adresse de test Resend
            // Mais on passe le nom de l'utilisateur ($user->name) à la classe LoginNotification
            Mail::to('mathis.eloidin@gmail.com')->send(new LoginNotification($user->name));
        } catch (\Exception $e) {
            // On ne bloque pas la connexion si le mail échoue, 
            // on pourrait loguer l'erreur ici : \Log::error($e->getMessage());
        }
        // --------------------------------

        // Suppression des anciens tokens pour n'avoir qu'une session active
        $user->tokens()->delete();

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'balance' => $user->balance,
            ]
        ]);
    }

    /**
     * Inscription d'un nouvel utilisateur
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'pin' => 'required|string|max:4', // Obligatoire pour la sécurité
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'transaction_pin' => Hash::make($request->pin), // Hachage du PIN
            'balance' => 100.00, // Bonus de bienvenue
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user
        ], 201);
    }

    /**
     * Exécution d'un transfert d'argent sécurisé par PIN
     */
    public function sendMoney(Request $request)
    {
        $request->validate([
            'receiver_email' => 'required|email|exists:users,email',
            'amount' => 'required|numeric|min:1',
            'pin' => 'required|string', 
        ]);

        $sender = $request->user();

        // 1. Vérification du PIN
        if (!$sender->transaction_pin || !Hash::check($request->pin, $sender->transaction_pin)) {
            return response()->json([
                'success' => false,
                'message' => 'Code PIN incorrect.'
            ], 403);
        }

        // 2. Vérification du solde
        if ($sender->balance < $request->amount) {
            return response()->json([
                'success' => false,
                'message' => 'Solde insuffisant.'
            ], 400);
        }

        // 3. Transaction atomique (Tout ou rien)
        return DB::transaction(function () use ($sender, $request) {
            $receiver = User::where('email', $request->receiver_email)->first();

            // Empêcher l'envoi à soi-même
            if ($sender->id === $receiver->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vous ne pouvez pas vous envoyer d\'argent à vous-même.'
                ], 400);
            }

            // Mise à jour des soldes
            $sender->decrement('balance', $request->amount);
            $receiver->increment('balance', $request->amount);

            // Création de l'enregistrement
            $transfer = Transfer::create([
                'sender_id' => $sender->id,
                'receiver_id' => $receiver->id,
                'amount' => $request->amount,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Transfert vers ' . $receiver->name . ' réussi !',
                'nouveauSolde' => $sender->balance,
                'montantTotal' => $sender->balance + $request->amount,
                'montantTransfere' => $request->amount
            ]);
        });
    }

    /**
     * Récupérer les informations de l'utilisateur connecté
     */
    public function getUserInfo(Request $request)
    {
        return response()->json($request->user());
    }

    /**
     * Historique des transactions (Envoyées et Reçues)
     */
    public function getTransactions(Request $request)
    {
        $user = $request->user();

        $transactions = Transfer::where('sender_id', $user->id)
            ->orWhere('receiver_id', $user->id)
            ->with(['sender:id,name', 'receiver:id,name']) // On ne prend que l'ID et le Nom
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($transactions);
    }
}