<?php

use App\Http\Controllers\ApiController;
use Illuminate\Support\Facades\Route;

// --- ROUTES PUBLIQUES (Pas besoin de Token) ---
// Seules ces deux routes sont accessibles à tout le monde
Route::post('/login', [ApiController::class, 'login']);
Route::post('/register', [ApiController::class, 'register']);
// Route de test pour voir un user spécifique (ex: /api/user/2)
Route::get('/user/{id}', [ApiController::class, 'showUser']);


// --- ROUTES PROTÉGÉES (Token OBLIGATOIRE) ---
Route::middleware('auth:sanctum')->group(function () {
    
    Route::get('/me', [ApiController::class, 'me']);          // Voir mon profil
    Route::get('/users', [ApiController::class, 'users']);    // Voir la liste des amis <--- REMIS ICI
    Route::post('/transfer', [ApiController::class, 'transfer']); // Faire un virement
    Route::get('/transactions', [ApiController::class, 'transactions']); // Voir l'historique
    Route::post('/deposit', [ApiController::class, 'deposit']);


});
