<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BankAccountController;
use App\Http\Controllers\CardController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\BeneficiaryController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\ExchangeRateController;
use App\Http\Controllers\WalletController;
use Illuminate\Support\Facades\Route;

// Public routes
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);
Route::get('/exchange-rates', [ExchangeRateController::class, 'rates']);
Route::post('/exchange-rates/convert', [ExchangeRateController::class, 'convert']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/profile', [AuthController::class, 'profile']);
    Route::put('/auth/profile', [AuthController::class, 'updateProfile']);
    Route::post('/auth/kyc', [AuthController::class, 'updateKYC']);

    // Bank Accounts
    Route::apiResource('bank-accounts', BankAccountController::class);

    // Cards
    Route::apiResource('cards', CardController::class)->only(['index', 'store', 'show']);
    Route::post('/cards/{card}/block', [CardController::class, 'toggleBlock']);
    Route::post('/cards/{card}/set-primary', [CardController::class, 'setPrimary']);

    // Transactions
    Route::get('/transactions', [TransactionController::class, 'index']);
    Route::get('/transactions/{transaction}', [TransactionController::class, 'show']);
    Route::post('/transactions/transfer', [TransactionController::class, 'transfer']);
    Route::post('/transactions/card-payment', [TransactionController::class, 'cardPayment']);

    // Beneficiaries
    Route::apiResource('beneficiaries', BeneficiaryController::class);

    // Wallets
    Route::apiResource('wallets', WalletController::class)->only(['index', 'store']);

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::post('/notifications/{notification}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/mark-all-as-read', [NotificationController::class, 'markAllAsRead']);
});
