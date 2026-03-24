<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\WalletController;
use Illuminate\Support\Facades\Route;

// Routes publiques
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// Route existante conservée
Route::get('/products', [ProductController::class, 'index']);

// Routes protégées (token Sanctum requis : Authorization: Bearer <token>)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', fn(\Illuminate\Http\Request $r) => response()->json($r->user()->only('id', 'name', 'email')));

    // Wallet
    Route::get('/wallet',                [WalletController::class, 'show']);
    Route::post('/wallet/transfer',      [WalletController::class, 'transfer']);
    Route::get('/wallet/transactions',   [WalletController::class, 'transactions']);
    Route::get('/wallet/exchange-rate',  [WalletController::class, 'exchangeRate']);
    Route::post('/wallet/convert',       [WalletController::class, 'convert']);

    // Top-up Stripe
    Route::post('/wallet/topup/create-intent', [WalletController::class, 'createPaymentIntent']);
    Route::post('/wallet/topup/confirm',        [WalletController::class, 'confirmTopUp']);
});
