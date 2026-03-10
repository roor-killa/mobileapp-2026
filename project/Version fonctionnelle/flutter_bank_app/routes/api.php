<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;

// Routes publiques (pas besoin de token)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Routes protégées (il faut un token Sanctum pour y accéder)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
    
    // Nos deux routes magiques !
    Route::post('/topup', [AuthController::class, 'topup']);
    Route::post('/transfer', [AuthController::class, 'transfer']);
    Route::get('/transactions', [AuthController::class, 'transactions']);
});