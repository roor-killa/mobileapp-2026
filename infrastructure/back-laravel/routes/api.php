<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AccountController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\PaymentRequestController;
use App\Http\Controllers\Api\ChatController;
use Illuminate\Support\Facades\Route;

// Routes d'authentification
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);
Route::post('/auth/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/auth/reset-password', [AuthController::class, 'resetPassword']);

// Routes protégées par authentification
Route::middleware('auth:sanctum')->group(function () {
    // Authentification
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::post('/auth/change-password', [AuthController::class, 'changePassword']);

    // Comptes
    Route::get('/accounts', [AccountController::class, 'getAccounts']);
    Route::get('/accounts/{account}', [AccountController::class, 'getAccount']);
    Route::post('/accounts', [AccountController::class, 'createAccount']);
    Route::delete('/accounts/{account}', [AccountController::class, 'deleteAccount']);
    Route::get('/beneficiaries', [AccountController::class, 'getBeneficiaries']);

    // Transactions
    Route::get('/transactions', [TransactionController::class, 'getTransactions']);
    Route::post('/transactions/transfer', [TransactionController::class, 'transfer']);
    Route::get('/accounts/{account}/transactions', [TransactionController::class, 'getAccountTransactions']);

    // Demandes d'argent (Recevoir)
    Route::get('/payment-requests', [PaymentRequestController::class, 'index']);
    Route::post('/payment-requests', [PaymentRequestController::class, 'store']);
    Route::post('/payment-requests/{payment_request}/accept', [PaymentRequestController::class, 'accept']);
    Route::post('/payment-requests/{payment_request}/decline', [PaymentRequestController::class, 'decline']);

    // Chatbot IA
    Route::post('/chat', [ChatController::class, 'chat']);
});
