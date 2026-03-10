<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CryptoController; // <-- 1. ON IMPORTE LE NOUVEAU CONTRÔLEUR ICI

// Routes publiques (pas besoin d'être connecté)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Routes protégées (il faut le token pour y accéder)
Route::middleware('auth:sanctum')->group(function () {
    
    // --- L'utilisateur et le Wallet ---
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    Route::post('/topup', [AuthController::class, 'topup']);
    Route::post('/transfer', [AuthController::class, 'transfer']);
    Route::get('/transactions', [AuthController::class, 'transactions']);

    // ---> 2. ON AJOUTE LES 3 NOUVELLES PORTES POUR LA CRYPTO ICI <---
    Route::get('/bkn/market', [CryptoController::class, 'getMarketData']);
    Route::post('/bkn/buy', [CryptoController::class, 'buyBkn']);
    Route::post('/bkn/sell', [CryptoController::class, 'sellBkn']);
    // -----------------------------------------------------------------
});