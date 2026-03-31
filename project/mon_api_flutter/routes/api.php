<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Mail;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\StripeController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// --- 1. ROUTES PUBLIQUES (Sans Token) ---
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Route pour le Webhook Stripe (Surtout PAS dans le middleware auth)
Route::post('/stripe/webhook', [StripeController::class, 'handleWebhook']);

// Routes de test
Route::get('/test-connexion', function () {
    return response()->json([
        'message' => 'Connexion réussie ! Laravel salue votre app Flutter.',
        'status' => 'success',
        'date' => now()->format('d/m/Y H:i')
    ]);
});

Route::get('/test-email', function () {
    try {
        $to = 'mathis.eloidin@gmail.com'; 
        Mail::raw('Félicitations ! Ton API Laravel communique bien avec Resend.', function ($message) use ($to) {
            $message->to($to)->subject('Test Réussi - App Bancaire');
        });
        return response()->json(['status' => 'success', 'message' => 'L\'email a été envoyé !']);
    } catch (\Exception $e) {
        return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
    }
});


// --- 2. ROUTES PROTÉGÉES (Nécessitent Token Bearer) ---
Route::middleware('auth:sanctum')->group(function () {
    
    // Infos Utilisateur & Solde
    Route::get('/user', [AuthController::class, 'getUserInfo']);
    
    // Historique des Transactions (Stripe + Transferts)
    Route::get('/transactions', [AuthController::class, 'getTransactions']);
    
    // Actions de compte
    Route::post('/send-money', [AuthController::class, 'sendMoney']);
    
    // Stripe : Création de l'intention de paiement
    Route::post('/payment/intent', [StripeController::class, 'createPaymentIntent']);

    Route::post('/qr-payment', [AuthController::class, 'processQrPayment']);
    
});