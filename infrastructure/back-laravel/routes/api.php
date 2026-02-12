<?php

use App\Http\Controllers\ProductController;
use App\Http\Controllers\TransferController;
use Illuminate\Support\Facades\Route;

// Routes pour les produits
Route::get('/products', [ProductController::class, 'index']);

// Routes pour les transferts d'argent
Route::prefix('transfers')->group(function () {
    // Lister tous les utilisateurs (pour sélectionner le destinataire)
    Route::get('/users', [TransferController::class, 'listUsers']);
    
    // Obtenir le solde de l'utilisateur courant
    Route::get('/balance', [TransferController::class, 'getBalance']);
    
    // Effectuer un transfert
    Route::post('/send', [TransferController::class, 'transfer']);
    
    // Historique des transferts
    Route::get('/history', [TransferController::class, 'getTransferHistory']);
});
