<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Mail;


// --- ROUTES PUBLIQUES (Accessibles sans jeton) ---
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::get('/test-connexion', function () {
    return response()->json([
        'message' => 'Connexion réussie ! Laravel salue votre app Flutter.',
        'status' => 'success',
        'date' => now()->format('d/m/Y H:i')
    ]);
});

// --- ROUTES PROTÉGÉES (Nécessitent le Token Bearer) ---
Route::middleware('auth:sanctum')->group(function () {
    
    // Ajoute tes routes ici pour qu'elles puissent utiliser $request->user()
    Route::get('/transactions', [AuthController::class, 'getTransactions']);
    Route::post('/send-money', [AuthController::class, 'sendMoney']); // N'oublie pas celle-ci !
    Route::get('/user', [AuthController::class, 'getUserInfo']);
});

Route::get('/test-email', function () {
    try {
        // Remplace par l'adresse mail de ton compte Resend
        $to = 'mathis.eloidin@gmail.com'; 

        Mail::raw('Félicitations ! Ton API Laravel communique bien avec Resend.', function ($message) use ($to) {
            $message->to($to)
                    ->subject('Test Réussi - App Bancaire');
        });

        return response()->json([
            'status' => 'success',
            'message' => 'L\'email a été envoyé ! Vérifie ta boîte de réception (et les spams).'
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage()
        ], 500);
    }
});