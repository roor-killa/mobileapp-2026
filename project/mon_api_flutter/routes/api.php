<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;

// --- ROUTES PUBLIQUES (Accessibles sans jeton) ---
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::get('/test-connexion', function () {
    return response()->json([
        'message' => 'Connexion réussie ! Laravel salue votre app Flutter.',
        'status' => 'success',
        'date' => now()->format('d/m/Y H:i')
    ]);
});

// --- ROUTES PROTÉGÉES (Nécessitent le Token Bearer) ---
Route::middleware('auth:sanctum')->group(function () {
    
    // Ajoute tes routes ici pour qu'elles puissent utiliser $request->user()
    Route::get('/transactions', [AuthController::class, 'getTransactions']);
    Route::post('/send-money', [AuthController::class, 'sendMoney']); // N'oublie pas celle-ci !
    
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});