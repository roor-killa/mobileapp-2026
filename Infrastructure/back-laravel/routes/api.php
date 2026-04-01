<?php

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ProductController;

Route::get('/products', [ProductController::class, 'index']);


// =======================
// REGISTER
// =======================
Route::post('/register', function (Request $request) {
    $request->validate([
        'name' => 'required',
        'email' => 'required|email|unique:users',
        'password' => 'required|min:4',
    ]);

    $user = User::create([
        'name' => $request->name,
        'email' => $request->email,
        'password' => Hash::make($request->password),
        'is_admin' => false,
        'balance' => 0,
    ]);

    return response()->json([
        'message' => 'Utilisateur créé',
        'user' => $user
    ]);
});


// =======================
// LOGIN
// =======================
Route::post('/login', function (Request $request) {
    $user = User::where('email', $request->email)->first();

    if (!$user || !Hash::check($request->password, $user->password)) {
        return response()->json(['message' => 'Identifiants invalides'], 401);
    }

    $token = base64_encode($user->email . '|' . now());

    return response()->json([
        'token' => $token,
        'user' => $user
    ]);
});


// =======================
// GET USER BALANCE
// =======================
Route::get('/user/{id}', function ($id) {
    $user = \App\Models\User::find($id);

    if (!$user) {
        return response()->json(['message' => 'Utilisateur introuvable'], 404);
    }

    return response()->json([
        'id' => $user->id,
        'name' => $user->name,
        'email' => $user->email,
        'balance' => $user->balance,
    ]);
});


// =======================
// USERS (ADMIN)
// =======================
Route::get('/users', function (Request $request) {

    if (!filter_var($request->is_admin, FILTER_VALIDATE_BOOLEAN)) {
        return response()->json(['message' => 'Non autorisé'], 403);
    }

    return User::select('id', 'name', 'email', 'balance')->get();
});


// =======================
// TRANSFER (RÉEL)
// =======================
Route::post('/transfer', function (Request $request) {

    $request->validate([
        'sender_id' => 'required|exists:users,id',
        'destinataire_email' => 'required|email',
        'montant' => 'required|numeric|min:0.01',
    ]);

    $montant = (float) $request->montant;

    $sender = User::find($request->sender_id);
    $receiver = User::where('email', $request->destinataire_email)->first();

    if (!$receiver) {
        return response()->json(['message' => 'Destinataire introuvable'], 404);
    }

    if ($sender->id === $receiver->id) {
        return response()->json(['message' => 'Auto-transfert interdit'], 400);
    }

    if ($sender->balance < $montant) {
        return response()->json(['message' => 'Solde insuffisant'], 400);
    }

    DB::beginTransaction();

    try {
        $sender->balance -= $montant;
        $receiver->balance += $montant;

        $sender->save();
        $receiver->save();

        DB::table('transactions')->insert([
            'sender_id' => $sender->id,
            'receiver_id' => $receiver->id,
            'amount' => $montant,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::commit();

        return response()->json([
            'success' => true,
            'new_balance' => $sender->balance
        ]);

    } catch (\Exception $e) {
        DB::rollBack();

        return response()->json([
            'message' => 'Erreur serveur',
            'error' => $e->getMessage()
        ], 500);
    }
});


// =======================
// TRANSACTIONS
// =======================
Route::get('/transactions/{userId}', function ($userId) {
    return DB::table('transactions')
        ->join('users as sender', 'transactions.sender_id', '=', 'sender.id')
        ->join('users as receiver', 'transactions.receiver_id', '=', 'receiver.id')
        ->where('sender_id', $userId)
        ->orWhere('receiver_id', $userId)
        ->select(
            'transactions.id',
            'transactions.amount',
            'transactions.created_at',
            'sender.email as sender_email',
            'receiver.email as receiver_email'
        )
        ->orderBy('transactions.created_at', 'desc')
        ->get();
});


// =======================
// ADMIN ADD MONEY
// =======================
Route::post('/admin/add-money', function (Request $request) {

    if (!filter_var($request->is_admin, FILTER_VALIDATE_BOOLEAN)) {
        return response()->json(['message' => 'Non autorisé'], 403);
    }

    $user = User::find($request->user_id);

    if (!$user) {
        return response()->json(['message' => 'Utilisateur introuvable'], 404);
    }

    $user->balance += $request->amount;
    $user->save();

    return response()->json([
        'success' => true,
        'new_balance' => $user->balance
    ]);
});