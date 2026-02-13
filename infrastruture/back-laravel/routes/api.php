<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

// ==========================================
// 1. ROUTES PUBLIQUES (Tout le monde peut y accéder)
// ==========================================

// Inscription
Route::post('/register', function (Request $request) {
    $request->validate([
        'username' => 'required|string|min:4|max:20|unique:users,username|alpha_dash', // ID Perso
        'name'     => 'required|string',
        'email'    => 'required|email|unique:users,email',
        'password' => 'required|string|min:6',
    ]);

    $user = User::create([
        'username' => $request->username,
        'name'     => $request->name,
        'email'    => $request->email,
        'password' => Hash::make($request->password),
        'balance'  => 100, // Bonus de bienvenue 🎁
    ]);

    return response()->json([
        'message' => 'Compte créé !',
        'token' => $user->createToken('auth_token')->plainTextToken
    ]);
});

// Connexion
Route::post('/login', function (Request $request) {
    $request->validate([
        'email'    => 'required|email',
        'password' => 'required',
    ]);

    $user = User::where('email', $request->email)->first();

    if (! $user || ! Hash::check($request->password, $user->password)) {
        throw ValidationException::withMessages(['email' => ['Mauvais identifiants']]);
    }

    return response()->json([
        'message' => 'Connecté !',
        'token' => $user->createToken('auth_token')->plainTextToken
    ]);
});


// ==========================================
// 2. ROUTES PROTÉGÉES (Il faut être connecté)
// ==========================================

Route::middleware('auth:sanctum')->group(function () {

    // Mon Profil (Qui suis-je ?)
    Route::get('/me', function (Request $request) {
        return $request->user();
    });

    // Liste des autres utilisateurs (Pour leur envoyer de l'argent)
    Route::get('/users', function (Request $request) {
        // On renvoie tout le monde sauf moi-même
        return User::where('id', '!=', $request->user()->id)->get(['id', 'username', 'name']);
    });

    // Faire un virement
    Route::post('/transfer', function (Request $request) {
        $request->validate([
            'receiver_username' => 'required|exists:users,username',
            'amount'            => 'required|integer|min:1'
        ]);

        $sender = $request->user();
        $receiver = User::where('username', $request->receiver_username)->first();
        $amount = $request->amount;

        // Vérifications de sécurité
        if ($sender->balance < $amount) {
            return response()->json(['message' => 'Fonds insuffisants'], 400);
        }
        
        if ($sender->id === $receiver->id) {
             return response()->json(['message' => 'Pas de virement à soi-même'], 400);
        }

        // Transaction atomique (Tout réussit ou tout échoue)
        DB::transaction(function () use ($sender, $receiver, $amount) {
            // 1. On débite l'expéditeur
            $sender->decrement('balance', $amount);
            
            // 2. On crédite le destinataire
            $receiver->increment('balance', $amount);
            
            // 3. On enregistre la trace dans l'historique
            DB::table('transactions')->insert([
                'sender_id' => $sender->id,
                'receiver_id' => $receiver->id,
                'amount' => $amount,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        });

        return response()->json(['message' => 'Virement envoyé !', 'new_balance' => $sender->balance]);
    });

    // Historique des Transactions (Reçu & Envoyé)
    Route::get('/transactions', function (Request $request) {
        $userId = $request->user()->id;
        
        $transactions = DB::table('transactions')
            ->join('users as sender', 'transactions.sender_id', '=', 'sender.id')
            ->join('users as receiver', 'transactions.receiver_id', '=', 'receiver.id')
            ->where('sender_id', $userId) // Soit j'ai envoyé
            ->orWhere('receiver_id', $userId) // Soit j'ai reçu
            ->select(
                'transactions.id',
                'transactions.amount',
                'transactions.created_at',
                'sender.username as sender_name',     // Nom de l'expéditeur
                'receiver.username as receiver_name'  // Nom du destinataire
            )
            ->orderBy('transactions.created_at', 'desc') // Du plus récent au plus vieux
            ->get();

        return response()->json($transactions);
    });
    
    // Déconnexion
    Route::post('/logout', function (Request $request) {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Déconnecté']);
    });
});

// Route de DEBUG pour voir tout le monde (Attention : à supprimer en production !)
Route::get('/users', function () {
    return User::all();
});

