<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AccountController;
use App\Http\Controllers\Api\TransactionController;
use Illuminate\Support\Facades\Route;

// Routes d'authentification
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Routes protégées par authentification
Route::middleware('auth:sanctum')->group(function () {
    // Authentification
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // Comptes
    Route::get('/accounts', [AccountController::class, 'getAccounts']);
    Route::get('/accounts/{account}', [AccountController::class, 'getAccount']);
    Route::post('/accounts', [AccountController::class, 'createAccount']);

    // Transactions
    Route::get('/transactions', [TransactionController::class, 'getTransactions']);
    Route::post('/transactions/transfer', [TransactionController::class, 'transfer']);
    Route::get('/accounts/{account}/transactions', [TransactionController::class, 'getAccountTransactions']);
});
