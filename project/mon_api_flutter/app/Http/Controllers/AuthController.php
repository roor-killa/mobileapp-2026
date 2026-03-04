<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Transfer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Identifiants incorrects'], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user,
            'balance' => $user->balance // On renvoie le solde actuel
        ]);
    }
    
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'balance' => 100.00, // On offre 100€ à l'inscription pour tester !
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user
        ], 201);
    }

    public function sendMoney(Request $request) 
    {
        $request->validate([
            'receiver_email' => 'required|email|exists:users,email',
            'amount' => 'required|numeric|min:0.01',
        ]);

        $sender = $request->user(); 
        $receiver = User::where('email', $request->receiver_email)->first();

        if ($sender->id === $receiver->id) {
            return response()->json(['message' => 'Envoi à soi-même impossible'], 400);
        }

        // Vérification du solde avant de commencer
        if ($sender->balance < $request->amount) {
            return response()->json(['message' => 'Solde insuffisant'], 400);
        }

        return DB::transaction(function () use ($sender, $receiver, $request) {
            $amount = $request->amount;
            $oldBalance = $sender->balance;

            // 1. Débiter l'expéditeur
            $sender->decrement('balance', $amount);

            // 2. Créditer le destinataire
            $receiver->increment('balance', $amount);

            // 3. Créer l'historique
            Transfer::create([
                'sender_id' => $sender->id,
                'receiver_id' => $receiver->id,
                'amount' => $amount,
            ]);

            // 4. Réponse structurée pour Flutter
            return response()->json([
                'success' => true,
                'message' => 'Transfert effectué avec succès',
                'montantTotal' => (double)$oldBalance,
                'montantTransfere' => (double)$amount,
                'nouveauSolde' => (double)$sender->balance
            ], 200);
        });
    }

    // Optionnel : Ajouter une méthode pour récupérer le solde seul
    public function getBalance(Request $request) {
        return response()->json($request->user()->balance);
    }

    public function getTransactions(Request $request)
    {
        $user = $request->user();

        // Récupère les transferts où l'utilisateur est soit l'envoyeur, soit le receveur
        $transactions = Transfer::where('sender_id', $user->id)
            ->orWhere('receiver_id', $user->id)
            ->with(['sender', 'receiver']) // Charge les infos des utilisateurs liés
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($transactions);
    }
}