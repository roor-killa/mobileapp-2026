<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\OperationController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\CryptoController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/history', [OperationController::class, 'history']);
    Route::post('/deposit', [OperationController::class, 'deposit']);
    Route::post('/withdraw', [OperationController::class, 'withdraw']);
    Route::post('/transfer', [OperationController::class, 'transfer']);

    Route::get('/crypto', [CryptoController::class, 'index']);
    Route::post('/crypto/buy', [CryptoController::class, 'buy']);
    Route::post('/crypto/sell', [CryptoController::class, 'sell']);

    Route::post('/chat', [ChatController::class, 'send']);
});