<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\StripeController;
use App\Models\User;
use Stripe\Stripe;
use Stripe\Webhook;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Route publique : récupération des produits
Route::get('/products', [ProductController::class, 'index']);

// Route publique : login
Route::post('/login', [AuthController::class, 'login']);

// 🔐 Routes protégées JWT
Route::group(['middleware' => 'jwt.auth'], function() {

    // Infos user
    Route::get('/users/me', function (Request $request) {
        $user = $request->user();
        return response()->json([
            'user' => $user,
            'solde' => $user->wallet_balance ?? 0,
        ]);
    });

    // Transfert
    Route::post('/transfert', [TransactionController::class, 'transfert']);

    // Checkout Stripe
    Route::post('/stripe/checkout', [StripeController::class, 'createCheckoutSession']);
});

// Success Stripe
Route::get('/success', [StripeController::class, 'success']);
Route::post('/register', [AuthController::class, 'register']);

// 🔥 WEBHOOK STRIPE (PAS DE JWT !!!)
Route::post('/stripe/webhook', function (Request $request) {

    $endpoint_secret = env('STRIPE_WEBHOOK_SECRET');
    $payload = $request->getContent();
    $sig_header = $request->header('Stripe-Signature');

    try {
        $event = Webhook::constructEvent($payload, $sig_header, $endpoint_secret);
    } catch (\Exception $e) {
        return response('Webhook error', 400);
    }

    // 🎯 Paiement réussi via Stripe Checkout
    if ($event->type == 'checkout.session.completed') {

        $session = $event->data->object;

        $userId = $session->metadata->user_id ?? null;
        $amount = ($session->amount_total ?? 0) / 100; // convertir centimes -> euros

        if ($userId) {
            $user = User::find($userId);
            if ($user) {
                $user->wallet_balance += $amount;
                $user->save();
            }
        }
    }

    return response('OK', 200);
});