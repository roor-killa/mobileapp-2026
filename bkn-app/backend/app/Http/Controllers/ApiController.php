<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class ApiController extends Controller
{
    // LOGIN
    public function login(Request $request) {
        $user = User::where('email', $request->email)->first();
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Identifiants invalides'], 401);
        }
        $token = $user->createToken('mobile_app')->plainTextToken;
        return response()->json(['token' => $token, 'user' => $user]);
    }

    // TEST (A SUPPRIMER PLUS TARD) : Voir un user par son ID
    public function showUser($id) {
        return response()->json(User::find($id));
    }


    // PROFIL & SOLDE
    public function me() {
        return response()->json(Auth::user());
    }

    // LISTE DES DESTINATAIRES (Sauf soi-même)
    public function users() {
        return response()->json(User::where('id', '!=', Auth::id())->get());
    }

    // TRANSFERT D'ARGENT
    public function transfer(Request $request) {
        $request->validate([
            'receiver_id' => 'required|exists:users,id',
            'amount' => 'required|integer|min:1'
        ]);

        $sender = Auth::user();
        if ($sender->balance < $request->amount) {
            return response()->json(['message' => 'Solde insuffisant'], 400);
        }

        // Transaction Atomique (Tout ou rien)
        DB::transaction(function () use ($sender, $request) {
            // 1. Débit
            $sender->decrement('balance', $request->amount);
            
            // 2. Crédit
            User::find($request->receiver_id)->increment('balance', $request->amount);

            // 3. Historique
            Transaction::create([
                'sender_id' => $sender->id,
                'receiver_id' => $request->receiver_id,
                'amount' => $request->amount
            ]);
        });

        return response()->json(['message' => 'Transfert réussi']);
    }

    // HISTORIQUE
    public function transactions() {
        $userId = Auth::id();
        // On récupère les transactions envoyées ET reçues
        $transactions = Transaction::where('sender_id', $userId)
            ->orWhere('receiver_id', $userId)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function($t) use ($userId) {
                // On ajoute un petit flag pour savoir si c'est entrant ou sortant
                $t->type = ($t->sender_id == $userId) ? 'sent' : 'received';
                return $t;
            });

        return response()->json($transactions);
    }

        // INSCRIPTION
    public function register(Request $request) {
        $request->validate([
            'name' => 'required|string',
            'username' => 'required|string|unique:users,username',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6'
        ]);

        $user = User::create([
            'name' => $request->name,
            'username' => $request->username,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'balance' => 50, // Cadeau de bienvenue : 50 BKN !
        ]);

        // On connecte l'utilisateur directement après l'inscription
        $token = $user->createToken('mobile_app')->plainTextToken;

        return response()->json([
            'message' => 'Compte créé avec succès',
            'token' => $token,
            'user' => $user
        ], 201);
    }
        // RECHARGEMENT (Dépôt)
    public function deposit(Request $request) {
        $request->validate([
            'amount' => 'required|integer|min:1'
        ]);

        $user = Auth::user();
        
        // On crédite le compte
        $user->increment('balance', $request->amount);

        // On crée une transaction "système" (sender_id = null ou user lui-même)
        // Pour simplifier, on dit que l'émetteur et le récepteur sont les mêmes
        Transaction::create([
            'sender_id' => $user->id,
            'receiver_id' => $user->id,
            'amount' => $request->amount
        ]);

        return response()->json(['message' => 'Compte rechargé avec succès', 'new_balance' => $user->balance]);
    }


}

