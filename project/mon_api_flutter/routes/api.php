<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;

Route::post('/login', [AuthController::class, 'login']);

Route::post('/register', [AuthController::class, 'register']);

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::get('/test-connexion', function () {
    return response()->json([
        'message' => 'Connexion réussie ! Laravel salue votre app Flutter.',
        'status' => 'success',
        'date' => now()->format('d/m/Y H:i')
    ]);
});