<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\StripeController;
use App\Models\User;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// 🌟 Routes publiques
Route::get('/products', [ProductController::class, 'index']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// 🔐 Routes protégées par JWT
Route::group(['middleware' => 'jwt.auth'], function() {

    // Infos utilisateur connecté
    Route::get('/users/me', function (Request $request) {
        $user = $request->user();
        return response()->json([
            'user' => $user,
            'solde' => $user->wallet_balance ?? 0,
        ]);
    });

    // Transfert
    Route::post('/transfert', [TransactionController::class, 'transfert']);

    // Stripe checkout
    Route::post('/stripe/checkout', [StripeController::class, 'createCheckoutSession']);
});

// ✅ Stripe webhook et page succès (PAS de JWT)
Route::get('/success', [StripeController::class, 'success']);
Route::post('/stripe/webhook', [StripeController::class, 'webhook']);