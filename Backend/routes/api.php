<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ChatbotController;
use App\Http\Controllers\Api\HistoryController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\QrCodeController;
use App\Http\Controllers\Api\RechargeController;
use App\Http\Controllers\Api\TransactionController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| MoneyTransferApp - API Routes
|--------------------------------------------------------------------------
|
| Version : /api/v1/...
| Auth    : Laravel Sanctum (Bearer Token)
|
*/

// ─── Routes publiques (sans authentification) ─────────────────────────────────
Route::prefix('v1')->group(function () {

    // Auth
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login',    [AuthController::class, 'login']);
    });

    // Webhook Stripe (vérification par signature, pas par token)
    Route::post('/recharge/webhook', [RechargeController::class, 'webhook'])
         ->name('stripe.webhook');

});

// ─── Routes protégées (Sanctum Auth requis) ───────────────────────────────────
Route::prefix('v1')->middleware('auth:sanctum')->group(function () {

    // ── Authentification ──────────────────────────────────────────────────────
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me',      [AuthController::class, 'me']);
    });

    // ── Transfert d'argent ────────────────────────────────────────────────────
    Route::post('/transfer', [TransactionController::class, 'transfer']);

    // ── Recharge via Stripe ───────────────────────────────────────────────────
    Route::post('/recharge/create-intent', [RechargeController::class, 'createPaymentIntent']);

    // ── Historique des transactions ───────────────────────────────────────────
    Route::prefix('history')->group(function () {
        Route::get('/',    [HistoryController::class, 'index']);
        Route::get('/{id}', [HistoryController::class, 'show']);
    });

    // ── Profil ────────────────────────────────────────────────────────────────
    Route::prefix('profile')->group(function () {
        Route::put('/',         [ProfileController::class, 'update']);
        Route::put('/password', [ProfileController::class, 'changePassword']);
        Route::put('/pin',      [ProfileController::class, 'changePin']);
    });

    // ── QR Code ───────────────────────────────────────────────────────────────
    Route::prefix('qr')->group(function () {
        Route::post('/generate', [QrCodeController::class, 'generate']);
        Route::post('/scan',     [QrCodeController::class, 'scan']);
    });

    // ── Chatbot Ollama ────────────────────────────────────────────────────────
    Route::post('/chatbot/message', [ChatbotController::class, 'message']);

});
